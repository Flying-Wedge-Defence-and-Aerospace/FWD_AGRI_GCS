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

            MapLayers {
                Layout.bottomMargin: 5
                //Layout.alignment: Qt.AlignHCenter
            }

            QGCButton {
                id: zoomInButton
                //width: 50
                Layout.preferredWidth: root.width * 0.75
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
                    // width: parent.width * 0.3
                    // height: parent.height * 0.3
                }
                onClicked: mapControl.zoomLevel += 0.5
            }

            QGCButton {
                id: zoomOutButton
                //width: 50
                Layout.preferredWidth: root.width * 0.75
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

// Item {
//     id: root
//     width: 60
//     height: 140


//     Rectangle {
//         id: backgroundRect
//         width: parent.width
//         height: parent.height
//         color: "#66FFFFFF" /*"transparent"*/

//         ColumnLayout {
//             anchors.fill: parent
//             anchors.margins: 5
//             anchors.leftMargin: 15
//             //spacing: 8

//             // Button 1
//             QGCButton {
//                 id: layersButton
//                 Layout.fillWidth: true
//                 Layout.preferredHeight: root.height * 0.4
//                 backRadius: 8
//                 background: Rectangle {
//                     color: "black"
//                     radius: 8
//                     border.width: 1
//                     border.color: "white"
//                 }

//                 contentItem: Image {
//                     anchors.centerIn: parent
//                     source: "/res/layers"
//                     fillMode: Image.PreserveAspectFit
//                     width: parent.width * 0.6
//                     height: parent.height * 0.6
//                 }

                // MouseArea {
                //     anchors.fill: parent
                //     hoverEnabled: true
                //     onEntered: extraButtons.visible = true
                //     onExited: extraButtons.visible = false
                // }
//             }

//             // Item {
//             //     id: container
//             //     width: layersButton.width + 3*80 + 2*8 + 10   // total width
//             //     height: layersButton.height

//             //     // Main button
//             //     QGCButton {
//             //         id: layersButton
//             //         width: 50
//             //         height: 60
//             //         backRadius: 8

//             //         background: Rectangle {
//             //             color: "black"
//             //             radius: 8
//             //             border.width: 1
//             //             border.color: "white"
//             //         }

//             //         contentItem: Image {
//             //             anchors.centerIn: parent
//             //             source: "/res/layers"
//             //             fillMode: Image.PreserveAspectFit
//             //             width: parent.width * 0.6
//             //             height: parent.height * 0.6
//             //         }
//             //     }

//             //     // Extra buttons
//             //     Row {
//             //         id: extraButtons
//             //         x: layersButton.width + 10   // right of main button
//             //         spacing: 8
//             //         visible: false
//             //         height: layersButton.height

//             //         QGCButton { text: "Btn 1"; width: 50; height: layersButton.height }
//             //         QGCButton { text: "Btn 2"; width: 50; height: layersButton.height }
//             //         QGCButton { text: "Btn 3"; width: 50; height: layersButton.height }
//             //     }

//             //     // Hover area covering both main and extra buttons
//             //     MouseArea {
//             //         anchors.fill: parent
//             //         hoverEnabled: true
//             //         onEntered: extraButtons.visible = true
//             //         onExited: extraButtons.visible = false
//             //     }
//             // }



//             // Button 2
            // QGCButton {
            //     //width: 50
            //     Layout.fillWidth: true
            //     Layout.preferredHeight: root.height * 0.4
            //     backRadius: 8
            //     background: Rectangle {
            //         color: "black"
            //         radius: 8
            //         border.width: 1
            //         border.color: "white"
            //     }
            //     contentItem: Image {
            //         anchors.centerIn: parent
            //         source: "/res/zoom-in"
            //         fillMode: Image.PreserveAspectFit
            //         width: parent.width * 0.4
            //         height: parent.height * 0.4
            //     }
            //     onClicked: mapControl.zoomLevel += 0.5
            // }

//             // Button 3
    //         QGCButton {
    //             //width: 50
    //             Layout.fillWidth: true
    //             Layout.preferredHeight: root.height * 0.4
    //             backRadius: 8
    //             background: Rectangle {
    //                 color: "black"
    //                 radius: 8
    //                 border.width: 1
    //                 border.color: "white"
    //             }
    //             contentItem: Image {
    //                 anchors.centerIn: parent
    //                 source: "/res/zoom-out"
    //                 fillMode: Image.PreserveAspectFit
    //                 width: parent.width * 0.4
    //                 height: parent.height * 0.4
    //             }
    //             onClicked: mapControl.zoomLevel -= 0.5
    //         }
    //     }
    // }

//     // RowLayout {
//     //     id: extraButtons
//     //     anchors.left: backgroundRect.right
//     //     anchors.leftMargin: 10
//     //     spacing: 8
//     //     visible: false

//     //     Item {
//     //         Layout.preferredWidth: 3 * 80 + 2 * 8  // 3 buttons + spacing
//     //         Layout.preferredHeight: layersButton.height

//     //         Row {
//     //             anchors.fill: parent
//     //             spacing: 8

//     //             QGCButton { text: "Btn 1"; width: 80; height: parent.height }
//     //             QGCButton { text: "Btn 2"; width: 80; height: parent.height }
//     //             QGCButton { text: "Btn 3"; width: 80; height: parent.height }
//     //         }

//     //         MouseArea {
//     //             anchors.fill: parent
//     //             hoverEnabled: true
//     //             onExited: extraButtons.visible = false
//     //         }
//     //     }
//     // }

// }
