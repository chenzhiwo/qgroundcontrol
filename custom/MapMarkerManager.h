#pragma once

#include <QObject>
#include <QString>
#include <QSettings>

#include <QmlObjectListModel.h>

#include "MapMarker.h"

class MapMarkerManager : public QObject
{
    Q_OBJECT

public:
    Q_PROPERTY(QmlObjectListModel* markers READ markers CONSTANT)

    MapMarkerManager(QObject* parent=nullptr);

    virtual ~MapMarkerManager();

    Q_INVOKABLE bool loadXML(const QString &file);

    Q_INVOKABLE bool saveXML(const QString &file);

    Q_INVOKABLE bool append(MapMarker* marker);

    Q_INVOKABLE bool remove(MapMarker* marker);

    Q_INVOKABLE MapMarker* add(void);

    Q_INVOKABLE MapMarker* get(int index);

    Q_INVOKABLE bool plan(void);

    QmlObjectListModel* markers(void)
    {
        return &_markers;
    }

private:
    QSettings _settings;
    QmlObjectListModel _markers;

signals:
    void popupOpenRemapped(MapMarker* marker);

public slots:
    void popupOpenRemap(MapMarker* marker)
    {
        emit popupOpenRemapped(marker);
    }
};
