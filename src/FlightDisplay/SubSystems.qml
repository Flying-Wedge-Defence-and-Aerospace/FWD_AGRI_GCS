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

// Item {
//     id: root
//     width: iRa.width
//     height: iRa.height

    Rectangle {
        id: iRa
        width: ml.implicitWidth
        height: ml.implicitHeight
        anchors.top: parent.top
        anchors.left: parent.left
        color: qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(1, 1, 1, 0.5) : "#88000000"

        ColumnLayout {
            id: ml
            anchors.fill: parent
            spacing: ScreenTools.defaultFontPixelHeight

            Rectangle {
                id: iR
                width: ScreenTools.defaultFontPixelWidth * 7.3
                height: ScreenTools.defaultFontPixelHeight * 1.6
                color: "transparent"
                radius: ScreenTools.defaultFontPixelWidth / 2

                Loader {
                    id: rcRssiLoader
                    anchors.fill: parent
                    source: "qrc:/toolbar/RCRSSIIndicator.qml"
                    //Layout.fillWidth: true
                    //Layout.preferredWidth: implicitHeight
                }
            }

            Rectangle {
                id: iR1
                width: ScreenTools.defaultFontPixelWidth * 3.5
                height: ScreenTools.defaultFontPixelHeight * 1.5
                color: "transparent"
                radius: ScreenTools.defaultFontPixelHeight / 2

                Loader {
                    id: gimbalLoader
                    anchors.fill: parent
                    source: "qrc:/toolbar/GimbalIndicator.qml"
                    //Layout.fillWidth: true
                    //Layout.preferredWidth: implicitHeight
                }
            }

            Rectangle {
                id: iR2
                width: ScreenTools.defaultFontPixelWidth * 4
                height: ScreenTools.defaultFontPixelHeight * 1.3
                color: "transparent"
                radius: ScreenTools.defaultFontPixelHeight / 2

                Loader {
                    id: remoteIdLoader
                    anchors.fill: parent
                    source: "qrc:/toolbar/RemoteIDIndicator.qml"
                    //Layout.fillWidth: true
                    //Layout.preferredWidth: implicitHeight
                }
            }

            Rectangle {
                id: iR3
                width: ScreenTools.defaultFontPixelWidth * 4
                height: ScreenTools.defaultFontPixelHeight * 1.3
                color: "transparent"

                Loader {
                    id: telemLoader
                    anchors.fill: parent
                    source: "qrc:/toolbar/TelemetryRSSIIndicator.qml"
                    //Layout.fillWidth: true
                    //Layout.preferredWidth: implicitHeight
                }
            }
        }
    }
//}
