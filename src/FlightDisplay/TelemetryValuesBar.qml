/****************************************************************************
 *
 *   (c) 2009-2016 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick                      2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts              1.12

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Vehicle       1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.FactControls 1.0


Rectangle {
    id:                 telemetryPanel
    height:             telemetryLayout.height + (_toolsMargin * 2)
    width:              telemetryLayout.width + (_toolsMargin * 2)
    color:              qgcPal.window /*"darkgray"*/
    radius:             ScreenTools.defaultFontPixelWidth / 2

    property bool       bottomMode: true

    DeadMouseArea { anchors.fill: parent }

    ColumnLayout {
        id:                 telemetryLayout
        anchors.margins:    _toolsMargin
        anchors.bottom:     parent.bottom
        anchors.left:       parent.left

         RowLayout {
            visible: mouseArea.containsMouse /*|| valueArea.settingsUnlocked*/

            // QGCColoredImage {
            //     source:             "/res/layout-bottom.svg"
            //     mipmap:             true
            //     width:              ScreenTools.minTouchPixels * 0.75
            //     height:             width
            //     sourceSize.width:   width
            //     color:              qgcPal.text
            //     fillMode:           Image.PreserveAspectFit
            //     visible:            !bottomMode

            //     QGCMouseArea {
            //         fillItem:   parent
            //         onClicked:  bottomMode = true
            //     }
            // }

            // QGCColoredImage {
            //     source:             "/res/layout-right.svg"
            //     mipmap:             true
            //     width:              ScreenTools.minTouchPixels * 0.75
            //     height:             width
            //     sourceSize.width:   width
            //     color:              qgcPal.text
            //     fillMode:           Image.PreserveAspectFit
            //     visible:            bottomMode

            //     QGCMouseArea {
            //         fillItem:   parent
            //         onClicked:  bottomMode = false
            //     }
            // }

            QGCColoredImage {
                source:             valueArea.settingsUnlocked ? "/res/LockOpen.svg" : "/res/pencil.svg"
                mipmap:             true
                width:              ScreenTools.minTouchPixels * 0.75
                height:             width
                sourceSize.width:   width
                color:              qgcPal.text
                fillMode:           Image.PreserveAspectFit

                QGCMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape:  Qt.PointingHandCursor
                    onClicked:    valueArea.settingsUnlocked = !valueArea.settingsUnlocked
                }
            }
        }

        QGCMouseArea {
            id:                         mouseArea
            x:                          telemetryLayout.x
            y:                          telemetryLayout.y
            width:                      telemetryLayout.width
            height:                     telemetryLayout.height
            hoverEnabled:               !ScreenTools.isMobile
            propagateComposedEvents:    true

            onClicked: {
                if (ScreenTools.isMobile && !valueArea.settingsUnlocked) {
                    valueArea.settingsUnlocked = true
                    mouse.accepted = true
                } else {
                    mouse.accepted = false
                }
            }
        }

        HorizontalFactValueGrid {
            id:                     valueArea
            userSettingsGroup:      telemetryBarUserSettingsGroup
            defaultSettingsGroup:   telemetryBarDefaultSettingsGroup
        }

        // Row {
        //     spacing: 16
        //     anchors.verticalCenter: parent.verticalCenter

        //     HorizontalFactValueGrid {
        //         id: valueArea
        //         userSettingsGroup: telemetryBarUserSettingsGroup
        //         defaultSettingsGroup: telemetryBarDefaultSettingsGroup
        //     }

        //     Column {
        //         spacing: 4
        //         width: 140

        //         Component.onCompleted: {
        //             if (_activeVehicle) {
        //                 console.log("Vehicle available:", _activeVehicle)
        //                 console.log("🔋 battery:", _activeVehicle.battery)
        //                 console.log("🔋 batteryFactGroup:", _activeVehicle.batteryFactGroup)
        //                 console.log("🔋 batteries:", _activeVehicle.batteries)


        //                 if (_activeVehicle.batteries) {
        //                     console.log("Voltage fact:", _activeVehicle.batteries.voltage)
        //                     console.log("Current fact:", _activeVehicle.batteries.current)
        //                 }
        //             } else {
        //                 console.log("_activeVehicle is null here")
        //             }
        //         }


                // Text {
                //     text: qsTr("Battery Voltage")
                //     font.pixelSize: ScreenTools.defaultFontPixelHeight
                //     color: qgcPal.text
                // }

        //         // Text {
        //         //     id: voltageText
        //         //     font.pixelSize: ScreenTools.defaultFontPixelHeight
        //         //     color: qgcPal.text
        //         //     // Safe-binding: only read valueString when the fact exists
        //         //     text: (_activeVehicle && _activeVehicle.battery && _activeVehicle.battery.voltage)
        //         //           ? _activeVehicle.batteryFactGroup.voltage.valueString
        //         //           : "--"
        //         //     wrapMode: Text.NoWrap
        //         // }

                // Text {
                //     text: _activeVehicle.batteries.get(0).voltage.valueString + " V"
                //     color: "white"
                // }

                // Text {
                //     text: qsTr("Battery Current")
                //     font.pixelSize: ScreenTools.defaultFontPixelHeight
                //     color: qgcPal.text
                // }

        //         // Text {
        //         //     id: currentText
        //         //     font.pixelSize: ScreenTools.defaultFontPixelHeight
        //         //     color: qgcPal.text
        //         //     text: (_activeVehicle && _activeVehicle.battery && _activeVehicle.battery.current)
        //         //           ? _activeVehicle.batteryFactGroup.current.valueString
        //         //           : "--"
        //         //     wrapMode: Text.NoWrap
        //         // }

                // Text {
                //     text: _activeVehicle.batteries.get(0).current.valueString + " A"
                //     color: "white"
                // }

        //     }
        // }
    }
}
