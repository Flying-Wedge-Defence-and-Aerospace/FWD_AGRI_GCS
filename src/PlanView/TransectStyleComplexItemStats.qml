import QtQuick          2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.12

import QGroundControl               1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controls      1.0

// Statistics section for TransectStyleComplexItems
GridLayout {
    // The following properties must be available up the hierarchy chain
    //property var    missionItem       ///< Mission Item for editor

    columns:        2
    columnSpacing:  ScreenTools.defaultFontPixelWidth + 20

    Rectangle {
        color: "#34495e"       // background color
        radius: 6              // rounded corners
        border.color: "#2c3e50"
        border.width: 1
        anchors.margins: 4
        height: label.implicitHeight + 8
        width: label.implicitWidth + 16

        QGCLabel {
            id: label
            text: qsTr("Survey Area")
            anchors.centerIn: parent
            font.italic: true
            color: "white"
        }
    }

    QGCLabel { text: QGroundControl.unitsConversion.squareMetersToAppSettingsAreaUnits(missionItem.coveredArea).toFixed(2) + " " + QGroundControl.unitsConversion.appSettingsAreaUnitsString }

    //QGCLabel { text: qsTr("Photo Count"); font.italic: true }

    Rectangle {
        color: "#34495e"       // background color
        radius: 6              // rounded corners
        border.color: "#2c3e50"
        border.width: 1
        anchors.margins: 4
        height: label1.implicitHeight + 8
        width: label1.implicitWidth + 16

        QGCLabel {
            id: label1
            text: qsTr("Photo Count")
            anchors.centerIn: parent
            font.italic: true
            color: "white"
        }
    }

    QGCLabel { text: missionItem.cameraShots }

    //QGCLabel { text: qsTr("Photo Interval"); font.italic: true }

    Rectangle {
        color: "#34495e"       // background color
        radius: 6              // rounded corners
        border.color: "#2c3e50"
        border.width: 1
        anchors.margins: 4
        height: label3.implicitHeight + 8
        width: label3.implicitWidth + 16

        QGCLabel {
            id: label3
            text: qsTr("Photo Interval")
            anchors.centerIn: parent
            font.italic: true
            color: "white"
        }
    }

    QGCLabel { text: missionItem.timeBetweenShots.toFixed(1) + " " + qsTr("secs") }

    //QGCLabel { text: qsTr("Trigger Distance"); font.italic: true }

    Rectangle {
        color: "#34495e"       // background color
        radius: 6              // rounded corners
        border.color: "#2c3e50"
        border.width: 1
        anchors.margins: 4
        height: label4.implicitHeight + 8
        width: label4.implicitWidth + 16

        QGCLabel {
            id: label4
            text: qsTr("Trigger Distance")
            anchors.centerIn: parent
            font.italic: true
            color: "white"
        }
    }

    QGCLabel { text: missionItem.cameraCalc.adjustedFootprintFrontal.valueString + " " + missionItem.cameraCalc.adjustedFootprintFrontal.units }
}
