#pragma once

#include <iostream>
#include "QGCCorePlugin.h"

class CustomPlugin : public QGCCorePlugin{
    Q_OBJECT
public:
    CustomPlugin(QGCApplication* app, QGCToolbox* toolbox)
        :QGCCorePlugin(app, toolbox)
    {
        std::cout << "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" << std::endl;
    }

    ~CustomPlugin() = default;

private:
};
