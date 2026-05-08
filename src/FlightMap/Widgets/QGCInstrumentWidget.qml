/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.12
import QtQuick.Layouts  1.12

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.FactSystem    1.0
import QGroundControl.FlightMap     1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.Palette       1.0

ColumnLayout {
    id:         root
    spacing:    ScreenTools.defaultFontPixelHeight / 3

    property real   _innerRadius:           (width - (_topBottomMargin * 3)) / 4
    property real   _outerRadius:           _innerRadius + _topBottomMargin
    property real   _spacing:               ScreenTools.defaultFontPixelHeight * 0.33
    property real   _topBottomMargin:       (width * 0.05) /*/ 2*/

    QGCPalette { id: qgcPal }

    Rectangle {
        id:                 visualInstrument
        height:             attitude.size + _altitudeItem.height + compass.size + (_spacing * 7) + (_topBottomMargin * 2)
        //width: 460
        // Layout.fillWidth:   true
        width: ScreenTools.isMobile ? (_innerRadius * 2.8) : (_innerRadius * 2.8) + 80
        radius:             width/2
        color:              qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(1, 1, 1, 0.5) : Qt.rgba(0, 0, 0, 0.5)

        DeadMouseArea { anchors.fill: parent }

        ColumnLayout {
            id: hudLayout
            anchors.fill: parent
            anchors.margins: _topBottomMargin
            spacing: ScreenTools.defaultFontPixelHeight

            QGCAttitudeWidget {
                id:                     attitude
                size:                   ScreenTools.isMobile ? (_innerRadius * 2.3) : (_innerRadius * 4.4)
                vehicle:                globals.activeVehicle
                Layout.alignment:       Qt.AlignHCenter
            }

            Item {
                id: _altitudeItem
                Layout.fillWidth: true
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.5

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 0
                    QGCLabel {
                        text: "ALT"
                        font.bold: true
                        font.pointSize: ScreenTools.largeFontPointSize
                    }
                    QGCLabel {
                        text: globals.activeVehicle ? globals.activeVehicle.altitudeRelative.valueString + " m" : "N/A"
                        font.pointSize: ScreenTools.mediumFontPointSize
                    }
                }
            }

            QGCCompassWidget {
                id:                     compass
                size:                   ScreenTools.isMobile ? (_innerRadius * 2.3) : (_innerRadius * 4.4)
                vehicle:                globals.activeVehicle
                Layout.alignment:       Qt.AlignHCenter
                Layout.topMargin:       _spacing
            }
        }
    }

    TerrainProgress {
        Layout.fillWidth: true
    }
}
