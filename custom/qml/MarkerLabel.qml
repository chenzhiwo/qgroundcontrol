import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2
import QGroundControl.Controls 1.0
import QGroundControl.ScreenTools 1.0

RowLayout {
    spacing: ScreenTools.defaultFontPixelWidth

    property string label
    property string value

    QGCLabel {
        text: label
        Layout.fillWidth: true
        elide: Text.ElideLeft
        horizontalAlignment: Text.AlignLeft
        style: Text.Outline
    }

    QGCLabel {
        text: value
        Layout.fillWidth: true
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignRight
        style: Text.Outline
    }
}
