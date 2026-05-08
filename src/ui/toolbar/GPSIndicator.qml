/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.11
import QtQuick.Layouts  1.11
import QtQuick.Controls 2.5

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0

//-------------------------------------------------------------------------
//-- GPS Indicator
Item {
    id:             _root
    //width:          (gpsValuesColumn.x + gpsValuesColumn.width) * 4
    //implicitWidth: (gpsValuesColumn.x + gpsValuesColumn.width) * 2

    implicitWidth: gpsIcon.width + gpsValuesColumn.width + ScreenTools.defaultFontPixelWidth
    implicitHeight: Math.max(gpsIcon.height, gpsValuesColumn.height)
    anchors.top:    parent.top
    anchors.bottom: parent.bottom

    property bool showIndicator: true

    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle

    Component {
        id: gpsInfo

        Rectangle {
            width:  gpsCol.width   + ScreenTools.defaultFontPixelWidth  * 3
            height: gpsCol.height  + ScreenTools.defaultFontPixelHeight * 2
            radius: ScreenTools.defaultFontPixelHeight * 0.5
            color:  qgcPal.window
            border.color:   qgcPal.text

            Column {
                id:                 gpsCol
                spacing:            ScreenTools.defaultFontPixelHeight * 0.5
                width:              Math.max(gpsGrid.width, gpsLabel.width)
                anchors.margins:    ScreenTools.defaultFontPixelHeight
                anchors.centerIn:   parent

                QGCLabel {
                    id:             gpsLabel
                    text:           (_activeVehicle && _activeVehicle.gps.count.value >= 0) ? qsTr("GPS Status") : qsTr("GPS Data Unavailable")
                    font.family:    ScreenTools.demiboldFontFamily
                    font.bold: true
                    font.pointSize: 12
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                QGCLabel {
                    visible: !_activeVehicle || !_activeVehicle.gps || _activeVehicle.gps.count === 0
                    text: qsTr("GPS Status not available")
                    color: "red"
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                GridLayout {
                    id:                 gpsGrid
                    visible:            (_activeVehicle && _activeVehicle.gps.count.value >= 0)
                    anchors.margins:    ScreenTools.defaultFontPixelHeight
                    columnSpacing:      ScreenTools.defaultFontPixelWidth + 30
                    anchors.horizontalCenter: parent.horizontalCenter
                    columns: 2

                    QGCLabel { text: qsTr("GPS Count:"); font.bold: true }
                    QGCLabel { text: _activeVehicle ? _activeVehicle.gps.count.valueString : qsTr("N/A", "No data to display") }
                    QGCLabel { text: qsTr("GPS Lock:"); font.bold: true }
                    QGCLabel { text: _activeVehicle ? _activeVehicle.gps.lock.enumStringValue : qsTr("N/A", "No data to display") }
                    QGCLabel { text: qsTr("HDOP:"); font.bold: true }
                    QGCLabel { text: _activeVehicle ? _activeVehicle.gps.hdop.valueString : qsTr("--.--", "No data to display") }
                    QGCLabel { text: qsTr("VDOP:"); font.bold: true }
                    QGCLabel { text: _activeVehicle ? _activeVehicle.gps.vdop.valueString : qsTr("--.--", "No data to display") }
                    QGCLabel { text: qsTr("Course Over Ground:"); font.bold: true }
                    QGCLabel { text: _activeVehicle ? _activeVehicle.gps.courseOverGround.valueString : qsTr("--.--", "No data to display") }
                }
            }
        }
    }

    QGCColoredImage {
        id:                 gpsIcon
        width:              height - (ScreenTools.isMobile ? 50 : 30)
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        source:             "/res/gps_icon"
        fillMode:           Image.PreserveAspectFit
        sourceSize.height:  height
        opacity:            (_activeVehicle && _activeVehicle.gps.count.value >= 0) ? 1 : 0.5
        color:              /*qgcPal.buttonText*/ "white"
    }

    Column {
        id:                     gpsValuesColumn
        anchors.verticalCenter: parent.verticalCenter
        //anchors.leftMargin:     ScreenTools.defaultFontPixelWidth / 2
        anchors.left:           gpsIcon.right
        anchors.leftMargin: ScreenTools.defaultFontPixelWidth
        spacing: 1

        QGCLabel {
            id: hdopPar
            anchors.horizontalCenter:   hdopValue.horizontalCenter
            //visible:                    _activeVehicle && !isNaN(_activeVehicle.gps.hdop.value)
            color:                      /*qgcPal.buttonText*/ "white"
            //text:                       _activeVehicle ? _activeVehicle.gps.count.valueString : ""
            text:                       _activeVehicle && !isNaN(_activeVehicle.gps.count.value)
                                                ? _activeVehicle.gps.count.valueString + "  sats"
                                                : "N/A"
            font.pointSize: ScreenTools.isMobile ? 6.8 : 11
            font.bold: true

            ToolTip.visible: count.containsMouse
            ToolTip.text: "GPS Count"

            MouseArea {
                id: count
                anchors.fill: parent
                hoverEnabled: true
            }
        }

        QGCLabel {
            id:         hdopValue
            //visible:    _activeVehicle && !isNaN(_activeVehicle.gps.hdop.value)
            color:      /*qgcPal.buttonText*/ "white"
            //text:       _activeVehicle ? _activeVehicle.gps.hdop.value.toFixed(1) : ""
            text:       _activeVehicle && !isNaN(_activeVehicle.gps.hdop.value)
                                ? _activeVehicle.gps.hdop.value.toFixed(1) + "  hdop"
                                : "N/A"
            font.bold: true
            font.pointSize: ScreenTools.isMobile ? 6.8 : 11

            ToolTip.visible: hdop.containsMouse
            ToolTip.text: "HDOP value"

            MouseArea {
                id: hdop
                anchors.fill: parent
                hoverEnabled: true
            }
        }
    }

    MouseArea {
        anchors.fill:   parent
        onClicked: {
            mainWindow.showIndicatorPopup(_root, gpsInfo, "top")
        }
    }
}
