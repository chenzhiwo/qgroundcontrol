QT += multimedia

DEFINES += \
    QGC_APPLICATION_NAME=\"\\\"$${QGC_APP_NAME}\\\"\" \
    QGC_ORG_NAME=\"\\\"$${QGC_ORG_NAME}\\\"\" \
    QGC_ORG_DOMAIN=\"\\\"$${QGC_ORG_DOMAIN}\\\"\" \
    CUSTOMCLASS=CorePlugin \
    CUSTOMHEADER=\"\\\"CorePlugin.h\\\"\"

INCLUDEPATH += \
    $$PWD \
    $$(OPENCV_INCLUDEPATH)

LIBS += \
    -L$$(OPENCV_LIBPATH) \
    -lopencv_core3 \
    -lopencv_imgproc3 \
    -lopencv_videoio3

HEADERS += \
    $$PWD/CorePlugin.h \
    $$PWD/MapMarkerManager.h \
    $$PWD/MapMarker.h \
    $$PWD/VideoCapture.h

SOURCES += \
    $$PWD/CorePlugin.cc \
    $$PWD/MapMarkerManager.cc

RESOURCES += \
    $$PWD/Custom.qrc
