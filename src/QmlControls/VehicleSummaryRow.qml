import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts  1.2

Item {

    property string labelText: "Label"
    property string valueText: "value"

    width: parent.width
    height: 30   // or whatever your row height is

    // Left label
    QGCLabel {
        id: label
        text: labelText
        color: "yellow"
        font.bold: true
        font.italic: true
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        //anchors.right: divider.left
        //anchors.rightMargin: 8   // spacing before divider
        //horizontalAlignment: Text.AlignRight
        //elide: Text.ElideRight
    }

    // Center divider (fixed position)
    Rectangle {
        id: divider
        width: 1
        color: "white"
        opacity: 0.4
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        height: parent.height * 0.8
    }

    // Right label
    QGCLabel {
        id: value
        text: valueText
        font.bold: true
        anchors.left: divider.right
        anchors.leftMargin: 8
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignRight
        elide: Text.ElideRight
    }
}
