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
    width: 33
    height: 33

    property string currentMapType: QGroundControl.settingsManager.flightMapSettings.mapType.value

    // Container that includes both the button and extra buttons
    Item {
        id: hoverContainer
        width: mainButton.width + extraButtons.width + 10
        height: Math.max(mainButton.height, extraButtons.height)

        // Detect hover over entire container
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onEntered: extraButtons.visible = true
            onExited: extraButtons.visible = false
        }

        // Main button
        Rectangle {
            id: mainButton
            width: 37
            height: 37
            radius: 8
            color: "black"
            border.width: 1
            border.color: "white"

            Image {
                anchors.fill: parent
                anchors.margins: 6
                fillMode: Image.PreserveAspectFit
                source: "/res/layers"
            }

            MouseArea {
                anchors.fill: parent
                onClicked: console.log("Main button clicked")
            }
        }

        Row {
            id: extraButtons
            anchors.left: mainButton.right
            anchors.leftMargin: 7
            anchors.verticalCenter: mainButton.verticalCenter
            spacing: 5
            visible: false

            // Btn1
            Rectangle {
                id: btn1
                width: mainButton.width + 20
                height: mainButton.height
                radius: 8
                property bool checked: false
                property string mapTypeValue: "Satellite"
                color: root.currentMapType === mapTypeValue ? "green" : "black"
                //color: checked ? "green" : "black"
                border.width: 1
                border.color: "white"

                Text {
                    anchors.centerIn: parent
                    text: "Satellite"
                    color: "white"
                    font.pixelSize: 10
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked:{
                        root.currentMapType = btn1.mapTypeValue
                        //btn1.checked = !btn1.checked
                        QGroundControl.settingsManager.flightMapSettings.mapType.value = btn1.mapTypeValue
                    }
                }
            }

            // Btn2
            Rectangle {
                id: btn2
                width: mainButton.width + 20
                height: mainButton.height
                radius: 8
                property bool checked: false
                property string mapTypeValue: "Terrain"
                color: root.currentMapType === mapTypeValue ? "green" : "black"
                //color: checked ? "green" : "black"
                border.width: 1
                border.color: "white"

                Text {
                    id: tertext
                    anchors.centerIn: parent
                    text: "Terrain"
                    color: "white"
                    font.pixelSize: 10
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked:{
                        root.currentMapType = btn2.mapTypeValue
                        //btn2.checked = !btn2.checked
                        QGroundControl.settingsManager.flightMapSettings.mapType.value = btn2.mapTypeValue
                    }
                }
            }

            // Btn3
            Rectangle {
                id: btn3
                width: mainButton.width + 20
                height: mainButton.height
                radius: 8
                property bool checked: false
                property string mapTypeValue: "Labels"
                color: root.currentMapType === mapTypeValue ? "green" : "black"
                //color: checked ? "green" : "black"
                border.width: 1
                border.color: "white"

                Text {
                    anchors.centerIn: parent
                    text: "Labels"
                    color: "white"
                    font.pixelSize: 10
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked:{
                        root.currentMapType = btn3.mapTypeValue
                        // btn3.checked = !btn3.checked
                        QGroundControl.settingsManager.flightMapSettings.mapType.value = btn3.mapTypeValue
                    }
                }
            }

            Rectangle {
                id: btn4
                width: mainButton.width + 20
                height: mainButton.height
                radius: 8
                property bool checked: false
                property string mapTypeValue: "Hybrid"
                color: root.currentMapType === mapTypeValue ? "green" : "black"
                //color: checked ? "green" : "black"
                border.width: 1
                border.color: "white"

                Text {
                    anchors.centerIn: parent
                    text: "Hybrid"
                    color: "white"
                    font.pixelSize: 10
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked:{
                        root.currentMapType = btn4.mapTypeValue
                        // btn4.checked = !btn4.checked
                        QGroundControl.settingsManager.flightMapSettings.mapType.value = btn4.mapTypeValue
                    }
                }
            }

            Rectangle {
                id: btn5
                width: mainButton.width + 23
                height: mainButton.height
                radius: 8
                property bool checked: false
                property string mapTypeValue: "Street Map"
                color: root.currentMapType === mapTypeValue ? "green" : "black"
                //color: checked ? "green" : "black"
                border.width: 1
                border.color: "white"

                Text {
                    anchors.centerIn: parent
                    text: "Street Map"
                    color: "white"
                    font.pixelSize: 10
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.currentMapType = btn5.mapTypeValue
                        // btn5.checked = !btn5.checked
                        QGroundControl.settingsManager.flightMapSettings.mapType.value = btn5.mapTypeValue
                    }
                }
            }
        }
    }
}

