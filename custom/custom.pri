DEFINES += \
    QGC_APPLICATION_NAME=\"\\\"$${QGC_APP_NAME}\\\"\" \
    QGC_ORG_NAME=\"\\\"$${QGC_ORG_NAME}\\\"\" \
    QGC_ORG_DOMAIN=\"\\\"$${QGC_ORG_DOMAIN}\\\"\" \
    CUSTOMCLASS=CorePlugin \
    CUSTOMHEADER=\"\\\"CorePlugin.h\\\"\"

INCLUDEPATH += \
    $$PWD

HEADERS += \
    $$PWD/CorePlugin.h \
    $$PWD/MapMarkerManager.h \
    $$PWD/MapMarker.h

SOURCES += \
    $$PWD/CorePlugin.cc \
    $$PWD/MapMarkerManager.cc

RESOURCES += \
    $$PWD/Custom.qrc
