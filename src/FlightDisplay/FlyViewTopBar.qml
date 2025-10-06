import QtQuick                  2.12
import QtQuick.Controls         2.15
import QtQuick.Dialogs          1.3
import QtQuick.Layouts          1.12

import QtLocation               5.3
import QtPositioning            5.3
import QtQuick.Window           2.2
import QtQml.Models             2.1

import QtGraphicalEffects 1.0

import QGroundControl               1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.Controllers   1.0
import QGroundControl.Controls      1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0


Item {
    id: root
    width: 800
    height: 40

    property var activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    Component {
        id: flightModeMenu

        Rectangle {
            width: flickable.width + (ScreenTools.defaultFontPixelWidth * 2)
            height: flickable.height + (ScreenTools.defaultFontPixelWidth * 2)
            radius: ScreenTools.defaultFontPixelHeight * 0.5
            color: /*qgcPal.window*/ "#2c3e50"
            border.color: qgcPal.text

            QGCFlickable {
                id: flickable
                anchors.margins: ScreenTools.defaultFontPixelWidth
                anchors.top: parent.top
                anchors.left: parent.left
                width: mainLayout.width
                height: _fullWindowHeight <= mainLayout.height ? _fullWindowHeight : mainLayout.height
                flickableDirection: Flickable.VerticalFlick
                contentHeight: mainLayout.height
                contentWidth: mainLayout.width

                property real _fullWindowHeight: mainWindow.contentItem.height - (indicatorPopup.padding * 2) - (ScreenTools.defaultFontPixelWidth * 2)

                ColumnLayout {
                    id: mainLayout
                    spacing: ScreenTools.defaultFontPixelWidth / 2

                    Repeater {
                        model: activeVehicle ? activeVehicle.flightModes : []

                        QGCButton {
                            text: modelData
                            backRadius: 7
                            Layout.fillWidth: true
                            onClicked: {
                                activeVehicle.flightMode = text
                                mainWindow.hideIndicatorPopup()
                            }
                        }
                    }
                }
            }
        }
    }



    Rectangle {
        id: centerBar
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: 800
        height: 40
        color: "#66FFFFFF"
        radius: height - 35
        border.width: 2
        border.color: "red"

        RowLayout {
            id: widgetLayout
            anchors.fill: parent
            spacing: 0

            Loader {
                id: messageIndicatorLoader
                //Layout.leftMargin: 12
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                //Layout.preferredWidth: 75
                source: "qrc:/toolbar/GPSIndicator.qml"
                //visible: item && item.showIndicator
            }

            Rectangle {
                width: 1
                color: "gray"
                Layout.fillHeight: true
            }

            Loader {
                id: batteryIndicatorLoader
                //Layout.leftMargin: 12
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                //Layout.preferredWidth: 90
                source: "qrc:/toolbar/BatteryIndicator.qml"
                //visible: item && item.showIndicator
            }

            Rectangle {
                width: 1
                color: "gray"
                Layout.fillHeight: true
            }

            MainStatusIndicator {
                id: mainIndicator
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.preferredWidth: 120
                //Layout.fillWidth:  true
                //Layout.leftMargin: 15
            }

            Rectangle {
                width: 1
                color: "gray"
                Layout.fillHeight: true
            }

            // QGCLabel {
            //     Layout.preferredWidth: 100
            //     id: modeLabel
            //     text: activeVehicle ? activeVehicle.flightMode : qsTr("FLIGHT MODE: N/A")
            //     color: "black"
            //     font.bold: true
            //     font.pointSize: 12
            //     font.family: "Times New Roman"
            //     Layout.alignment: Qt.AlignHCenter
            //     //Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            //     //Layout.fillWidth: true

            //     ToolTip.visible: flightMode.containsMouse
            //     ToolTip.text: "Mode"

            //     MouseArea {
            //         id: flightMode
            //         anchors.fill: parent
            //         hoverEnabled: true
            //         onClicked: {
            //             if(activeVehicle) {
            //                 mainWindow.showIndicatorPopup(modeLabel, flightModeMenu)
            //             }
            //         }
            //     }
            // }

            Item {
                    id: centerContainer
                    //Layout.fillWidth: true
                    width: 140
                    Layout.alignment: Qt.AlignVCenter
                    height: parent.height

                    QGCLabel {
                        id: modeLabel
                        anchors.centerIn: parent
                        text: activeVehicle ? activeVehicle.flightMode : qsTr("FLIGHT MODE: N/A")
                        color: "black"
                        font.bold: true
                        font.pointSize: 12
                        font.family: "Times New Roman"

                        ToolTip.visible: flightMode.containsMouse
                        ToolTip.text: "Mode"

                        MouseArea {
                            id: flightMode
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (activeVehicle) {
                                    mainWindow.showIndicatorPopup(modeLabel, flightModeMenu)
                                }
                            }
                        }
                    }
                }


            Rectangle {
                width: 1
                color: "gray"
                Layout.fillHeight: true
            }

            // QGCLabel {
            //     text: _activeVehicle ? _activeVehicle.firmwareTypeString + " - " + _activeVehicle.vehicleTypeString
            //                          : qsTr("No Vehicle")
            //     color: "black"
            //     font.bold: true
            //     font.family: "Times New Roman"
            //     font.capitalization: Font.AllUppercase
            //     horizontalAlignment: Text.AlignHCenter
            //     Layout.fillWidth: true
            //     font.pointSize: 11

            //     ToolTip.visible: vehicleName.containsMouse
            //     ToolTip.text: "Vehicle Type"

            //     MouseArea {
            //         id: vehicleName
            //         anchors.fill: parent
            //         hoverEnabled: true
            //     }
            // }
        }
    }
}

