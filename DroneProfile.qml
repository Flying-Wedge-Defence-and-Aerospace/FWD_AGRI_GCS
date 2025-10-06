import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Dialogs          1.2
import QtQuick.Layouts          1.2

import QGroundControl                       1.0
import QGroundControl.FactSystem            1.0
import QGroundControl.FactControls          1.0
import QGroundControl.Controls              1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.Palette               1.0
import QGroundControl.Controllers           1.0
import QGroundControl.SettingsManager       1.0

Rectangle {
    id: droneProfile
    color: qgcPal.window

    readonly property real _defaultTextHeight: ScreenTools.defaultFontPixelHeight
    readonly property real _defaultTextWidth: ScreenTools.defaultFontPixelWidth
    readonly property real _horizontalMargin: _defaultTextWidth / 2
    readonly property real _verticalMargin: _defaultTextHeight / 2
    readonly property real _buttonHeight: ScreenTools.isTinyScreen ? ScreenTools.defaultFontPixelHeight * 3 : ScreenTools.defaultFontPixelHeight * 2

    property real   _comboFieldWidth:           ScreenTools.defaultFontPixelWidth * 30

    property var    _videoSettings:             QGroundControl.settingsManager.videoSettings

    QGCPalette { id: qgcpal }

    Rectangle {
        id: innerRect
        width: 800
        height: 800
        color: qgcPal.window
        // color: "blue"
        anchors.centerIn: parent

        ColumnLayout {

            anchors.centerIn: parent
            spacing: 30

            RowLayout {
                id: formLayout
                spacing: 50

                QGCLabel {
                    id: typeLabel
                    text: qsTr("Drone Type")
                }

                FactComboBox {
                    id: droneSource
                    width: 300
                    model: ["Agri Drone", "Killer Drone", "Surveillance Drone"]
                    onCurrentIndexChanged: updateSubCombo()
                }
            }

                RowLayout {
                    spacing: 50

                    QGCLabel {
                        text: qsTr("Sub Drones")
                    }

                    FactComboBox {
                        id: subCombo
                        width: 300
                        model: []
                    }
                }

                function updateSubCombo() {
                    var droneType = droneSource.currentText.trim();
                    if (droneType === "Agri Drone") {
                        subCombo.model = ["a", "b", "c"];
                    } else if (droneType === "Killer Drone") {
                        subCombo.model = ["d", "e", "f"];
                    } else if (droneType === "Surveillance Drone") {
                        subCombo.model = ["g", "h", "i"];
                    } else {
                        subCombo.model = [];
                    }
                }

                Component.onCompleted: updateSubCombo()


            RowLayout{
                id: droneSpecLayout
                spacing: 20
                Rectangle {
                    width: 300
                    height: 500
                    color: "gray"
                }

                Rectangle {
                    width: 300
                    height: 500
                    color: "gray"
                }

                Rectangle {
                    width: 300
                    height: 500
                    color: "gray"
                }

            }
        }
    }
}

