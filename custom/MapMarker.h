#pragma once

#include <QObject>
#include <QDateTime>
#include <QGeoCoordinate>

class MapMarker : public QObject
{
    Q_OBJECT

public:
    Q_PROPERTY(QDateTime timestamp READ timestamp WRITE setTimestamp NOTIFY timestampChanged)
    Q_PROPERTY(QGeoCoordinate coordinate READ coordinate WRITE setCoordinate NOTIFY coordinateChanged)

    MapMarker(QObject *parent=nullptr)
        :QObject(parent)
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

private:
    QDateTime _timestamp;
    QGeoCoordinate _coordinate;

signals:
    void timestampChanged();
    void coordinateChanged();
};
