/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick          2.3
import QtQuick.Layouts  1.2
import QtQuick.Controls 2.0

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.FactSystem            1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0

//-------------------------------------------------------------------------
//-- Message Indicator
Item {
    id:             _root
    implicitHeight: ScreenTools.defaultFontPixelHeight * 2
    implicitWidth: implicitHeight
    //width:          height
    anchors.top:    parent.top
    anchors.bottom: parent.bottom

    function formatMessage(message) {
        message = message.replace(new RegExp("<#E>", "g"), "color: " + qgcPal.warningText + "; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        message = message.replace(new RegExp("<#I>", "g"), "color: " + qgcPal.warningText + "; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        message = message.replace(new RegExp("<#N>", "g"), "color: " + qgcPal.text + "; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        return message;
    }

    property bool showIndicator: true

    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property bool   _isMessageImportant:    _activeVehicle ? !_activeVehicle.messageTypeNormal && !_activeVehicle.messageTypeNone : false

    function dropMessageIndicator() {
        mainWindow.showIndicatorPopup(_root, vehicleMessagesPopup, "top");
    }

    function getMessageColor() {
        if (_activeVehicle) {
            if (_activeVehicle.messageTypeNone)
                return qgcPal.colorGrey
            if (_activeVehicle.messageTypeNormal)
                return qgcPal.colorBlue;
            if (_activeVehicle.messageTypeWarning)
                return qgcPal.colorOrange;
            if (_activeVehicle.messageTypeError)
                return qgcPal.colorRed;
            // Cannot be so make make it obnoxious to show error
            console.warn("MessageIndicator.qml:getMessageColor Invalid vehicle message type", _activeVehicle.messageTypeNone)
            return "purple";
        }
        //-- It can only get here when closing (vehicle gone while window active)
        return qgcPal.colorGrey
    }

    Image {
        id:                 criticalMessageIcon
        anchors.fill:       parent
        source:             "/qmlimages/Yield.svg"
        sourceSize.height:  height
        fillMode:           Image.PreserveAspectFit
        cache:              false
        visible:            _activeVehicle && _activeVehicle.messageCount > 0 && _isMessageImportant
    }

    QGCColoredImage {
        anchors.fill:       parent
        source:             "/res/message"
        sourceSize.height:  height
        fillMode:           Image.PreserveAspectFit
        color:              getMessageColor()
        visible:            !criticalMessageIcon.visible
    }

    MouseArea {
        anchors.fill:   parent
        onClicked:      dropMessageIndicator()
    }

    Component {
        id: vehicleMessagesPopup

        Rectangle {
            width:          mainWindow.width  * 0.500
            height:         mainWindow.height * 0.666
            radius:         ScreenTools.defaultFontPixelHeight / 2
            color:          qgcPal.window
            border.color:   qgcPal.text

            Component.onCompleted: {
                messageText.text = formatMessage(_activeVehicle.formattedMessages)
                //-- Hack to scroll to last message
                for (var i = 0; i < _activeVehicle.messageCount; i++)
                    messageFlick.flick(0,-5000)
                _activeVehicle.resetAllMessages()
            }

            Connections {
                target: _activeVehicle
                onNewFormattedMessage :{
                    messageText.append(formatMessage(formattedMessage))
                    //notificationPopup.showMessage(formattedMessage)
                    //-- Hack to scroll down
                    messageFlick.flick(0,-500)
                }
            }

            QGCLabel {
                anchors.centerIn:   parent
                text:               qsTr("No Messages")
                visible:            messageText.length === 0
            }

            QGCColoredImage {
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

            FactPanelController {
                id: controller
            }

            QGCFlickable {
                id:                 messageFlick
                anchors.margins:    ScreenTools.defaultFontPixelHeight
                anchors.fill:       parent
                contentHeight:      messageText.height
                contentWidth:       messageText.width
                pixelAligned:       true

                TextEdit {
                    id:                 messageText
                    readOnly:           true
                    textFormat:         TextEdit.RichText
                    //selectByMouse:      true
                    color:              qgcPal.text
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
        }
    }

    // ------------ For floating notifications ------------------

    // Popup {
    //     id: notificationPopup
    //     x: (mainWindow.width - width) / 3
    //     y: 40
    //     modal: false
    //     focus: false
    //     closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    //     visible: mainWindow.loggedIn

    //     width: contentCol.implicitWidth + 20
    //     height: contentCol.implicitHeight + 20

    //     background: Rectangle {
    //         color: qgcPal.window
    //         border.color: qgcPal.text
    //         radius: 6
    //     }

    //     Column {
    //         id: contentCol
    //         anchors.centerIn: parent
    //         spacing: 4

    //         QGCLabel {
    //             id: popupMessage
    //             text: ""
    //             textFormat: Text.RichText
    //             wrapMode: Text.Wrap
    //             color: qgcPal.text
    //             width: 300
    //         }
    //     }

    //     function showMessage(msg) {
    //         if (!mainWindow.loggedIn) {
    //                 return
    //             }
    //         popupMessage.text = msg
    //         open()
    //         Qt.createQmlObject(
    //             'import QtQuick 2.0; Timer { interval: 4000; running: true; repeat: false; onTriggered: notificationPopup.close(); }',
    //             notificationPopup
    //         )
    //     }
    // }

    // Connections {
    //     target: QGroundControl.multiVehicleManager
    //     onActiveVehicleChanged: {
    //         if (QGroundControl.multiVehicleManager.activeVehicle) {
    //             _activeVehicle = QGroundControl.multiVehicleManager.activeVehicle
    //         }
    //     }
    // }

    // Connections {
    //     target: _activeVehicle
    //     onNewFormattedMessage: function(message) {
    //         notificationPopup.showMessage(message)
    //     }
    // }
}
