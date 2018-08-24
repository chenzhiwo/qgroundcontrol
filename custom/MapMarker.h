#pragma once

#include <QObject>
#include <QDateTime>
#include <QGeoCoordinate>
#include <QStringListModel>

class MapMarker : public QObject
{
    Q_OBJECT

public:
    Q_PROPERTY(QDateTime timestamp READ timestamp WRITE setTimestamp NOTIFY timestampChanged)
    Q_PROPERTY(QGeoCoordinate coordinate READ coordinate WRITE setCoordinate NOTIFY coordinateChanged)
    Q_PROPERTY(QStringListModel* images READ images CONSTANT)

    MapMarker(QObject *parent=nullptr)
        :QObject(parent),
          _images(this)
    {
    }

    virtual ~MapMarker() = default;

    QDateTime timestamp(void) const
    {
        return _timestamp;
    }

    QGeoCoordinate coordinate(void) const
    {
        return _coordinate;
    }

    QStringListModel* images(void)
    {
        return &_images;
    }

    void setTimestamp(QDateTime timestamp)
    {
        if(_timestamp == timestamp)
        {
            return;
        }
        _timestamp = timestamp;
        emit timestampChanged();
    }

    void setCoordinate(const QGeoCoordinate &coordinate)
    {
        if(_coordinate == coordinate)
        {
            return;
        }
        _coordinate = coordinate;
        emit coordinateChanged();
    }

    Q_INVOKABLE void addImage(const QString &name)
    {
        _images.insertRow(_images.rowCount());
        _images.setData(_images.index(_images.rowCount() - 1), name);
    }

private:
    QDateTime _timestamp;
    QGeoCoordinate _coordinate;
    QStringListModel _images;

signals:
    void timestampChanged();
    void coordinateChanged();
};
