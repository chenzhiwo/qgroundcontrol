DEFINES += QGC_APPLICATION_NAME=\"\\\"QGroundControl By AutoGoLab\\\"\"
DEFINES += QGC_ORG_NAME=\"\\\"QGroundControl.org & AutoGoLab\\\"\"
DEFINES += QGC_ORG_DOMAIN=\"\\\"org.qgroundcontrol\\\"\"

DEFINES += \
    CUSTOMCLASS=CustomPlugin \
    CUSTOMHEADER=\"\\\"CustomPlugin.h\\\"\"

INCLUDEPATH += \
    $$PWD

HEADERS += \
    $$PWD/CustomPlugin.h

SOURCES += \
    $$PWD/CustomPlugin.cpp
