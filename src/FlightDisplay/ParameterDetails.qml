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
    color:  qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(1, 1, 1, 0.5) : Qt.rgba(0, 0, 0, 0.5)
    radius: ScreenTools.defaultFontPixelHeight / 2

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
                    font.bold: true
                    font.pointSize: ScreenTools.isMobile ? 6.5 : 9
                }

                QGCLabel {
                    Layout.preferredWidth: 15
                    text: (_activeVehicle && _activeVehicle.roll)
                          ? _activeVehicle.roll.valueString
                          : "N/A"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: ScreenTools.isMobile ? 6.5 : 9
                }

                QGCLabel {
                    text: "deg"
                    font.bold: true
                    font.pointSize: ScreenTools.isMobile ? 6.5 : 9
                }
            }

            Rectangle {
                width: 1
                Layout.fillHeight: true
                color: "gray"
            }

            RowLayout {
                QGCLabel {
                    text: qsTr("Pitch  ")
                    font.bold: true
                    font.pointSize: ScreenTools.isMobile ? 6.5 : 9
                }

                QGCLabel {
                    Layout.preferredWidth: 15
                    text: (_activeVehicle && _activeVehicle.pitch)
                          ? _activeVehicle.pitch.valueString
                          : "N/A"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: ScreenTools.isMobile ? 6.5 : 9
                }

                QGCLabel {
                    text: " deg"
                    font.bold: true
                    font.pointSize: ScreenTools.isMobile ? 6.5 : 9
                }
            }

            Rectangle {
                width: 1
                Layout.fillHeight: true
                color: "gray"
            }

            RowLayout {
                QGCLabel {
                    text: qsTr("Yaw")
                    font.bold: true
                    font.pointSize: ScreenTools.isMobile ? 6.5 : 9
                }

                QGCLabel {
                    Layout.preferredWidth: 15
                    text: (_activeVehicle && _activeVehicle.yawRate)
                          ? _activeVehicle.yawRate.valueString
                          : "N/A"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: ScreenTools.isMobile ? 6.5 : 9
                }

                QGCLabel {
                    text: "deg"
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
                    font.bold: true
                    font.pointSize: ScreenTools.isMobile ? 6.5 : 9
                }

                QGCLabel {
                    Layout.preferredWidth: 20
                    text: (_activeVehicle && _activeVehicle.airSpeed)
                          ? _activeVehicle.airSpeed.valueString
                          : "N/A"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: ScreenTools.isMobile ? 6.5 : 9
                }

                QGCLabel {
                    text: "m/s"
                    font.bold: true
                    font.pointSize: ScreenTools.isMobile ? 6.5 : 9
                }
            }

            Rectangle {
                width: 1
                Layout.fillHeight: true
                color: "gray"
            }

            RowLayout {
                QGCLabel {
                    text: qsTr("Ground Speed")
                    font.bold: true
                    font.pointSize: ScreenTools.isMobile ? 6.5 : 9
                }

                QGCLabel {
                    Layout.preferredWidth: 20
                    text: (_activeVehicle && _activeVehicle.groundSpeed)
                            ? _activeVehicle.groundSpeed.valueString : "N/A"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: ScreenTools.isMobile ? 6.5 : 9
                }

                QGCLabel {
                    text: "m/s"
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
            color: "gray"
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
                border.color: "gray"
                border.width: 0.5
                color: "transparent"

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 0
                    QGCLabel {
                        text: qsTr("Alt Rel (m)")
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                        font.pointSize: ScreenTools.isMobile ? 5.5 : 9
                    }
                    QGCLabel {
                        text: (_activeVehicle && _activeVehicle.altitudeRelative)
                                ? _activeVehicle.altitudeRelative.valueString : "N/A"
                        //font.pointSize: 12
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                        font.pointSize: ScreenTools.isMobile ? 5.8 : 11
                    }
                }
            }

            Rectangle {
                width: infoTable.width / 2
                height: 50
                border.color: "gray"
                border.width: 0.5
                color: "transparent"

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 0
                    QGCLabel {
                        text: qsTr("Climb Rate (m)")
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                        font.pointSize: ScreenTools.isMobile ? 5.5 : 9
                    }
                    QGCLabel {
                        text: (_activeVehicle && _activeVehicle.climbRate)
                                ? _activeVehicle.climbRate.valueString : "N/A"
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                        font.pointSize: ScreenTools.isMobile ? 5.8 : 11
                    }
                }
            }

            // Row 2
            Rectangle {
                width: infoTable.width / 2
                height: 50
                border.color: "gray"
                border.width: 0.5
                color: "transparent"

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 0
                    QGCLabel {
                        text: qsTr("Flight Distance (m)")
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                        font.pointSize: ScreenTools.isMobile ? 5.5 : 9
                    }
                    QGCLabel {
                        text: (_activeVehicle && _activeVehicle.flightDistance)
                                ? _activeVehicle.flightDistance.valueString : "N/A"
                        //font.pointSize: 12
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                        font.pointSize: ScreenTools.isMobile ? 6.5 : 11
                    }
                }
            }

            Rectangle {
                width: infoTable.width / 2
                height: 50
                border.color: "gray"
                border.width: 0.5
                color: "transparent"

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 0
                    QGCLabel {
                        text: qsTr("Flight Time (sec)")
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                        font.pointSize: ScreenTools.isMobile ? 5.5 : 9
                    }
                    QGCLabel {
                        Layout.alignment: Qt.AlignHCenter
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
                border.color: "gray"
                border.width: 0.5
                color: "transparent"

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 0
                    QGCLabel {
                        text: qsTr("Battery Current (Amp)")
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                        font.pointSize: ScreenTools.isMobile ? 5.5 : 9
                    }

                    QGCLabel {
                        Layout.alignment: Qt.AlignHCenter
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
                border.color: "gray"
                border.width: 0.5
                color: "transparent"

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 0
                    QGCLabel {
                        text: qsTr("Battery Voltage (Vol)")
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                        font.pointSize: ScreenTools.isMobile ? 5.5 : 9
                    }

                    QGCLabel {
                        Layout.alignment: Qt.AlignHCenter
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
            font.bold: true
            font.pointSize: ScreenTools.isMobile ? 5.8 : 9
            // visible: (
            //     // (activeVehicle && activeVehicle.rcRSSI !== undefined && activeVehicle.rcRSSI > 0) ||
            //     (activeVehicle && activeVehicle .rcRSSI !== undefined && activeVehicle.rcRSSI > 0 && activeVehicle.rcRSSI < 100) ||
            //     (activeVehicle && activeVehicle.gimbalAvailable) ||
            //     (activeVehicle && activeVehicle.remoteIDAvailable) ||
            //     (activeVehicle && activeVehicle.telemetryLRSSI !== undefined && activeVehicle.telemetryLRSSI > 0))
        }

        RowLayout {
            spacing: ScreenTools.defaultFontPixelWidth
            Rectangle {
                id: rcRssiRect
                implicitWidth: rcRssiLoader.status === Loader.Ready ? rcRssiLoader.width + ScreenTools.defaultFontPixelWidth : 60
                height: 30
                color: "transparent"
                //visible: activeVehicle && activeVehicle.rcRSSI && activeVehicle.rcRSSI > 0

                Loader {
                    id: rcRssiLoader
                    anchors.fill: parent
                    source: "qrc:/toolbar/RCRSSIIndicator.qml"
                }
            }

            Rectangle {
                id: gimbalRect
                implicitWidth: gimbalLoader.status === Loader.Ready ? gimbalLoader.width + ScreenTools.defaultFontPixelWidth : 60
                height: 30
                color: "transparent"

                Loader {
                    id: gimbalLoader
                    anchors.fill: parent
                    source: /*(activeVehicle && activeVehicle.gimbalAvailable) ?*/ "qrc:/toolbar/GimbalIndicator.qml" /*: ""*/
                }
            }

            Rectangle {
                id: remoteIdRect
                implicitWidth: remoteIdLoader.status === Loader.Ready ? remoteIdLoader.width + ScreenTools.defaultFontPixelWidth : 60
                height: 30
                color: "transparent"

                Loader {
                    id: remoteIdLoader
                    anchors.fill: parent
                    source: /*(activeVehicle && activeVehicle.remoteIDAvailable) ?*/ "qrc:/toolbar/RemoteIDIndicator.qml" /*: ""*/
                }
            }

            Rectangle {
                id: telemRssiRect
                implicitWidth: telemRssiLoader.status === Loader.Ready ? telemRssiLoader.width + ScreenTools.defaultFontPixelWidth : 20
                height: 30
                color: "transparent"

                Loader {
                    id: telemRssiLoader
                    anchors.fill: parent
                    source: /*(activeVehicle && activeVehicle.telemetryLRSSI > 0) ?*/ "qrc:/toolbar/TelemetryRSSIIndicator.qml" /*: ""*/
                }
            }
        }
    }
}
