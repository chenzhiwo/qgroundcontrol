import QtQuick 2.0
import QtPositioning 5.8

MouseArea {
    anchors.fill: parent
    enabled: false
    preventStealing: true
    hoverEnabled: true

    function getCoordinate()
    {
        // In case of overlap
        return parent.toCoordinate(Qt.point(mouseX - 1, mouseY - 1))
    }
}
