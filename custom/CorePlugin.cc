#include "CorePlugin.h"

#include <QQmlEngine>
#include <QDebug>

#include "QmlComponentInfo.h"

CorePlugin::CorePlugin(QGCApplication* app, QGCToolbox* toolbox)
    :QGCCorePlugin(app, toolbox),
      _mapMarkerManager(this)
{
    qmlRegisterType<MapMarker>("QGroundControl.CorePlugin", 1, 0, "MapMarker");
    qmlRegisterType<MapMarkerManager>("QGroundControl.CorePlugin", 1, 0, "MapMarkerManager");

    QmlComponentInfo *item = new QmlComponentInfo(
                "MapMarkerView",
                QUrl("qrc:/qml/MapMarkerView.qml"),
                QUrl(),
                this
                );
    QGCCorePlugin::customMapItems()->append(item);

    item = new QmlComponentInfo(
                "MapMarkerPopup",
                QUrl("qrc:/qml/MapMarkerPopup.qml"),
                QUrl(),
                this
                );
    QGCCorePlugin::customMapItems()->append(item);

   item = new QmlComponentInfo(
                "MapMarkerToolView",
                QUrl("qrc:/qml/MapMarkerToolView.qml"),
                QUrl(),
                this
                );
    QGCCorePlugin::customMapItems()->append(item);
}

CorePlugin::~CorePlugin()
{
}
