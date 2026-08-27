import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11

import QGroundControl 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools 1.0

Rectangle {
    id: _root
    color: qgcPal.window
    anchors.fill: parent
    anchors.margins: ScreenTools.defaultFontPixelWidth
    height: aboutColumn.implicitHeight

    QGCPalette { id: qgcPal }

    property bool   _checking: false
    property string _statusText: ""
    property color  _statusColor: qgcPal.text

    Connections {
        target: fwdUpdateManager
        onUpdateAvailable: {
            _checking = false
            _statusText = qsTr("Update available: %1").arg(version)
            _statusColor = qgcPal.colorGreen
        }
        onNoUpdateAvailable: {
            _checking = false
            _statusText = qsTr("You're up to date!")
            _statusColor = qgcPal.colorGreen
        }
        onCheckFailed: {
            _checking = false
            _statusText = qsTr("Check failed: %1").arg(error)
            _statusColor = "red"
        }
    }

    QGCFlickable {
        anchors.fill: parent
        anchors.horizontalCenter: parent.horizontalCenter
        flickableDirection: Flickable.VerticalFlick
        contentHeight:      aboutColumn.height
        contentWidth:       aboutColumn.width
        clip: true

        Column {
            id:                 aboutColumn
            width:              _root.width
            spacing:            ScreenTools.defaultFontPixelHeight * 0.5
            anchors.margins:    ScreenTools.defaultFontPixelWidth

            Item {
                width:              ScreenTools.defaultFontPixelWidth * 75
                height:             aboutLabel.height
                anchors.margins:    ScreenTools.defaultFontPixelWidth
                anchors.horizontalCenter: parent.horizontalCenter
                QGCLabel {
                    id:             aboutLabel
                    text:           qsTr("About")
                    font.pointSize: 11
                    font.family:    ScreenTools.demiboldFontFamily
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            Rectangle {
                width: ScreenTools.defaultFontPixelWidth * 75
                height: aboutContent.height + 20
                radius: 6
                color: "transparent"
                border.color: "#888"
                anchors.horizontalCenter: parent.horizontalCenter

                ColumnLayout {
                    id: aboutContent
                    anchors.centerIn: parent
                    spacing: ScreenTools.defaultFontPixelWidth * 2

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 20

                        QGCLabel {
                            text: qsTr("Application Name")
                            font.pointSize: 10
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            horizontalAlignment: Text.AlignLeft
                        }

                        Item { Layout.fillWidth: true }

                        QGCLabel {
                            text: "FWD Agri GCS"
                            font.pointSize: 10
                            color: qgcPal.text
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        }
                    }

                    Rectangle {
                        height: 1
                        Layout.fillWidth: true
                        color: "gray"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 20

                        QGCLabel {
                            text: qsTr("Version")
                            font.pointSize: 10
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            horizontalAlignment: Text.AlignLeft
                        }

                        Item { Layout.fillWidth: true }

                        QGCLabel {
                            text: QGroundControl.qgcVersion
                            font.pointSize: 10
                            color: qgcPal.text
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        }
                    }

                    Rectangle {
                        height: 1
                        Layout.fillWidth: true
                        color: "gray"
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 20

                        QGCLabel {
                            text: qsTr("Update Status")
                            font.pointSize: 10
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            horizontalAlignment: Text.AlignLeft
                        }

                        Item { Layout.fillWidth: true }

                        QGCLabel {
                            text: _root._checking ? qsTr("Checking...") : _root._statusText
                            font.pointSize: 10
                            color: _root._checking ? qgcPal.text : _root._statusColor
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                        }
                    }

                    Rectangle {
                        height: 1
                        Layout.fillWidth: true
                        color: "gray"
                    }

                    QGCButton {
                        text: _root._checking ? qsTr("Checking...") : qsTr("Check for Updates")
                        enabled: !_root._checking
                        Layout.alignment: Qt.AlignHCenter
                        onClicked: {
                            _root._checking = true
                            _root._statusText = ""
                            fwdUpdateManager.checkForUpdates()
                        }
                    }
                }
            }
        }
    }
}
