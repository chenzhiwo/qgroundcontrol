#pragma once

#include <QObject>
#include <QAbstractVideoSurface>
#include <QVideoSurfaceFormat>
#include <QVideoFrame>
#include <QUrl>
#include <QSize>
#include <QThread>
#include <QtDebug>

#include <opencv2/opencv.hpp>

class CaptureWorker : public QThread
{
    Q_OBJECT

signals:
    void frameChanged(void);

public:
    CaptureWorker(cv::VideoCapture* capture, QVideoFrame* frame, QObject* parent=nullptr)
        :QThread(parent),
          _capture(capture),
          _frame(frame->height(), frame->width(), CV_8UC4, frame->bits())
    {
    }

    ~CaptureWorker() = default;

private:
    cv::VideoCapture* _capture;
    cv::Mat _frame;
    cv::Mat _image;

    void run(void) override {
        int delay = 1000 / _capture->get(cv::CAP_PROP_FPS);

        forever {
            if(isInterruptionRequested())
            {
                return;
            }

            if(_capture->grab())
            {
                if(!_capture->retrieve(_image))
                {
                    break;
                }
                cv::cvtColor(_image, _frame, cv::COLOR_RGB2RGBA);

                emit frameChanged();
            }

            QThread::msleep(delay);
        }
    }
};

class VideoCapture : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QAbstractVideoSurface* videoSurface READ videoSurface WRITE setVideoSurface NOTIFY videoSurfaceChanged)

signals:
    void sourceChanged(void);
    void videoSurfaceChanged(void);

private slots:
    void sourceUpdate(void)
    {
        if(_worker)
        {
            _worker->requestInterruption();
            _worker->wait();
            _worker = nullptr;
        }

        if(_capture.isOpened())
        {
            _capture.release();
        }

        if(_source.isLocalFile())
        {
            if(!_capture.open(_source.path().toStdString()))
            {
                qCritical() << "Open" << _source.path() << "failed.";
                return;
            }
        }
        else
        {
            if(!_capture.open(_source.toString().toStdString()))
            {
                qCritical() << "Open" << _source.toString() << "failed.";
                return;
            }
        }

        if(_videoFrame)
        {
            if(_videoFrame->isMapped())
            {
                _videoFrame->unmap();
            }
            delete _videoFrame;
            _videoFrame = nullptr;
        }

        QSize size;
        size.setWidth(_capture.get(cv::CAP_PROP_FRAME_WIDTH));
        size.setHeight(_capture.get(cv::CAP_PROP_FRAME_HEIGHT));

        _videoFrame = new QVideoFrame(
                    size.width() * size.height() * PIXEL_BYTES,
                    size,
                    size.width() * PIXEL_BYTES,
                    PIXEL_FORMAT
                    );

        if(!_videoFrame)
        {
            return;
        }
        _videoFrame->map(QAbstractVideoBuffer::ReadOnly);

        videoSurfaceUpdate();

        _worker = new CaptureWorker(&_capture, _videoFrame, this);
        connect(_worker, SIGNAL(frameChanged()), this, SLOT(videoFrameUpdate()));
        connect(_worker, SIGNAL(finished()), _worker, SLOT(deleteLater()));
        _worker->start();
    }

    void videoSurfaceUpdate(void)
    {
        if(!_videoSurface)
        {
            return;
        }

        if(_videoSurface->isActive())
        {
            _videoSurface->stop();
        }

        if(!_videoFrame)
        {
            return;
        }

        if(!_videoSurface->start(QVideoSurfaceFormat(_videoFrame->size(), PIXEL_FORMAT)))
        {
            qCritical() << "Start video surface failed.";
        }
    }

    void videoFrameUpdate(void)
    {
        if(!_videoSurface)
        {
            return;
        }

        if(!_videoSurface->present(*_videoFrame))
        {
            qCritical() << "VideoSurface present failed.";
        }
    }

public:
    VideoCapture(QObject* parent=nullptr)
        :QObject(parent),
          _source(),
          _videoSurface(nullptr),
          _videoFrame(nullptr),
          _worker(nullptr)
    {
        connect(this, SIGNAL(sourceChanged()), this, SLOT(sourceUpdate()));
        connect(this, SIGNAL(videoSurfaceChanged()), this, SLOT(videoSurfaceUpdate()));
    }

    ~VideoCapture()
    {
        if(_worker)
        {
            _worker->requestInterruption();
            _worker->wait();
        }
    }

    QUrl source(void)
    {
        return _source;
    }

    void setSource(const QUrl& source)
    {
        if(_source != source)
        {
            _source = source;
            emit sourceChanged();
        }
    }

    QAbstractVideoSurface* videoSurface(void)
    {
        return _videoSurface;
    }

    void setVideoSurface(QAbstractVideoSurface * videoSurface)
    {
        if(_videoSurface != videoSurface)
        {
            _videoSurface = videoSurface;
            emit videoSurfaceChanged();
        }
    }

private:
    const int PIXEL_BYTES = 4;
    const QVideoFrame::PixelFormat PIXEL_FORMAT = QVideoFrame::PixelFormat::Format_ARGB32;

    QUrl _source;
    QAbstractVideoSurface* _videoSurface;
    QVideoFrame* _videoFrame;

    cv::VideoCapture _capture;

    CaptureWorker* _worker;
};
