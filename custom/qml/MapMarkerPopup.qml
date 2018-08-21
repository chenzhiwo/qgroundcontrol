import QtQuick 2.0
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3

import QGroundControl 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools 1.0
import QGroundControl.CorePlugin 1.0

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

    property MapMarkerManager markerManager: QGroundControl.corePlugin.mapMarkerManager
    property MapMarker marker: MapMarker {
    }
    property MapCoordinatePicker coordinatePicker

    Connections {
        target: markerManager
        onPopupOpenRemapped: {
            popup.marker = marker
            popup.open()
        }
    }

    QGCPalette {
        id: qgcPal
        colorGroupEnabled: true
    }

    Item {
        anchors.fill: parent

        ColumnLayout {
            id: rowLayout
            anchors.top: parent.top
            anchors.right: parent.right
            spacing: ScreenTools.defaultFontPixelWidth

            QGCLabel {
                text: marker.timestamp.toLocaleString()
            }

            QGCLabel {
                text: marker.coordinate.latitude
            }

            QGCLabel {
                text: marker.coordinate.longitude
            }

            QGCLabel {
                text: marker.coordinate.altitude
            }

            QGCButton {
                text: qsTr("Picker")
                Layout.fillWidth: true

                Connections {
                    target: coordinatePicker

                    onPositionChanged: {
                        marker.coordinate = coordinatePicker.getCoordinate()
                    }

                    onClicked: {
                        marker.coordinate = coordinatePicker.getCoordinate()
                        coordinatePicker.enabled = false
                    }
                }

                onClicked: {
                    popup.close()
                    coordinatePicker.enabled = true
                }
            }

            QGCButton {
                text: qsTr("Delete")
                Layout.fillWidth: true

                onClicked: {
                    popup.close()
                    markerManager.remove(marker)
                }
            }

            QGCButton {
                text: qsTr("Close")
                Layout.fillWidth: true

                onClicked: {
                    popup.close()
                }
            }
        }
    }

    // Create a Coordinate Picker, set it's parent to map.
    Component.onCompleted: {
        var component = Qt.createComponent("qrc:/qml/MapCoordinatePicker.qml");
        if (component.status === Component.Ready) {
            coordinatePicker = component.createObject(map, {})
        }

    }

    Component.onDestruction: {
        if (coordinatePicker) {
            coordinatePicker.destroy()
        }
    }
}
