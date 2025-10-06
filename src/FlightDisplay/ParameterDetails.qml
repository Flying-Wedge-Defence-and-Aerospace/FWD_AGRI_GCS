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
    width: 290
    height: mainLayout.height + 20
    color:  Qt.rgba(0.2, 0.4, 0.8, 0.65)
    radius: 20
    border.color: "yellow"
    border.width: 1

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
            Layout.alignment: Qt.AlignHCenter/* && Qt.AlignVCenter*/
            // anchors.horizontalCenter: parent.horizontalCenter
            // anchors.top: parent.top
            // anchors.topMargin: 10
            spacing: 12

            RowLayout {
                QGCLabel {
                    text: qsTr("Roll  ")
                    color: "black"
                    font.bold: true
                }

                QGCLabel {
                    Layout.preferredWidth: 15
                    text: (_activeVehicle && _activeVehicle.roll)
                          ? _activeVehicle.roll.valueString
                          : "N/A"
                    font.bold: true
                    color: "black"
                    horizontalAlignment: Text.AlignHCenter
                }

                QGCLabel {
                    text: "deg"
                    color: "black"
                    font.bold: true
                }
            }

            Rectangle {
                width: 1
                Layout.fillHeight: true
                color: "black"
            }

            RowLayout {
                QGCLabel {
                    text: qsTr("Pitch  ")
                    color: "black"
                    font.bold: true
                }

                QGCLabel {
                    Layout.preferredWidth: 15
                    text: (_activeVehicle && _activeVehicle.pitch)
                          ? _activeVehicle.pitch.valueString
                          : "N/A"
                    font.bold: true
                    color: "black"
                    horizontalAlignment: Text.AlignHCenter
                }

                QGCLabel {
                    text: " deg"
                    color: "black"
                    font.bold: true
                }
            }

            Rectangle {
                width: 1
                Layout.fillHeight: true
                color: "black"
            }

            RowLayout {
                QGCLabel {
                    text: qsTr("Yaw")
                    color: "black"
                    font.bold: true
                }

                QGCLabel {
                    Layout.preferredWidth: 15
                    text: (_activeVehicle && _activeVehicle.yawRate)
                          ? _activeVehicle.yawRate.valueString
                          : "N/A"
                    font.bold: true
                    color: "black"
                    horizontalAlignment: Text.AlignHCenter
                }

                QGCLabel {
                    text: "deg"
                    color: "black"
                    font.bold: true
                }
            }
        }

        RowLayout {
            id: mainSpeedLayout
            Layout.alignment: Qt.AlignHCenter/* && Qt.AlignVCenter*/
            // anchors.horizontalCenter: parent.horizontalCenter
            // anchors.top: firstLayout.bottom
            // anchors.topMargin: 7
            spacing: 15

            RowLayout {

                QGCLabel {
                    text: qsTr("Air Speed")
                    //font.pixelSize: ScreenTools.defaultFontPixelHeight
                    color: /*qgcPal.text*/ "black"
                    font.bold: true
                }

                QGCLabel {
                    Layout.preferredWidth: 20
                    text: (_activeVehicle && _activeVehicle.airSpeed)
                          ? _activeVehicle.airSpeed.valueString
                          : "N/A"
                    color: "black"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }

                QGCLabel {
                    text: "m/s"
                    color: "black"
                    font.bold: true
                }
            }

            Rectangle {
                width: 1
                Layout.fillHeight: true
                color: "black"
            }

            RowLayout {
                QGCLabel {
                    text: qsTr("Ground Speed")
                    color: "black"
                    font.bold: true
                }

                QGCLabel {
                    Layout.preferredWidth: 20
                    text: (_activeVehicle && _activeVehicle.groundSpeed)
                            ? _activeVehicle.groundSpeed.valueString : "N/A"
                    color: "black"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                }

                QGCLabel {
                    text: "m/s"
                    color: "black"
                    font.bold: true
                }
            }
        }

        Rectangle {
            id: dividerLine
            Layout.alignment: Qt.AlignHCenter
            // anchors.top: mainSpeedLayout.bottom
            // anchors.topMargin: 10
            // anchors.horizontalCenter: parent.horizontalCenter
            Layout.fillWidth: true
            Layout.preferredHeight: 2
            color: "white"
            opacity: 0.5
        }

        GridLayout {
            id: infoTable
            Layout.alignment: Qt.AlignHCenter
            // anchors.top: dividerLine.bottom
            // anchors.topMargin: 10
            // anchors.horizontalCenter: parent.horizontalCenter
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
                    QGCLabel {
                        //Layout.horizontalCenter: parent.horizontalCenter
                        text: qsTr("Alt Rel (m)")
                        font.bold: true
                        color: "black"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    QGCLabel {
                       // Layout.horizontalCenter: parent.horizontalCenter
                        text: (_activeVehicle && _activeVehicle.altitudeRelative)
                                ? _activeVehicle.altitudeRelative.valueString : "N/A"
                        font.pointSize: 12
                        font.bold: true
                        color: "black"
                        Layout.alignment: Qt.AlignHCenter
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
                    QGCLabel {
                        //Layout.horizontalCenter: parent.horizontalCenter
                        text: qsTr("Climb Rate (m)")
                        font.bold: true
                        color: "black"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    QGCLabel {
                       // Layout.horizontalCenter: parent.horizontalCenter
                        text: (_activeVehicle && _activeVehicle.climbRate)
                                ? _activeVehicle.climbRate.valueString : "N/A"
                        font.pointSize: 12
                        font.bold: true
                        color: "black"
                        Layout.alignment: Qt.AlignHCenter
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
                    QGCLabel {
                        //Layout.horizontalCenter: parent.horizontalCenter
                        text: qsTr("Flight Distance (m)")
                        font.bold: true
                        color: "black"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    QGCLabel {
                       // Layout.horizontalCenter: parent.horizontalCenter
                        text: (_activeVehicle && _activeVehicle.flightDistance)
                                ? _activeVehicle.flightDistance.valueString : "N/A"
                        font.pointSize: 12
                        font.bold: true
                        color: "black"
                        Layout.alignment: Qt.AlignHCenter
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
                    QGCLabel {
                        //Layout.horizontalCenter: parent.horizontalCenter
                        text: qsTr("Flight Time (sec)")
                        font.bold: true
                        color: "black"
                        Layout.alignment: Qt.AlignHCenter
                    }
                    QGCLabel {
                        Layout.alignment: Qt.AlignHCenter
                        color: "black"
                        text: QGroundControl.multiVehicleManager.activeVehicle ?
                              QGroundControl.multiVehicleManager.activeVehicle.flightTime.valueString : "N/A"
                        font.pointSize: 12
                        font.bold: true
                    }
                }
            }
        }

        QGCLabel {
            id: batteryDetails
            Layout.alignment: Qt.AlignHCenter
            // anchors.top: infoTable.bottom
            // anchors.topMargin: 10
            // anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("BATTERY PROFILE")
            font.bold: true
            color: "yellow"
        }

        GridLayout {
            id: batteryLayout
            Layout.alignment: Qt.AlignHCenter
            // anchors.top: batteryDetails.bottom
            // anchors.topMargin: 5
            // anchors.horizontalCenter: parent.horizontalCenter
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
                    QGCLabel {
                        //Layout.horizontalCenter: parent.horizontalCenter
                        text: qsTr("Battery Current (Amp)")
                        font.bold: true
                        color: "black"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    QGCLabel {
                        Layout.alignment: Qt.AlignHCenter
                        color: "black"
                        text: (_activeVehicle && _activeVehicle.batteries && _activeVehicle.batteries.count > 0
                                && _activeVehicle.batteries.get(0))
                              ? _activeVehicle.batteries.get(0).current.valueString
                              : "N/A"
                        font.pointSize: 12
                        font.bold: true
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
                    QGCLabel {
                        //Layout.horizontalCenter: parent.horizontalCenter
                        text: qsTr("Battery Voltage (Vol)")
                        font.bold: true
                        color: "black"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    QGCLabel {
                        Layout.alignment: Qt.AlignHCenter
                        color: "black"
                        text: (_activeVehicle && _activeVehicle.batteries && _activeVehicle.batteries.count > 0
                                && _activeVehicle.batteries.get(0))
                              ? _activeVehicle.batteries.get(0).voltage.valueString
                              : "N/A"
                        font.pointSize: 12
                        font.bold: true
                    }
                }
            }
        }

        QGCLabel {
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("OTHER PROFILES")
            color: "yellow"
            font.bold: true
            visible: (
                // (activeVehicle && activeVehicle.rcRSSI !== undefined && activeVehicle.rcRSSI > 0) ||
                (activeVehicle && activeVehicle.rcRSSI !== undefined && activeVehicle.rcRSSI > 0 && activeVehicle.rcRSSI < 100) ||
                (activeVehicle && activeVehicle.gimbalAvailable) ||
                (activeVehicle && activeVehicle.remoteIDAvailable) ||
                (activeVehicle && activeVehicle.telemetryLRSSI !== undefined && activeVehicle.telemetryLRSSI > 0))
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            // anchors.top: batteryLayout.bottom
            // anchors.topMargin: 15
            // anchors.horizontalCenter: parent.horizontalCenter
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
                    visible: activeVehicle && activeVehicle.rcRSSI && activeVehicle.rcRSSI > 0

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
                        width: parent.widths
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

                        // Loader {
                        //     id: telemLoader
                        //     source: "qrc:/toolbar/TelemetryRSSIIndicator.qml"
                        //     active: _activeVehicle && _activeVehicle.telemetryLRSSI !== undefined
                        //     visible: _activeVehicle && _activeVehicle.telemetryLRSSI !== undefined
                        //     //active: true
                        //     anchors.centerIn: parent
                        //     width: parent.width * 0.6
                        //     height: parent.height * 0.6
                        // }

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




// import QtQuick                  2.12
// import QtQuick.Controls         2.15
// import QtQuick.Dialogs          1.3
// import QtQuick.Layouts          1.12

// import QtLocation               5.3
// import QtPositioning            5.3
// import QtQuick.Window           2.2
// import QtQml.Models             2.1

// import QtGraphicalEffects 1.0

// import QGroundControl               1.0
// import QGroundControl.MultiVehicleManager   1.0
// import QGroundControl.Controllers   1.0
// import QGroundControl.Controls      1.0
// import QGroundControl.FactSystem    1.0
// import QGroundControl.FlightDisplay 1.0
// import QGroundControl.FlightMap     1.0
// import QGroundControl.Palette       1.0
// import QGroundControl.ScreenTools   1.0
// import QGroundControl.Vehicle       1.0

// Rectangle {
//     id: root
//     width: 290
//     height: 270
//     color:  Qt.rgba(0.2, 0.4, 0.8, 0.65)
//     radius: 20

//     property var    activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle

    // QGCPalette {
    //     id: defaultPalette
    //     colorGroupEnabled: true
    // }

    // RowLayout {
    //     id: firstLayout
    //     anchors.horizontalCenter: parent.horizontalCenter
    //     anchors.top: parent.top
    //     anchors.topMargin: 10
    //     spacing: 12

    //     RowLayout {
    //         QGCLabel {
    //             text: qsTr("Roll  ")
    //             color: "black"
    //             font.bold: true
    //         }

    //         QGCLabel {
    //             Layout.preferredWidth: 15
    //             text: (_activeVehicle && _activeVehicle.roll)
    //                   ? _activeVehicle.roll.valueString
    //                   : "N/A"
    //             font.bold: true
    //             color: "black"
    //             horizontalAlignment: Text.AlignHCenter
    //         }

    //         QGCLabel {
    //             text: "deg"
    //             color: "black"
    //             font.bold: true
    //         }
    //     }

    //     RowLayout {
    //         QGCLabel {
    //             text: qsTr("Pitch")
    //             color: "black"
    //             font.bold: true
    //         }

    //         QGCLabel {
    //             Layout.preferredWidth: 15
    //             text: (_activeVehicle && _activeVehicle.pitch)
    //                   ? _activeVehicle.pitch.valueString
    //                   : "N/A"
    //             font.bold: true
    //             color: "black"
    //             horizontalAlignment: Text.AlignHCenter
    //         }

    //         QGCLabel {
    //             text: "deg"
    //             color: "black"
    //             font.bold: true
    //         }
    //     }

    //     RowLayout {
    //         QGCLabel {
    //             text: qsTr("Yaw")
    //             color: "black"
    //             font.bold: true
    //         }

    //         QGCLabel {
    //             Layout.preferredWidth: 15
    //             text: (_activeVehicle && _activeVehicle.yawRate)
    //                   ? _activeVehicle.yawRate.valueString
    //                   : "N/A"
    //             font.bold: true
    //             color: "black"
    //             horizontalAlignment: Text.AlignHCenter
    //         }

    //         QGCLabel {
    //             text: "deg"
    //             color: "black"
    //             font.bold: true
    //         }
    //     }
    // }


    // RowLayout {
    //     id: mainSpeedLayout
    //     anchors.horizontalCenter: parent.horizontalCenter
    //     anchors.top: firstLayout.bottom
    //     anchors.topMargin: 7
    //     spacing: 25

    //     RowLayout {

    //         QGCLabel {
    //             text: qsTr("Air Speed")
    //             //font.pixelSize: ScreenTools.defaultFontPixelHeight
    //             color: /*qgcPal.text*/ "black"
    //             font.bold: true
    //         }

    //         QGCLabel {
    //             Layout.preferredWidth: 20
    //             text: (_activeVehicle && _activeVehicle.airSpeed)
    //                   ? _activeVehicle.airSpeed.valueString
    //                   : "N/A"
    //             color: "black"
    //             font.bold: true
    //             horizontalAlignment: Text.AlignHCenter
    //         }

    //         QGCLabel {
    //             text: "m/s"
    //             color: "black"
    //             font.bold: true
    //         }
    //     }

    //     RowLayout {
    //         QGCLabel {
    //             text: qsTr("Ground Speed")
    //             color: "black"
    //             font.bold: true
    //         }

    //         QGCLabel {
    //             Layout.preferredWidth: 20
    //             text: (_activeVehicle && _activeVehicle.groundSpeed)
    //                     ? _activeVehicle.groundSpeed.valueString : "N/A"
    //             color: "black"
    //             font.bold: true
    //             horizontalAlignment: Text.AlignHCenter
    //         }

    //         QGCLabel {
    //             text: "m/s"
    //             color: "black"
    //             font.bold: true
    //         }
    //     }
    // }

    // Rectangle {
    //     id: dividerLine
    //     anchors.top: mainSpeedLayout.bottom
    //     anchors.topMargin: 10
    //     anchors.horizontalCenter: parent.horizontalCenter
    //     width: parent.width * 0.95
    //     height: 2
    //     color: "white"
    //     opacity: 0.5
    // }

//     // GridLayout {
//     //     id: infoTable
//     //     anchors.top: dividerLine.bottom
//     //     anchors.topMargin: 10
//     //     anchors.horizontalCenter: parent.horizontalCenter
//     //     columns: 2
//     //     rowSpacing: 0
//     //     columnSpacing: 0
//     //     width: parent.width * 0.95

//     //     Repeater {
//     //         model: 8   // total cells (2x4)
//     //         delegate: Rectangle {
//     //             width: infoTable.width / 2
//     //             height: 50
//     //             border.width: 0.5
//     //             border.color: "white"
//     //             color: "transparent"

//     //             QGCLabel {
//     //                         anchors.centerIn: parent
//     //                         text: "Cell " + (index + 1)
//     //                         color: "white"
//     //                     }
//     //         }
//     //     }
//     // }

    // GridLayout {
    //     id: infoTable
    //     anchors.top: dividerLine.bottom
    //     anchors.topMargin: 10
    //     anchors.horizontalCenter: parent.horizontalCenter
    //     columns: 2
    //     rowSpacing: -1
    //     columnSpacing: -1
    //     width: parent.width * 0.95

    //     // Row 1
    //     Rectangle {
    //         width: infoTable.width / 2
    //         height: 50
    //         border.color: Qt.rgba(1, 1, 1, 0.3)
    //         border.width: 0.5
    //         color: "transparent"

    //         ColumnLayout {
    //             anchors.centerIn: parent
    //             QGCLabel {
    //                 //Layout.horizontalCenter: parent.horizontalCenter
    //                 text: qsTr("Alt Rel (m)")
    //                 font.bold: true
    //                 color: "black"
    //                 Layout.alignment: Qt.AlignHCenter
    //             }
    //             QGCLabel {
    //                // Layout.horizontalCenter: parent.horizontalCenter
    //                 text: (_activeVehicle && _activeVehicle.altitudeRelative)
    //                         ? _activeVehicle.altitudeRelative.valueString : "N/A"
    //                 font.bold: true
    //                 color: "black"
    //                 Layout.alignment: Qt.AlignHCenter
    //             }
    //         }
    //     }

    //     Rectangle {
    //         width: infoTable.width / 2
    //         height: 50
    //         border.color: Qt.rgba(1, 1, 1, 0.3)
    //         border.width: 0.5
    //         color: "transparent"

    //         ColumnLayout {
    //             anchors.centerIn: parent
    //             QGCLabel {
    //                 //Layout.horizontalCenter: parent.horizontalCenter
    //                 text: qsTr("Climb Rate (m)")
    //                 font.bold: true
    //                 color: "black"
    //                 Layout.alignment: Qt.AlignHCenter
    //             }
    //             QGCLabel {
    //                // Layout.horizontalCenter: parent.horizontalCenter
    //                 text: (_activeVehicle && _activeVehicle.climbRate)
    //                         ? _activeVehicle.climbRate.valueString : "N/A"
    //                 font.bold: true
    //                 color: "black"
    //                 Layout.alignment: Qt.AlignHCenter
    //             }
    //         }
    //     }

    //     // Row 2
    //     Rectangle {
    //         width: infoTable.width / 2
    //         height: 50
    //         border.color: Qt.rgba(1, 1, 1, 0.3)
    //         border.width: 0.5
    //         color: "transparent"

    //         ColumnLayout {
    //             anchors.centerIn: parent
    //             QGCLabel {
    //                 //Layout.horizontalCenter: parent.horizontalCenter
    //                 text: qsTr("Flight Distance (m)")
    //                 font.bold: true
    //                 color: "black"
    //                 Layout.alignment: Qt.AlignHCenter
    //             }
    //             QGCLabel {
    //                // Layout.horizontalCenter: parent.horizontalCenter
    //                 text: (_activeVehicle && _activeVehicle.flightDistance)
    //                         ? _activeVehicle.flightDistance.valueString : "N/A"
    //                 font.bold: true
    //                 color: "black"
    //                 Layout.alignment: Qt.AlignHCenter
    //             }
    //         }
    //     }

    //     Rectangle {
    //         width: infoTable.width / 2
    //         height: 50
    //         border.color: Qt.rgba(1, 1, 1, 0.3)
    //         border.width: 0.5
    //         color: "transparent"

    //         ColumnLayout {
    //             anchors.centerIn: parent
    //             QGCLabel {
    //                 //Layout.horizontalCenter: parent.horizontalCenter
    //                 text: qsTr("Flight Time (sec)")
    //                 font.bold: true
    //                 color: "black"
    //                 Layout.alignment: Qt.AlignHCenter
    //             }
    //             QGCLabel {
    //                 Layout.alignment: Qt.AlignHCenter
    //                 color: "black"
    //                 text: QGroundControl.multiVehicleManager.activeVehicle ?
    //                       QGroundControl.multiVehicleManager.activeVehicle.flightTime.valueString : "N/A"
    //                 font.bold: true
    //             }
    //         }
    //     }
    // }

    // QGCLabel {
    //     id: batteryDetails
    //     anchors.top: infoTable.bottom
    //     anchors.topMargin: 10
    //     anchors.horizontalCenter: parent.horizontalCenter
    //     text: qsTr("BATTERY PROFILE")
    //     font.bold: true
    //     color: "yellow"
    // }

    // GridLayout {
    //     id: batteryLayout
    //     anchors.top: batteryDetails.bottom
    //     anchors.topMargin: 5
    //     anchors.horizontalCenter: parent.horizontalCenter
    //     columns: 2
    //     rowSpacing: -1
    //     columnSpacing: -1
    //     width: parent.width * 0.95

    //     Rectangle {
    //         width: batteryLayout.width / 2
    //         height: 50
    //         border.color: Qt.rgba(1, 1, 1, 0.3)
    //         border.width: 0.5
    //         color: "transparent"

    //         ColumnLayout {
    //             anchors.centerIn: parent
    //             QGCLabel {
    //                 //Layout.horizontalCenter: parent.horizontalCenter
    //                 text: qsTr("Battery Current (Amp)")
    //                 font.bold: true
    //                 color: "black"
    //                 Layout.alignment: Qt.AlignHCenter
    //             }

    //             QGCLabel {
    //                 Layout.alignment: Qt.AlignHCenter
    //                 color: "black"
    //                 text: (_activeVehicle && _activeVehicle.batteries && _activeVehicle.batteries.count > 0
    //                         && _activeVehicle.batteries.get(0))
    //                       ? _activeVehicle.batteries.get(0).current.valueString
    //                       : "N/A"
    //                 font.bold: true
    //             }
    //         }
    //     }

    //     Rectangle {
    //         width: batteryLayout.width / 2
    //         height: 50
    //         border.color: Qt.rgba(1, 1, 1, 0.3)
    //         border.width: 0.5
    //         color: "transparent"

    //         ColumnLayout {
    //             anchors.centerIn: parent
    //             QGCLabel {
    //                 //Layout.horizontalCenter: parent.horizontalCenter
    //                 text: qsTr("Battery Voltage (Vol)")
    //                 font.bold: true
    //                 color: "black"
    //                 Layout.alignment: Qt.AlignHCenter
    //             }

    //             QGCLabel {
    //                 Layout.alignment: Qt.AlignHCenter
    //                 color: "black"
    //                 text: (_activeVehicle && _activeVehicle.batteries && _activeVehicle.batteries.count > 0
    //                         && _activeVehicle.batteries.get(0))
    //                       ? _activeVehicle.batteries.get(0).voltage.valueString
    //                       : "N/A"
    //                 font.bold: true
    //             }
    //         }
    //     }
    // }

//     Rectangle {
//         anchors.top: batteryLayout.bottom
//         anchors.topMargin: 15
//         anchors.horizontalCenter: parent.horizontalCenter
//         width: parent.width * 0.95
//         height: 50
//         border.color: Qt.rgba(1, 1, 1, 0.3)
//         border.width: 0.5
//         color: "transparent"
//         visible: (
//             // (activeVehicle && activeVehicle.rcRSSI !== undefined && activeVehicle.rcRSSI > 0) ||
//             (activeVehicle && activeVehicle.rcRSSI !== undefined && activeVehicle.rcRSSI > 0 && activeVehicle.rcRSSI < 100) ||
//             (activeVehicle && activeVehicle.gimbalAvailable) ||
//             (activeVehicle && activeVehicle.remoteIDAvailable) ||
//             (activeVehicle && activeVehicle.telemetryLRSSI !== undefined && activeVehicle.telemetryLRSSI > 0)
//         )


//         Row {
//             anchors.fill: parent
//             spacing: 0

//             Rectangle {
//                 width: parent.width / 5
//                 height: parent.height
//                 color: "transparent"
//                 visible: activeVehicle && activeVehicle.rcRSSI && activeVehicle.rcRSSI > 0

//                 Item {
//                     anchors.centerIn: parent
//                     width: parent.width
//                     height: parent.height

//                     Loader {
//                         id: rcRssiLoader
//                         //source: "qrc:/toolbar/RCRSSIIndicator.qml"
//                         //active: true
//                         anchors.centerIn: parent
//                         width: parent.width * 0.6
//                         height: parent.height * 0.6
//                         source: "qrc:/toolbar/RCRSSIIndicator.qml"
//                     }
//                 }
//             }

//             Rectangle {
//                 width: 1
//                 color: "gray"
//                 Layout.fillHeight: true
//             }

//             Rectangle {
//                 width: parent.width / 2.3
//                 height: parent.height
//                 color: "transparent"

//                 Item {
//                     anchors.centerIn: parent
//                     width: parent.widths
//                     height: parent.height

//                     Loader {
//                         id: gimbalLoader
//                         source: (activeVehicle && activeVehicle.gimbalAvailable) ? "qrc:/toolbar/GimbalIndicator.qml" : ""
//                         //source: "qrc:/toolbar/GimbalIndicator.qml"
//                         //active: true
//                         anchors.centerIn: parent
//                         width: parent.width * 0.6
//                         height: parent.height * 0.6
//                     }
//                 }
//             }

//             Rectangle {
//                 width: 1
//                 color: "gray"
//                 Layout.fillHeight: true
//             }

//             Rectangle {
//                 width: parent.width / 6
//                 height: parent.height
//                 color: "transparent"

//                 Item {
//                     anchors.centerIn: parent
//                     width: parent.width
//                     height: parent.height

//                     Loader {
//                         id: remoteIdLoader
//                         source: (activeVehicle && activeVehicle.remoteIDAvailable) ? "qrc:/toolbar/RemoteIDIndicator.qml" : ""
//                         //source: "qrc:/toolbar/RemoteIDIndicator.qml"
//                         //active: true
//                         anchors.centerIn: parent
//                         width: parent.width * 0.6
//                         height: parent.height * 0.6
//                     }
//                 }
//             }

//             Rectangle {
//                 width: 1
//                 color: "blue"
//                 Layout.fillHeight: true
//             }

//             Rectangle {
//                 width: parent.width / 6
//                 height: parent.height
//                 color: "transparent"

//                 Item {
//                     anchors.centerIn: parent
//                     width: parent.width
//                     height: parent.height

//                     // Loader {
//                     //     id: telemLoader
//                     //     source: "qrc:/toolbar/TelemetryRSSIIndicator.qml"
//                     //     active: _activeVehicle && _activeVehicle.telemetryLRSSI !== undefined
//                     //     visible: _activeVehicle && _activeVehicle.telemetryLRSSI !== undefined
//                     //     //active: true
//                     //     anchors.centerIn: parent
//                     //     width: parent.width * 0.6
//                     //     height: parent.height * 0.6
//                     // }

//                     Loader {
//                         id: telemLoader
//                         anchors.centerIn: parent
//                         width: parent.width * 0.6
//                         height: parent.height * 0.6
//                         source: (activeVehicle && activeVehicle.telemetryLRSSI > 0) ? "qrc:/toolbar/TelemetryRSSIIndicator.qml" : ""
//                     }
//                 }
//             }
//         }
//     }
// }
