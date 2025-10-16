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

Rectangle {
    id: root
    width: ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth * 21 : ScreenTools.defaultFontPixelWidth * 48
    height: mainLayout.height + 20
    color:  /*Qt.rgba(0.2, 0.4, 0.8, 0.65)*/ "#66800000"
    radius: 10
    border.color: "orange"
    border.width: 2

    property var    activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle

    QGCPalette {
        id: defaultPalette
        colorGroupEnabled: true
    }

    ColumnLayout {
        id: mainLayout
        anchors.centerIn: parent
        spacing: 7
        RowLayout {
            id: firstLayout
            Layout.alignment: Qt.AlignHCenter
            spacing: 12

            RowLayout {
                QGCLabel {
                    text: qsTr("Roll  ")
                    color: "white"
                    font.bold: true
                    font.pointSize: ScreenTools.isMobile ? 6.5 : 9
                }

                QGCLabel {
                    Layout.preferredWidth: 15
                    text: (_activeVehicle && _activeVehicle.roll)
                          ? _activeVehicle.roll.valueString
                          : "N/A"
                    font.bold: true
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: ScreenTools.isMobile ? 6.5 : 9
                }

                QGCLabel {
                    text: "deg"
                    color: "white"
                    font.bold: true
                    font.pointSize: ScreenTools.isMobile ? 6.5 : 9
                }
            }

            Rectangle {
                width: 1
                Layout.fillHeight: true
                color: "white"
            }

            RowLayout {
                QGCLabel {
                    text: qsTr("Pitch  ")
                    color: "white"
                    font.bold: true
                    font.pointSize: ScreenTools.isMobile ? 6.5 : 9
                }

                QGCLabel {
                    Layout.preferredWidth: 15
                    text: (_activeVehicle && _activeVehicle.pitch)
                          ? _activeVehicle.pitch.valueString
                          : "N/A"
                    font.bold: true
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: ScreenTools.isMobile ? 6.5 : 9
                }

                QGCLabel {
                    text: " deg"
                    color: "white"
                    font.bold: true
                    font.pointSize: ScreenTools.isMobile ? 6.5 : 9
                }
            }

            Rectangle {
                width: 1
                Layout.fillHeight: true
                color: "white"
            }

            RowLayout {
                QGCLabel {
                    text: qsTr("Yaw")
                    color: "white"
                    font.bold: true
                    font.pointSize: ScreenTools.isMobile ? 6.5 : 9
                }

                QGCLabel {
                    Layout.preferredWidth: 15
                    text: (_activeVehicle && _activeVehicle.yawRate)
                          ? _activeVehicle.yawRate.valueString
                          : "N/A"
                    font.bold: true
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: ScreenTools.isMobile ? 6.5 : 9
                }

                QGCLabel {
                    text: "deg"
                    color: "white"
                    font.bold: true
                    font.pointSize: ScreenTools.isMobile ? 6.5 : 9
                }
            }
        }

        RowLayout {
            id: mainSpeedLayout
            Layout.alignment: Qt.AlignHCenter
            spacing: 15

            RowLayout {

                QGCLabel {
                    text: qsTr("Air Speed")
                    color: /*qgcPal.text*/ "white"
                    font.bold: true
                    font.pointSize: ScreenTools.isMobile ? 6.5 : 9
                }

                QGCLabel {
                    Layout.preferredWidth: 20
                    text: (_activeVehicle && _activeVehicle.airSpeed)
                          ? _activeVehicle.airSpeed.valueString
                          : "N/A"
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: ScreenTools.isMobile ? 6.5 : 9
                }

                QGCLabel {
                    text: "m/s"
                    color: "white"
                    font.bold: true
                    font.pointSize: ScreenTools.isMobile ? 6.5 : 9
                }
            }

            Rectangle {
                width: 1
                Layout.fillHeight: true
                color: "white"
            }

            RowLayout {
                QGCLabel {
                    text: qsTr("Ground Speed")
                    color: "white"
                    font.bold: true
                    font.pointSize: ScreenTools.isMobile ? 6.5 : 9
                }

                QGCLabel {
                    Layout.preferredWidth: 20
                    text: (_activeVehicle && _activeVehicle.groundSpeed)
                            ? _activeVehicle.groundSpeed.valueString : "N/A"
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: ScreenTools.isMobile ? 6.5 : 9
                }

                QGCLabel {
                    text: "m/s"
                    color: "white"
                    font.bold: true
                    font.pointSize: ScreenTools.isMobile ? 6.5 : 9
                }
            }
        }

        Rectangle {
            id: dividerLine
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.preferredHeight: 2
            color: "white"
            opacity: 0.5
        }

        GridLayout {
            id: infoTable
            Layout.alignment: Qt.AlignHCenter
            columns: 2
            rowSpacing: -1
            columnSpacing: -1
            width: root.width * 0.95

            // Row 1
            Rectangle {
                width: infoTable.width / 2
                height: 50
                border.color: Qt.rgba(1, 1, 1, 0.3)
                border.width: 0.5
                color: "transparent"

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 0
                    QGCLabel {
                        text: qsTr("Alt Rel (m)")
                        font.bold: true
                        color: "white"
                        Layout.alignment: Qt.AlignHCenter
                        font.pointSize: ScreenTools.isMobile ? 5.5 : 9
                    }
                    QGCLabel {
                        text: (_activeVehicle && _activeVehicle.altitudeRelative)
                                ? _activeVehicle.altitudeRelative.valueString : "N/A"
                        //font.pointSize: 12
                        font.bold: true
                        color: "white"
                        Layout.alignment: Qt.AlignHCenter
                        font.pointSize: ScreenTools.isMobile ? 5.8 : 11
                    }
                }
            }

            Rectangle {
                width: infoTable.width / 2
                height: 50
                border.color: Qt.rgba(1, 1, 1, 0.3)
                border.width: 0.5
                color: "transparent"

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 0
                    QGCLabel {
                        text: qsTr("Climb Rate (m)")
                        font.bold: true
                        color: "white"
                        Layout.alignment: Qt.AlignHCenter
                        font.pointSize: ScreenTools.isMobile ? 5.5 : 9
                    }
                    QGCLabel {
                        text: (_activeVehicle && _activeVehicle.climbRate)
                                ? _activeVehicle.climbRate.valueString : "N/A"
                        font.bold: true
                        color: "white"
                        Layout.alignment: Qt.AlignHCenter
                        font.pointSize: ScreenTools.isMobile ? 5.8 : 11
                    }
                }
            }

            // Row 2
            Rectangle {
                width: infoTable.width / 2
                height: 50
                border.color: Qt.rgba(1, 1, 1, 0.3)
                border.width: 0.5
                color: "transparent"

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 0
                    QGCLabel {
                        text: qsTr("Flight Distance (m)")
                        font.bold: true
                        color: "white"
                        Layout.alignment: Qt.AlignHCenter
                        font.pointSize: ScreenTools.isMobile ? 5.5 : 9
                    }
                    QGCLabel {
                        text: (_activeVehicle && _activeVehicle.flightDistance)
                                ? _activeVehicle.flightDistance.valueString : "N/A"
                        //font.pointSize: 12
                        font.bold: true
                        color: "white"
                        Layout.alignment: Qt.AlignHCenter
                        font.pointSize: ScreenTools.isMobile ? 6.5 : 11
                    }
                }
            }

            Rectangle {
                width: infoTable.width / 2
                height: 50
                border.color: Qt.rgba(1, 1, 1, 0.3)
                border.width: 0.5
                color: "transparent"

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 0
                    QGCLabel {
                        text: qsTr("Flight Time (sec)")
                        font.bold: true
                        color: "white"
                        Layout.alignment: Qt.AlignHCenter
                        font.pointSize: ScreenTools.isMobile ? 5.5 : 9
                    }
                    QGCLabel {
                        Layout.alignment: Qt.AlignHCenter
                        color: "white"
                        text: QGroundControl.multiVehicleManager.activeVehicle ?
                              QGroundControl.multiVehicleManager.activeVehicle.flightTime.valueString : "N/A"
                        //font.pointSize: 12
                        font.bold: true
                        font.pointSize: ScreenTools.isMobile ? 5.8 : 11
                    }
                }
            }
        }

        QGCLabel {
            id: batteryDetails
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("BATTERY PROFILE")
            font.bold: true
            color: "yellow"
            font.pointSize: ScreenTools.isMobile ? 5.8 : 9
        }

        GridLayout {
            id: batteryLayout
            Layout.alignment: Qt.AlignHCenter
            columns: 2
            rowSpacing: -1
            columnSpacing: -1
            width: root.width * 0.95

            Rectangle {
                width: batteryLayout.width / 2
                height: 50
                border.color: Qt.rgba(1, 1, 1, 0.3)
                border.width: 0.5
                color: "transparent"

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 0
                    QGCLabel {
                        text: qsTr("Battery Current (Amp)")
                        font.bold: true
                        color: "white"
                        Layout.alignment: Qt.AlignHCenter
                        font.pointSize: ScreenTools.isMobile ? 5.5 : 9
                    }

                    QGCLabel {
                        Layout.alignment: Qt.AlignHCenter
                        color: "white"
                        text: (_activeVehicle && _activeVehicle.batteries && _activeVehicle.batteries.count > 0
                                && _activeVehicle.batteries.get(0))
                              ? _activeVehicle.batteries.get(0).current.valueString
                              : "N/A"
                        font.bold: true
                        font.pointSize: ScreenTools.isMobile ? 5.8 : 11
                    }
                }
            }

            Rectangle {
                width: batteryLayout.width / 2
                height: 50
                border.color: Qt.rgba(1, 1, 1, 0.3)
                border.width: 0.5
                color: "transparent"

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 0
                    QGCLabel {
                        text: qsTr("Battery Voltage (Vol)")
                        font.bold: true
                        color: "white"
                        Layout.alignment: Qt.AlignHCenter
                        font.pointSize: ScreenTools.isMobile ? 5.5 : 9
                    }

                    QGCLabel {
                        Layout.alignment: Qt.AlignHCenter
                        color: "white"
                        text: (_activeVehicle && _activeVehicle.batteries && _activeVehicle.batteries.count > 0
                                && _activeVehicle.batteries.get(0))
                              ? _activeVehicle.batteries.get(0).voltage.valueString
                              : "N/A"
                        font.bold: true
                        font.pointSize: ScreenTools.isMobile ? 5.8 : 11
                    }
                }
            }
        }

        QGCLabel {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("OTHER PROFILES")
            color: "yellow"
            font.bold: true
            font.pointSize: ScreenTools.isMobile ? 5.8 : 9
            visible: (
                // (activeVehicle && activeVehicle.rcRSSI !== undefined && activeVehicle.rcRSSI > 0) ||
                (activeVehicle && activeVehicle.rcRSSI !== undefined && activeVehicle.rcRSSI > 0 && activeVehicle.rcRSSI < 100) ||
                (activeVehicle && activeVehicle.gimbalAvailable) ||
                (activeVehicle && activeVehicle.remoteIDAvailable) ||
                (activeVehicle && activeVehicle.telemetryLRSSI !== undefined && activeVehicle.telemetryLRSSI > 0))
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: parent.width * 0.95
            height: 50
            border.color: Qt.rgba(1, 1, 1, 0.3)
            border.width: 0.5
            color: "transparent"
            visible: (
                // (activeVehicle && activeVehicle.rcRSSI !== undefined && activeVehicle.rcRSSI > 0) ||
                (activeVehicle && activeVehicle.rcRSSI !== undefined && activeVehicle.rcRSSI > 0 && activeVehicle.rcRSSI < 100) ||
                (activeVehicle && activeVehicle.gimbalAvailable) ||
                (activeVehicle && activeVehicle.remoteIDAvailable) ||
                (activeVehicle && activeVehicle.telemetryLRSSI !== undefined && activeVehicle.telemetryLRSSI > 0))


            Row {
                anchors.fill: parent
                spacing: 0

                Rectangle {
                    width: parent.width / 5
                    height: parent.height
                    color: "transparent"
                    //visible: activeVehicle && activeVehicle.rcRSSI && activeVehicle.rcRSSI > 0

                    Item {
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height

                        Loader {
                            id: rcRssiLoader
                            //source: "qrc:/toolbar/RCRSSIIndicator.qml"
                            //active: true
                            anchors.centerIn: parent
                            width: parent.width * 0.6
                            height: parent.height * 0.6
                            source: "qrc:/toolbar/RCRSSIIndicator.qml"
                        }
                    }
                }

                Rectangle {
                    width: 1
                    color: "gray"
                    Layout.fillHeight: true
                }

                Rectangle {
                    width: parent.width / 2.3
                    height: parent.height
                    color: "transparent"

                    Item {
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height

                        Loader {
                            id: gimbalLoader
                            source: (activeVehicle && activeVehicle.gimbalAvailable) ? "qrc:/toolbar/GimbalIndicator.qml" : ""
                            //source: "qrc:/toolbar/GimbalIndicator.qml"
                            //active: true
                            anchors.centerIn: parent
                            width: parent.width * 0.6
                            height: parent.height * 0.6
                        }
                    }
                }

                Rectangle {
                    width: 1
                    color: "gray"
                    Layout.fillHeight: true
                }

                Rectangle {
                    width: parent.width / 6
                    height: parent.height
                    color: "transparent"

                    Item {
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height

                        Loader {
                            id: remoteIdLoader
                            source: (activeVehicle && activeVehicle.remoteIDAvailable) ? "qrc:/toolbar/RemoteIDIndicator.qml" : ""
                            //source: "qrc:/toolbar/RemoteIDIndicator.qml"
                            //active: true
                            anchors.centerIn: parent
                            width: parent.width * 0.6
                            height: parent.height * 0.6
                        }
                    }
                }

                Rectangle {
                    width: 1
                    color: "blue"
                    Layout.fillHeight: true
                }

                Rectangle {
                    width: parent.width / 6
                    height: parent.height
                    color: "transparent"

                    Item {
                        anchors.centerIn: parent
                        width: parent.width
                        height: parent.height

                        Loader {
                            id: telemLoader
                            anchors.centerIn: parent
                            width: parent.width * 0.6
                            height: parent.height * 0.6
                            source: (activeVehicle && activeVehicle.telemetryLRSSI > 0) ? "qrc:/toolbar/TelemetryRSSIIndicator.qml" : ""
                        }
                    }
                }
            }
        }
    }
}
