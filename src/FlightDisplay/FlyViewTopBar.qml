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
    width: ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth * 30 : ScreenTools.defaultFontPixelWidth * 115
    height: ScreenTools.isMobile ? ScreenTools.defaultFontPixelHeight - 12 : ScreenTools.defaultFontPixelHeight * 2

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
        width: ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth * 47 : ScreenTools.defaultFontPixelWidth * 115
        height: ScreenTools.isMobile ? ScreenTools.defaultFontPixelHeight + 15 : ScreenTools.defaultFontPixelHeight * 2
        //color: /*"#66FFFFFF"*/ "#8B0000"
        color: "#77800000"
        radius: ScreenTools.isMobile ? 10 : height - 30
        border.width: 2
        border.color: "orange"
        //opacity: 0.5

        RowLayout {
            id: widgetLayout
            anchors.fill: parent
            spacing: 0

            Loader {
                id: messageIndicatorLoader
                Layout.leftMargin: 12
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.preferredWidth: ScreenTools.isMobile ? 120 : 65
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
                Layout.leftMargin: ScreenTools.isMobile? 20 : 12
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Layout.preferredWidth: ScreenTools.isMobile ? 145 : 75
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
                Layout.preferredWidth: 150
                Layout.fillWidth:  true
                Layout.leftMargin: ScreenTools.isMobile ? 45 : 15
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
                    width: ScreenTools.isMobile? 200 : 160
                    Layout.alignment: Qt.AlignVCenter
                    height: parent.height

                    QGCLabel {
                        id: modeLabel
                        anchors.centerIn: parent
                        text: activeVehicle ? activeVehicle.flightMode : qsTr("GUIDED_NOGPS")
                        color: "white"
                        font.bold: true
                        font.pointSize: ScreenTools.isMobile ? 8 : 11
                        //font.pointSize: 11
                        //font.family: "Times New Roman"

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

            QGCLabel {
                text: _activeVehicle ? /*_activeVehicle.firmwareTypeString + " - " +*/ _activeVehicle.vehicleTypeString
                                     : qsTr("No Vehicle")
                color: "white"
                font.bold: true
                //font.family: "Times New Roman"
                font.capitalization: Font.AllUppercase
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                font.pointSize: ScreenTools.isMobile ? 8 : 10
                //font.pointSize: 10

                ToolTip.visible: vehicleName.containsMouse
                ToolTip.text: "Vehicle Type"

                MouseArea {
                    id: vehicleName
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }
        }
    }
}

