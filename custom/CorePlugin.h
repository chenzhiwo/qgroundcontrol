#pragma once

#include "QGCCorePlugin.h"

#include "MapMarkerManager.h"

class CorePlugin : public QGCCorePlugin
{
    Q_OBJECT

public:
    Q_PROPERTY(MapMarkerManager* mapMarkerManager READ mapMarkerManager CONSTANT)

    CorePlugin(QGCApplication* app, QGCToolbox* toolbox);

    virtual ~CorePlugin();

    MapMarkerManager* mapMarkerManager(void) {
        return &_mapMarkerManager;
    }

private:
    MapMarkerManager _mapMarkerManager;
};
