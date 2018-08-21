import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtPositioning 5.8

import QGroundControl 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools 1.0
import QGroundControl.CorePlugin 1.0

Item {
    anchors.fill: parent

    property string markerFile: QGroundControl.settingsManager.appSettings.savePath.value + "/Markers/markers.xml"
    property MapMarkerManager markerManager: QGroundControl.corePlugin.mapMarkerManager

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
