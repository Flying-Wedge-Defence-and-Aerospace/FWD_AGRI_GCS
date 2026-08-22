import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11

import QGroundControl 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools 1.0


Rectangle {
    id: settingsDrawerRoot
    color: qgcPal.window

    signal closeDrawer

    QGCPalette { id: qgcPal }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: ScreenTools.defaultFontPixelWidth
        spacing: ScreenTools.defaultFontPixelWidth * (ScreenTools.isMobile ? 2 : 1)

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: closeButton.height

            QGCColoredImage {
                id: closeButton
                source: "qrc:/res/cheveron-right.svg"
                width: ScreenTools.defaultFontPixelWidth * 4
                height: width
                fillMode: Image.PreserveAspectFit
                color: qgcPal.buttonText
                anchors.right: parent.right
                anchors.rightMargin: ScreenTools.defaultFontPixelWidth / 2

                QGCMouseArea {
                    anchors.fill: parent
                    onClicked: settingsDrawerRoot.closeDrawer()
                }
            }
        }

        Rectangle {
            Layout.preferredWidth: parent.width
            Layout.alignment: Qt.AlignHCenter
            height: 1
            color: "gray"
        }

        Item {
            id: vehicleSetupItem
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 2.2
            clip: true

            Rectangle {
                anchors.fill: parent
                color: qgcPal.window
            }

            Row {
                anchors.centerIn: parent
                spacing: ScreenTools.defaultFontPixelWidth
                QGCColoredImage {
                    source: "qrc:/res/vehSet_icon"
                    height: ScreenTools.defaultFontPixelHeight * (ScreenTools.isMobile ? 3.5 : 5)
                    width: ScreenTools.defaultFontPixelWidth * (ScreenTools.isMobile ? 5 : 5)
                    fillMode: Image.PreserveAspectFit
                    color: qgcPal.buttonText
                }
                QGCLabel {
                    text: "Vehicle Setup"
                    color: qgcPal.buttonText
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !ScreenTools.isMobile
                }
            }

            QGCMouseArea {
                anchors.fill: parent
                onClicked: {
                    console.log("Vehicle Setup clicked")
                    mainWindow.showSetupTool()
                }
            }
        }

        Rectangle {
            Layout.preferredWidth: parent.width
            Layout.alignment: Qt.AlignHCenter
            height: 1
            color: "gray"
        }

        Item {
            id: analyzeSettingsItem
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 2.2
            clip: true

            Rectangle {
                anchors.fill: parent
                color: qgcPal.window
            }

            Row {
                anchors.centerIn: parent
                spacing: ScreenTools.defaultFontPixelWidth
                QGCColoredImage {
                    source: "qrc:/res/analyze_icon"
                    height: ScreenTools.defaultFontPixelHeight * (ScreenTools.isMobile ? 3.5 : 5)
                    width: ScreenTools.defaultFontPixelWidth * (ScreenTools.isMobile ? 5 : 5)
                    fillMode: Image.PreserveAspectFit
                    color: qgcPal.buttonText
                }
                QGCLabel {
                    text: "Analyze Settings"
                    color: qgcPal.buttonText
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !ScreenTools.isMobile
                }
            }

            QGCMouseArea {
                anchors.fill: parent
                onClicked: mainWindow.showAnalyzeTool()
            }
        }

        Rectangle {
            Layout.preferredWidth: parent.width
            Layout.alignment: Qt.AlignHCenter
            height: 1
            color: "gray"
        }

        Item {
            id: appSettingsItem
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 2.2
            clip: true

            Rectangle {
                anchors.fill: parent
                color: qgcPal.window
            }

            Row {
                anchors.centerIn: parent
                spacing: ScreenTools.defaultFontPixelWidth
                QGCColoredImage {
                    source: "qrc:/res/set_icon"
                    height: ScreenTools.defaultFontPixelHeight * (ScreenTools.isMobile ? 3.5 : 5)
                    width: ScreenTools.defaultFontPixelWidth * (ScreenTools.isMobile ? 5 : 5)
                    fillMode: Image.PreserveAspectFit
                    color: qgcPal.buttonText
                }
                QGCLabel {
                    text: "Application Settings"
                    color: qgcPal.buttonText
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !ScreenTools.isMobile
                }
            }

            QGCMouseArea {
                anchors.fill: parent
                onClicked: mainWindow.showSettingsTool()
            }
        }

        Rectangle {
            Layout.preferredWidth: parent.width
            Layout.alignment: Qt.AlignHCenter
            height: 1
            color: "gray"
        }

        Item { Layout.fillHeight: true }

        QGCLabel {
            text:               qsTr("Version: ") + QGroundControl.qgcVersion
            color:              qgcPal.text
            opacity:            0.5
            font.pointSize:     ScreenTools.smallFontPointSize
            Layout.alignment:   Qt.AlignHCenter
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: profileLayout.height + ScreenTools.defaultFontPixelHeight / 2
            color: qgcPal.window
            border.width: 1
            border.color: "gray"

            ColumnLayout {
                id: profileLayout
                anchors.centerIn: parent

                QGCButton {
                    text: "Logout"
                }
            }
        }
    }
}
