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
        height:             ScreenTools.isMobile ? (_outerRadius * 1.3) : (_outerRadius * 2) + 60 /*- 100*/ // size of that
        //width: 460
        // Layout.fillWidth:   true
        width: attitude.width + compass.width + _spacing + (_topBottomMargin * 2) + 20
        radius:             20
        color:              /*Qt.rgba(0.2, 0.4, 0.8, 0.65)*/ "#66800000"
        border.color: "orange"
        border.width: 2

        DeadMouseArea { anchors.fill: parent }

        QGCAttitudeWidget {
            id:                     attitude
            anchors.leftMargin:     _topBottomMargin
            anchors.left:           parent.left
            size:                   ScreenTools.isMobile ? (_innerRadius * 1.3) : (_innerRadius * 2) + 50 /*- 100*/  // size of that
            vehicle:                globals.activeVehicle
            anchors.verticalCenter: parent.verticalCenter
        }

        QGCCompassWidget {
            id:                     compass
            anchors.leftMargin:     _spacing + 20
            anchors.left:           attitude.right
            size:                   ScreenTools.isMobile ? (_innerRadius * 1.3) : (_innerRadius * 2) + 50 /*- 100*/   // size of that
            vehicle:                globals.activeVehicle
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    TerrainProgress {
        Layout.fillWidth: true
    }
}
