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
    clip: true

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

        Image {
            id: image
            anchors.centerIn: parent

            onSourceChanged: {
                scale = 1.0
                anchors.centerIn = parent
            }

            MouseArea {
                id: mouseArea
                anchors.fill: image

                drag {
                    target: image
                    axis: Drag.XandYAxis
                }

                onPressed: {
                    image.anchors.centerIn = undefined
                }

                onWheel: {
                    if(wheel.angleDelta.y > 0)
                    {
                        image.scale /= 0.9
                    }
                    else
                    {
                        image.scale *= 0.9
                    }
                }

                onDoubleClicked: {
                    image.scale = 1.0
                }
            }
        }

        ListView {
            id: imageList
            width: parent.width
            height: ScreenTools.defaultFontPixelWidth * 10
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            spacing: ScreenTools.defaultFontPixelWidth
            orientation: ListView.Horizontal
            clip: true
            focus: true

            model: marker.images

            highlight: Rectangle
            {
                color: "black"
                opacity: 0.4
                focus: true
                z: imageList.z + 2
                width: contentWidth
                height: contentHeight
            }

            delegate: Image {
                width: sourceSize.width * (height / sourceSize.height)
                height: imageList.height
                fillMode: Image.PreserveAspectFit
                source: "file://" + display

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        imageList.currentIndex = index
                    }
                }
            }

            onCurrentIndexChanged: {
                image.source = currentItem.source
            }
        }

        ColumnLayout {
            id: labelLayout
            anchors.top: parent.top
            anchors.left: parent.left
            spacing: ScreenTools.defaultFontPixelWidth

            MarkerLabel {
                label: "TIME"
                value: Qt.formatDateTime(marker.timestamp, "yyyy-MM-ddThh:mm:ss")
            }

            MarkerLabel {
                label: "LAT"
                value: marker.coordinate.latitude
            }

            MarkerLabel {
                label: "LON"
                value: marker.coordinate.longitude
            }

            MarkerLabel {
                label: "ALT"
                value: marker.coordinate.altitude
            }

            MarkerLabel {
                label: "HED"
                value: marker.heading
            }
        }

        ColumnLayout {
            id: buttonLayout
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
                text: qsTr("Image")
                Layout.fillWidth: true

                QGCFileDialog {
                    id: imageFileDialog
                    title: qsTr("Select image")
                    selectExisting: true

                    onAcceptedForLoad: {
                        marker.addImage(file);
                    }
                }

                onClicked: {
                    imageFileDialog.openForLoad()
                }
            }

            QGCButton {
                text: qsTr("Move")
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

        }
    }

    onClosed: {
        image.source = ""
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
