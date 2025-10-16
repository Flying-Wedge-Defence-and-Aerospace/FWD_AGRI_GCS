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

    signal changeMessageIcon

    property int messageCount: 0
    property bool showDetailsChecked: false

    // property bool isMessageImportant: _activeVehicle
    //                                   ? !_activeVehicle.messageTypeNormal && !_activeVehicle.messageTypeNone
    //                                   : false

    property bool isMessageImportant: _activeVehicle
        ? (_activeVehicle.messageTypeError || _activeVehicle.messageTypeWarning)
        : false


    property bool showMessages: false

    function dropMessageIndicator() {
        mainWindow.showIndicatorPopup(root, vehicleMessagesPopup)
        root.messageCount = 0   // reset badge count
    }

    function formatMessage(message) {
        message = message.replace(new RegExp("<#E>", "g"), "color: " + qgcPal.warningText + "; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        message = message.replace(new RegExp("<#I>", "g"), "color: " + qgcPal.warningText + "; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        message = message.replace(new RegExp("<#N>", "g"), "color: " + qgcPal.text + "; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        return message;
    }

    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        radius: 8
        color: "black"
        border.width: 1
        border.color: "white"

        // Icon switches based on important message & message count
        Image {
            id: messsageIcon
            anchors.fill: parent
            anchors.margins: 6
            fillMode: Image.PreserveAspectFit
            // source: (root.messageCount > 0 && isMessageImportant)
            //             ? "/qmlimages/Yield.svg" : "/res/message_icon"
            source: isMessageImportant
                    ? "/qmlimages/Yield.svg"
                    : "/res/message_icon"

            ToolTip.visible: message.containsMouse
            ToolTip.text: "Messages"

            MouseArea {
                id: message
                anchors.fill: parent
                hoverEnabled: true
            }

        }

        // Badge for message count
        Rectangle {
            id: badge
            width: parent.width * 0.45
            height: width
            radius: width / 2
            color: "red"
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: -4
            visible: messageCount > 0

            QGCLabel {
                anchors.centerIn: parent
                text: messageCount > 99 ? "99+" : messageCount
                color: "white"
                font.pixelSize: Math.max(8, parent.width * 0.4)
                font.bold: true
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                dropMessageIndicator()
                if(isMessageImportant) {
                    isMessageImportant = false
                    changeMessageIcon()
                }
            }
        }
    }

    // Listen for new messages and increment count starting from 1
    Connections {
        target: _activeVehicle
        onNewFormattedMessage: {
            // Only increment if user has already cleared messages
            if (root.messageCount === 0) {
                root.messageCount = 1
            } else {
                root.messageCount += 1
            }
        }
    }

    Component {
        id: vehicleMessagesPopup

        Rectangle {
            width: mainWindow.width * 0.5
            height: mainWindow.height * 0.66
            radius: ScreenTools.defaultFontPixelHeight / 2
            color: "#2c3e50"
            border.color: qgcPal.text

            QGCLabel {
                anchors.centerIn:   parent
                text:               qsTr("No Messages")
                visible:            messageText.length === 0
            }

            QGCColoredImage {
                id: deleteButton
                anchors.bottom:     parent.bottom
                anchors.right:      parent.right
                anchors.margins:    ScreenTools.defaultFontPixelHeight * 0.5
                height:             ScreenTools.isMobile ? ScreenTools.defaultFontPixelHeight * 1.5 : ScreenTools.defaultFontPixelHeight
                width:              height
                sourceSize.height:   height
                source:             "/res/TrashDelete.svg"
                fillMode:           Image.PreserveAspectFit
                mipmap:             true
                smooth:             true
                color:              qgcPal.text
                visible:            messageText.length !== 0
                MouseArea {
                    anchors.fill:   parent
                    onClicked: {
                        if (_activeVehicle) {
                            _activeVehicle.clearMessages()
                            mainWindow.hideIndicatorPopup()
                        }
                    }
                }
            }

            RowLayout {
                id: bottomRow
                anchors.bottom: parent.bottom
                anchors.right: deleteButton.left
                //anchors.margins: ScreenTools.defaultFontPixelHeight * 0.5
                anchors.bottomMargin: 3
                anchors.rightMargin: 15
                spacing: 10

                // Radio button + label grouped
                RowLayout {
                    spacing: 5
                    Layout.alignment: Qt.AlignVCenter

                    QGCLabel {
                        text: qsTr("Live Messages")
                        color: qgcPal.text
                        Layout.alignment: Qt.AlignVCenter
                    }

                    // QGCRadioButton {
                    //     id: details
                    //     checked: false
                    //     Layout.alignment: Qt.AlignVCenter

                    //     onCheckedChanged: root.showMessages = checked
                    // }

                    QGCRadioButton {
                        id: details
                        checked: showDetailsChecked
                        Layout.alignment: Qt.AlignVCenter

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                details.checked = !details.checked  // toggle on each click
                                showDetailsChecked = details.checked
                            }
                        }

                        onCheckedChanged: root.showMessages = checked
                    }
                }
            }

            FactPanelController {
                id: controller
            }

            QGCFlickable {
                id: messageFlick
                anchors.margins:    ScreenTools.defaultFontPixelHeight
                anchors.fill: parent
                contentWidth: messageText.width
                contentHeight: messageText.height
                pixelAligned:       true

                TextEdit {
                    id: messageText
                    readOnly: true
                    textFormat: TextEdit.RichText
                    color: qgcPal.text
                    selectByMouse: true
                    selectionColor:     qgcPal.text
                    selectedTextColor:  qgcPal.window
                    property var fact:  null

                    onLinkActivated: {
                        if (link.startsWith('param://')) {
                            var paramName = link.substr(8);
                            fact = controller.getParameterFact(-1, paramName, true)
                            if (fact != null) {
                                paramEditorDialogComponent.createObject(mainWindow).open()
                            }
                        } else {
                            Qt.openUrlExternally(link);
                        }
                    }
                }

                Component {
                    id: paramEditorDialogComponent

                    ParameterEditorDialog {
                        title:          qsTr("Edit Parameter")
                        fact:           messageText.fact
                        destroyOnClose: true
                    }
                }

            }

            Component.onCompleted: {
                if (_activeVehicle) {
                    messageText.text = formatMessage(_activeVehicle.formattedMessages)
                    for (var i = 0; i < _activeVehicle.messageCount; i++)
                        messageFlick.flick(0,-5000)
                }
            }

            Connections {
                target: _activeVehicle
                onNewFormattedMessage: {
                    messageText.append(formatMessage(formattedMessage))
                    root.messageCount = root.messageCount === 0 ? 1 : root.messageCount + 1
                    messageFlick.flick(0,-500)
                }
            }
        }
    }
}

