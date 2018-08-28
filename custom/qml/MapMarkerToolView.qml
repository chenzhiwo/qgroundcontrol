import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtPositioning 5.8
import QtMultimedia 5.9

import QGroundControl 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools 1.0
import QGroundControl.CorePlugin 1.0

Item {
    anchors.fill: parent

    property string markerPath: QGroundControl.settingsManager.appSettings.savePath.value + "/Markers"
    property string markerFile: markerPath + "/markers.xml"
    property MapMarkerManager markerManager: QGroundControl.corePlugin.mapMarkerManager
    property var activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    QGCPalette {
        id: qgcPal
        colorGroupEnabled: true
    }

    Image {
        anchors.margins: ScreenTools.defaultFontPixelWidth
        source: "qrc:/images/menu.png"
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        MouseArea {
            anchors.fill: parent

            onClicked: {
                popup.open()
            }
        }
    }

    Popup {
        id: popup
        x: parent.x
        y: parent.y
        width: parent.width - margins * 2
        height: parent.height - margins * 2
        margins: ScreenTools.defaultFontPixelWidth * 2
        padding: ScreenTools.defaultFontPixelWidth
        focus: true
        modal: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        palette.window: qgcPal.window

        Item {
            anchors.fill: parent

            VideoCapture {
                id: capture
            }

            VideoOutput {
                id: video
                anchors.fill: parent
                source: capture
            }

            ColumnLayout {
                id: rowLayout
                anchors.top: parent.top
                anchors.right: parent.right
                spacing: ScreenTools.defaultFontPixelWidth

                QGCButton {
                    text: qsTr("Close")
                    Layout.fillWidth: true

                    onClicked: {
                        popup.close()
                    }
                }

                QGCButton {
                    text: qsTr("Add")
                    Layout.fillWidth: true

                    onClicked: {
                        popup.close()
                        var marker = markerManager.add()
                        // Set date time to now
                        marker.timestamp = new Date()
                        marker.coordinate = map.center
                        markerManager.popupOpenRemap(marker)
                    }
                }

                QGCButton {
                    text: qsTr("Plan")
                    Layout.fillWidth: true

                    onClicked: {
                        popup.close()
                        mainWindow.showPlanView()
                        markerManager.plan()
                    }
                }

                QGCButton {
                    text: qsTr("Streaming")
                    Layout.fillWidth: true
                    checkable: true

                    onClicked: {
                        if(checked)
                        {
//                            capture.source = "rtsp://admin:admin@192.168.100.109:554/cam1/h264"
                            capture.source = "file:///home/chenz/desktop/bridge/MOV_0364.MOV"
                        }
                        else
                        {
                            capture.source = ""
                        }
                    }
                }

                QGCButton {
                    text: qsTr("Capture")
                    Layout.fillWidth: true

                    onClicked: {
                        if(!activeVehicle)
                        {
                            return
                        }

                        video.grabToImage(function(result) {
                            var date = new Date()
                            var imageFile = markerPath + "/" + Qt.formatDateTime(date, "yyyy-MM-ddThh:mm:ss:zzz") + ".png"
                            result.saveToFile(imageFile)
                            var marker = markerManager.add()
                            // Set date time to now
                            marker.timestamp = date
                            marker.coordinate = activeVehicle.coordinate
                            marker.heading = activeVehicle.heading.value
                            marker.addImage(imageFile)
                        }
                        )
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        console.log("Load markers from", markerFile)
        markerManager.loadXML(markerFile)
    }

    Component.onDestruction: {
        console.log("Save markers to", markerFile)
        markerManager.saveXML(markerFile)
    }
}
