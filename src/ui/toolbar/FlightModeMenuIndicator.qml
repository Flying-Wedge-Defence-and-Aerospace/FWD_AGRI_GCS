/****************************************************************************
 *
 * (c) 2009-2022 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick 2.11
import QtQuick.Layouts 1.11

import QGroundControl 1.0
import QGroundControl.Controls 1.0
import QGroundControl.MultiVehicleManager 1.0
import QGroundControl.ScreenTools 1.0
import QGroundControl.Palette 1.0

Item {
    id:                     _root
    width:  modeLabel.width
    height: modeLabel.height
    //Layout.preferredWidth:  rowLayout.width

    property real fontPointSize: ScreenTools.largeFontPointSize
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

    // RowLayout {
    //     id:         rowLayout
    //     spacing:    0
    //     height:     parent.height

    //     // QGCColoredImage {
    //     //     id:         flightModeIcon
    //     //     width:      ScreenTools.defaultFontPixelWidth * 2
    //     //     height:     ScreenTools.defaultFontPixelHeight * 0.75
    //     //     fillMode:   Image.PreserveAspectFit
    //     //     mipmap:     true
    //     //     color:      qgcPal.text
    //     //     source:     "/qmlimages/FlightModesComponentIcon.png"
    //     //     Layout.alignment:   Qt.AlignVCenter
    //     // }

    //     Item {
    //         Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth / 2
    //         height:                 1
    //     }

    //     QGCLabel {
    //         text:               activeVehicle ? activeVehicle.flightMode : qsTr("N/A", "No data to display")
    //         color: "black"
    //         //font.pointSize:     fontPointSize
    //         font.bold: true
    //         //Layout.alignment:   Qt.AlignVCenter
    //         //font.pointSize: 15
    //     }
    // }


    // QGCMouseArea {
    //     anchors.fill:   rowLayout
    //     onClicked: {
    //         console.log("Clicked")
    //         mainWindow.showIndicatorPopup(_root, flightModeMenu)
    //     }
    // }


    // RowLayout {
    //     id: rowLayout
    //     spacing: 6
    //     height: parent.height

    //     QGCLabel {
    //         text: activeVehicle ? activeVehicle.flightMode : qsTr("N/A", "No data to display")
    //         color: "black"
    //         font.bold: true
    //         Layout.alignment: Qt.AlignVCenter
    //     }

    //     // Arrow icon for dropdown
    //     Text {
    //         id: arrowIcon
    //         text: "▼"
    //         font.pixelSize: 14
    //         color: "black"
    //         Layout.alignment: Qt.AlignVCenter
    //     }

    //     QGCMouseArea {
    //         anchors.fill: arrowIcon
    //         onClicked: {
    //             console.log("Arrow clicked")
    //             mainWindow.showIndicatorPopup(_root, flightModeMenu)
    //         }
    //     }
    // }

    // RowLayout {
    //     id: rowLayout
    //     spacing: 6
    //     height: parent.height

    //     QGCLabel {
    //         text: activeVehicle ? activeVehicle.flightMode : qsTr("N/A", "No data to display")
    //         color: "black"
    //         font.bold: true
    //         Layout.alignment: Qt.AlignVCenter
    //     }

    //     // Wrap arrow + mouse area inside an Item
    //     Item {
    //         id: arrowBox
    //         Layout.preferredWidth: arrowIcon.implicitWidth
    //         Layout.preferredHeight: arrowIcon.implicitHeight
    //         Layout.alignment: Qt.AlignVCenter

    //         Text {
    //             id: arrowIcon
    //             text: "▼"
    //             font.pixelSize: 14
    //             color: "black"
    //             anchors.centerIn: parent
    //         }

    //         QGCMouseArea {
    //             anchors.fill: parent   // ✅ legal now, because parent is Item (not layout-managed)
    //             onClicked: {
    //                 console.log("Arrow clicked")
    //                 mainWindow.showIndicatorPopup(_root, flightModeMenu)
    //             }
    //         }
    //     }
    // }


    // RowLayout {
    //     id: rowLayout
    //     spacing: 6
    //     height: parent.height

    //     // Background for mode name
    //     Rectangle {
    //         id: modeBg
    //         color: Qt.rgba(0.9, 0.9, 0.9, 0.6)   // light gray semi-transparent
    //         radius: 6
    //         // border.color: "black"
    //         // border.width: 1
    //         Layout.alignment: Qt.AlignVCenter
    //         Layout.preferredHeight: modeLabel.implicitHeight + 8   // add padding
    //         Layout.preferredWidth: modeLabel.implicitWidth + 16    // add padding

    //         QGCLabel {
    //             id: modeLabel
    //             text: activeVehicle ? activeVehicle.flightMode : qsTr("N/A", "No data to display")
    //             color: "black"
    //             font.bold: true
    //             anchors.centerIn: parent
    //         }
    //     }

    //     // Arrow box with click
    //     Item {
    //         id: arrowBox
    //         Layout.preferredWidth: arrowIcon.implicitWidth + 8
    //         Layout.preferredHeight: arrowIcon.implicitHeight + 8
    //         Layout.alignment: Qt.AlignVCenter

    //         Text {
    //             id: arrowIcon
    //             text: "▼"
    //             font.pointSize: 14
    //             color: "black"
    //             anchors.centerIn: parent
    //         }

    //         QGCMouseArea {
    //             anchors.fill: parent
    //             onClicked: {
    //                 console.log("Arrow clicked")
    //                 mainWindow.showIndicatorPopup(_root, flightModeMenu)
    //             }
    //         }
    //     }
    // }

    // RowLayout {
    //     id: rowLayout
    //     spacing: 0
    //     height: parent.height

        // // Unified background for mode + arrow
        // Rectangle {
        //     id: modeContainer
        //     color: /*Qt.rgba(0.9, 0.9, 0.9, 0.6) */  "transparent" // light gray semi-transparent
        //     // radius: 6
        //     // border.color: "black"
        //     // border.width: 1
        //     //Layout.alignment: Qt.AlignVCenter
        //     Layout.preferredHeight: modeLabel.implicitHeight + 27
        //     Layout.preferredWidth: modeLayout.implicitWidth + 50 /*+ arrowIcon.implicitWidth + 50*/ // text + arrow + padding

            // RowLayout {
            //     id: modeLayout
            //     anchors.fill: parent
            //     //anchors.margins: 8
            //     spacing: 8

                // QGCLabel {
                //     text: "MODE"
                //     color: "black"
                //     Layout.alignment: Qt.AlignVCenter
                // }

                QGCLabel {
                    id: modeLabel
                    text: activeVehicle ? activeVehicle.flightMode : qsTr("FLIGHT MODE")
                    color: "black"
                    font.bold: true

                    QGCMouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if(activeVehicle) {
                                mainWindow.showIndicatorPopup(_root, flightModeMenu)
                            }
                        }
                    }
                }
            //}

            // Whole rectangle is clickable
            // QGCMouseArea {
            //     anchors.fill: parent
            //     onClicked: {
            //         if(activeVehicle) {
            //             mainWindow.showIndicatorPopup(_root, flightModeMenu)
            //         }
            //     }
            // }
        //}
    //}
}
