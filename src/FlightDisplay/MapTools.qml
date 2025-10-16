import QtQuick                  2.12
import QtQuick.Controls         2.2
import QtQuick.Controls.Styles 1.4
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
    width: 50
    height: mainLayout.height + 20
    color: /*Qt.rgba(0.2, 0.4, 0.8, 0.65)*/ "transparent"
    radius: 20

    signal toggleComponents(bool hidden)

    ColumnLayout {
        id: mainLayout
        anchors.centerIn: parent
        spacing: 10

        ColumnLayout {
            id: optionsLayout
            Layout.alignment: Qt.AlignHCenter

            // QGCButton {
            //     id: layerButton
            //     //width: 50
            //     Layout.preferredWidth: root.width * 0.75
            //     Layout.preferredHeight: width
            //     // Layout.preferredHeight: root.height * 0.5
            //     backRadius: 8
            //     background: Rectangle {
            //         color: "black"
            //         radius: 8
            //         border.width: 1
            //         border.color: "white"
            //     }
            //     contentItem: Image {
            //         anchors.centerIn: parent
            //         source: "/res/layers"
            //         fillMode: Image.PreserveAspectFit
            //         // width: parent.width * 0.4
            //         // height: parent.height * 0.4
            //     }
            // }

            // QGCButton {
            //     id: hideButton
            //     //width: 50
            //     Layout.preferredWidth: root.width * 0.75
            //     Layout.preferredHeight: width
            //     // Layout.preferredHeight: root.height * 0.5
            //     backRadius: 8
            //     background: Rectangle {
            //         color: "black"
            //         radius: 8
            //         border.width: 1
            //         border.color: "white"
            //     }
            //     contentItem: Image {
            //         id: buttonIcon
            //         anchors.centerIn: parent
            //         source: "/res/paramHide"
            //         fillMode: Image.PreserveAspectFit
            //         // width: parent.width * 0.3
            //         // height: parent.height * 0.3
            //     }
            //     //onClicked: mapControl.zoomLevel += 0.5
            // }

            QGCButton {
                id: hideButton
                Layout.preferredWidth: ScreenTools.isMobile ? root.width * 1.5 : root.width * 0.75
                Layout.preferredHeight: width
                backRadius: 8
                //visible: _activeVehicle !== null
                background: Rectangle {
                    color: "black"
                    radius: 8
                    border.width: 1
                    border.color: "white"
                }
                contentItem: Image {
                    id: buttonIcon
                    anchors.centerIn: parent
                    source: "/res/paramHide"
                    fillMode: Image.PreserveAspectFit
                }

                property bool hiddenState: false  // track state

                onClicked: {
                    hiddenState = !hiddenState
                    buttonIcon.source = hiddenState ? "/res/paramShow" : "/res/paramHide"

                    // emit signal to FlyView
                    toggleComponents(hiddenState)
                }
            }


            MapLayers {
                Layout.bottomMargin: 5
                //Layout.alignment: Qt.AlignHCenter
            }

            QGCButton {
                id: zoomInButton
                //width: 50
                Layout.preferredWidth: ScreenTools.isMobile ? root.width * 1.5 : root.width * 0.75
                Layout.preferredHeight: width
                // Layout.preferredHeight: root.height * 0.5
                backRadius: 8
                background: Rectangle {
                    color: "black"
                    radius: 8
                    border.width: 1
                    border.color: "white"
                }
                contentItem: Image {
                    anchors.centerIn: parent
                    source: "/res/zoom-in"
                    fillMode: Image.PreserveAspectFit
                    width: parent.width
                    height: parent.height
                }
                onClicked: mapControl.zoomLevel += 0.5
            }

            QGCButton {
                id: zoomOutButton
                //width: 50
                Layout.preferredWidth: ScreenTools.isMobile ? root.width * 1.5 : root.width * 0.75
                Layout.preferredHeight: width
                // Layout.preferredHeight: root.height * 0.5
                backRadius: 8
                background: Rectangle {
                    color: "black"
                    radius: 8
                    border.width: 1
                    border.color: "white"
                }
                contentItem: Image {
                    anchors.centerIn: parent
                    source: "/res/zoom-out"
                    fillMode: Image.PreserveAspectFit
                    // width: parent.width * 0.4
                    // height: parent.height * 0.4
                }
                onClicked: mapControl.zoomLevel -= 0.5
            }
        }
    }
}
