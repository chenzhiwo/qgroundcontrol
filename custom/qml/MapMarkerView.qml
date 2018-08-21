import QtQuick 2.0
import QtLocation 5.11

import QGroundControl 1.0
import QGroundControl.CorePlugin 1.0

MapItemView {
    model: QGroundControl.corePlugin.mapMarkerManager.markers

    property MapMarkerManager markerManager: QGroundControl.corePlugin.mapMarkerManager

    delegate: MapQuickItem {
        coordinate: object.coordinate
        anchorPoint.x: sourceItem.width / 2
        anchorPoint.y: sourceItem.height

        sourceItem:  Image {
            source: "qrc:/images/marker.png"

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    markerManager.popupOpenRemap(markerManager.get(index))
                }
            }
        }

        Component.onCompleted: {
            console.log("Marker[" + index + "]", "(" + coordinate + ")")
        }
    }
}
