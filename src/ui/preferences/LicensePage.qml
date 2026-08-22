/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

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

Rectangle {
    id:             licenseRoot
    color:          qgcPal.window
    anchors.fill:   parent

    property real _labelWidth:          ScreenTools.defaultFontPixelWidth * 35
    property real _valueWidth:          ScreenTools.defaultFontPixelWidth * 24
    property real _columnSpacing:       ScreenTools.defaultFontPixelHeight * 1
    property var  _activeVehicle:       QGroundControl.multiVehicleManager.activeVehicle
    property bool _licenseRequired:     false
    property string _promptStatus:      ""

    Connections {
        target: QGroundControl.multiVehicleManager
        onActiveVehicleChanged: {
            _licenseRequired = false
            _promptStatus = ""
            if (QGroundControl.multiVehicleManager.activeVehicle) {
                QGroundControl.multiVehicleManager.activeVehicle.licenseRequired.connect(function(uid) {
                    _licenseRequired = true
                })
                QGroundControl.multiVehicleManager.activeVehicle.licenseError.connect(function(msg) {
                    _promptStatus = msg
                })
                QGroundControl.multiVehicleManager.activeVehicle.licenseActivated.connect(function(uid) {
                    _promptStatus = qsTr("License activated for ") + uid
                    _licenseRequired = false
                })
            }
        }
    }

    Connections {
        target: QGroundControl.licenseManager
        onActivationSucceeded: {
            QGroundControl.startMavlinkConnections()
        }
    }

    QGCPalette { id: qgcPal }

    QGCFlickable {
        clip:               true
        anchors.fill:       parent
        anchors.margins:    ScreenTools.defaultFontPixelWidth
        contentHeight:      settingsColumn.height
        contentWidth:       settingsColumn.width
        flickableDirection: Flickable.VerticalFlick

        Column {
            id:                 settingsColumn
            width:              licenseRoot.width
            spacing:            ScreenTools.defaultFontPixelHeight * 0.5
            anchors.margins:    ScreenTools.defaultFontPixelWidth

            //-- License Activation Section
            Item {
                width:              ScreenTools.defaultFontPixelWidth * 75
                height:             activateLabel.height
                anchors.horizontalCenter: parent.horizontalCenter
                QGCLabel {
                    id:             activateLabel
                    text:           qsTr("License Activation")
                    font.family:    ScreenTools.demiboldFontFamily
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            Rectangle {
                height:         activateColumn.height + (ScreenTools.defaultFontPixelHeight * 2)
                width:          ScreenTools.defaultFontPixelWidth * 75
                color:          "transparent"
                radius: 6
                border.color:   "#888"
                anchors.horizontalCenter: parent.horizontalCenter
                ColumnLayout {
                    id:         activateColumn
                    spacing:    _columnSpacing
                    anchors.centerIn: parent

                    RowLayout {
                        spacing: ScreenTools.defaultFontPixelWidth
                        QGCLabel {
                            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                            text: qsTr("License Key (96 characters):")
                        }
                        QGCTextField {
                            id:                     licenseKeyField
                            Layout.fillWidth:       true
                            Layout.preferredWidth:  _valueWidth * 2
                            inputMethodHints:       Qt.ImhNoAutoUppercase
                        }
                        QGCButton {
                            text:   qsTr("Activate")
                            enabled: licenseKeyField.text.length === 96
                            onClicked: {
                                QGroundControl.licenseManager.activate(licenseKeyField.text)
                                licenseKeyField.text = ""
                                droneRepeater.update()
                            }
                        }
                    }

                    QGCLabel {
                        id:         statusLabel
                        text:       qsTr("Enter a 96-character license key and press Activate.")
                        color:      qgcPal.text
                    }
                }
            }

            //-- Activated Drones Section
            Item {
                width:              ScreenTools.defaultFontPixelWidth * 75
                height:             droneListLabel.height
                anchors.horizontalCenter: parent.horizontalCenter
                QGCLabel {
                    id:             droneListLabel
                    text:           qsTr("Activated Drones")
                    font.family:    ScreenTools.demiboldFontFamily
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            Rectangle {
                height:         droneListColumn.height + (ScreenTools.defaultFontPixelHeight * 2)
                width:          ScreenTools.defaultFontPixelWidth * 75
                color:          "transparent"
                radius: 6
                border.color:   "#888"
                anchors.horizontalCenter: parent.horizontalCenter
                Column {
                    id:         droneListColumn
                    spacing:    _columnSpacing
                    anchors.centerIn: parent
                    width:      parent.width - (ScreenTools.defaultFontPixelWidth * 4)

                    Repeater {
                        id:     droneRepeater
                        model:  ListModel { id: licenseListModel }

                        function update() {
                            var licenses = QGroundControl.licenseManager.list()
                            licenseListModel.clear()
                            for (var i = 0; i < licenses.length; i++) {
                                licenseListModel.append({ boardUid: licenses[i][0], keyPreview: licenses[i][1] })
                            }
                        }

                        Component.onCompleted: update()

                        Rectangle {
                            width:  droneListColumn.width
                            height: droneRow.height + ScreenTools.defaultFontPixelHeight
                            color:  "transparent"
                            border.color: "#888"
                            border.width: 1
                            RowLayout {
                                id:         droneRow
                                spacing:    ScreenTools.defaultFontPixelWidth
                                anchors.centerIn: parent

                                QGCLabel {
                                    text:           qsTr("Board UID: %1").arg(boardUid)
                                    Layout.fillWidth: true
                                }
                                QGCLabel {
                                    text:           keyPreview
                                    color:          qgcPal.textFieldText
                                }
                                QGCButton {
                                    text:           qsTr("Remove")
                                    onClicked: {
                                        QGroundControl.licenseManager.remove(boardUid)
                                        droneRepeater.update()
                                    }
                                }
                            }
                        }
                    }

                    QGCLabel {
                        id:         emptyLabel
                        text:       qsTr("No licenses activated yet.")
                        visible:    licenseListModel.count === 0
                    }
                }
            }

            //-- Connection Prompt Section
            Item {
                width:              ScreenTools.defaultFontPixelWidth * 75
                height:             promptLabel.height
                anchors.horizontalCenter: parent.horizontalCenter
                visible:            _activeVehicle && _licenseRequired
                QGCLabel {
                    id:             promptLabel
                    text:           qsTr("License Required for Connected Drone")
                    font.family:    ScreenTools.demiboldFontFamily
                    font.bold: true
                    color:          qgcPal.warningText
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            Rectangle {
                height:         promptColumn.height + (ScreenTools.defaultFontPixelHeight * 2)
                width:          ScreenTools.defaultFontPixelWidth * 75
                color:          "transparent"
                radius: 6
                border.color:   qgcPal.warningText
                anchors.horizontalCenter: parent.horizontalCenter
                visible:        _activeVehicle && _licenseRequired
                ColumnLayout {
                    id:         promptColumn
                    spacing:    _columnSpacing
                    anchors.centerIn: parent

                    QGCLabel {
                        text: qsTr("Drone %1 requires a license to enable MAVLink signing. Enter your license key below.")
                            .arg(_activeVehicle ? _activeVehicle.boardUid : "")
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                    RowLayout {
                        spacing: ScreenTools.defaultFontPixelWidth
                        QGCTextField {
                            id:                     promptLicenseField
                            Layout.fillWidth:       true
                            inputMethodHints:       Qt.ImhNoAutoUppercase
                        }
                        QGCButton {
                            text:   qsTr("Activate & Connect")
                            enabled: promptLicenseField.text.length === 96
                            onClicked: {
                                _activeVehicle.activateAndConnectLicense(promptLicenseField.text)
                                promptLicenseField.text = ""
                            }
                        }
                    }
                    QGCLabel {
                        id:         promptStatusLabel
                        text:       _promptStatus
                        color:      _promptStatus.indexOf("activated") >= 0 ? "green" : qgcPal.warningText
                        wrapMode:   Text.WordWrap
                        Layout.fillWidth: true
                        visible:    _promptStatus.length > 0
                    }
                }
            }
        }
    }
}
