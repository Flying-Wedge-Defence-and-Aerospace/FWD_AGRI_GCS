/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.12
import QtQuick.Controls 2.4
import QtQuick.Layouts  1.11
import QtQuick.Dialogs  1.3

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.Palette               1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Controllers           1.0

Rectangle {
    id:     _root
    color:  /*qgcPal.toolbarBackground*//*_mainStatusBGColor*/ "#2c3e50"
    // border.width: 1
    // border.color: "white"
    signal toolSelectClicked  
    signal logOutRequested

    property int currentToolbar: planViewToolbar

    readonly property int flyViewToolbar:   0
    readonly property int planViewToolbar:  1
    readonly property int simpleToolbar:    2

    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property bool   _communicationLost: _activeVehicle ? _activeVehicle.vehicleLinkManager.communicationLost : false
    property color  _mainStatusBGColor: qgcPal.brandingPurple

    property string userName: ""

    function dropMessageIndicatorTool() {
        if (currentToolbar === flyViewToolbar) {
            indicatorLoader.item.dropMessageIndicatorTool();
        }
    }

    QGCPalette { id: qgcPal }

    /// Bottom single pixel divider
    Rectangle {
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.bottom: parent.bottom
        height:         1
        //color:          "black"
        visible:        qgcPal.globalTheme === QGCPalette.Light
    }


    // RowLayout {
    //     id:                     viewButtonRow
    //     anchors.top:            parent.top
    //     anchors.bottom:         parent.bottom
    //     anchors.left:           parent.left
    //     anchors.right:          parent.right
    //     anchors.bottomMargin:   1
    //     spacing:                ScreenTools.defaultFontPixelWidth / 2

    //     // Left logo button
    //     QGCToolBarButton {
    //         id:                     currentButton
    //         Layout.preferredHeight: viewButtonRow.height
    //         icon.source:            "/res/FWD_only_logo"
    //         // anchors.left: parent.left
    //         // anchors.leftMargin: 15
    //         Layout.alignment:       Qt.AlignVCenter | Qt.AlignLeft
    //         Layout.leftMargin:      15
    //         logo:                   true
    //     }

    //     QGCFlickable {
    //         id: toolsFlickable
    //         anchors.leftMargin:     ScreenTools.defaultFontPixelWidth * ScreenTools.largeFontPointRatio * 1.5
    //         anchors.left:           currentButton.right
    //         anchors.bottomMargin:   1
    //         anchors.top:            parent.top
    //         anchors.bottom:         parent.bottom
    //         anchors.right:          parent.right
    //         contentWidth:           indicatorLoader.x + indicatorLoader.width
    //         flickableDirection:     Flickable.HorizontalFlick

    //         Loader {
    //             id:                 indicatorLoader
    //             anchors.left:       parent.left
    //             anchors.top:        parent.top
    //             anchors.bottom:     parent.bottom
    //             source:             (currentToolbar == planViewToolbar ? "qrc:/qml/PlanToolBarIndicators.qml" : "")
    //         }
    //     }

    //     // Flexible spacer before the center text
    //     // Item {
    //     //     Layout.fillWidth: true
    //     // }

    //     // Center text
    //     QGCLabel {
    //         text: "FWD AGRI GCS"
    //         font.bold: true
    //         font.pointSize: ScreenTools.largeFontPointSize
    //         color: "white"
    //         //Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
    //     }

    //     // Flexible spacer after the center text
    //     Item {
    //         Layout.fillWidth: true
    //     }

    //     QGCToolBarButton {
    //         id: profileIcon
    //         Layout.preferredWidth: viewButtonRow.height
    //         icon.source: "/res/profile_icon"
    //         logo: true
    //         Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
    //         // onClicked: mainWindow.showProfilePage()
    //         Layout.leftMargin: 10

    //         onClicked: {
    //             if (settingsPopup.visible) {
    //                 settingsPopup.close()
    //             } else {
    //                 settingsPopup.open()
    //             }
    //         }
    //     }

    //     // Right settings button
    //     QGCToolBarButton {
    //         id: settingsButton
    //         Layout.preferredHeight: viewButtonRow.height
    //         icon.source:            "/res/settings_icon"
    //         logo:                   true
    //         onClicked:              mainWindow.showSettingsPage()
    //         Layout.alignment:       Qt.AlignVCenter | Qt.AlignLeft
    //         //Layout.leftMargin:      15
    //         // anchors.right: parent.right
    //         // anchors.rightMargin: 15
    //     }
    // }

    RowLayout {
        id:                     viewButtonRow
        anchors.fill:           parent
        anchors.bottomMargin:   1
        spacing:                ScreenTools.defaultFontPixelWidth / 2

        // Left logo
        QGCToolBarButton {
            id: currentButton
            Layout.preferredHeight: viewButtonRow.height
            icon.source: "/res/FWD_only_logo"
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            Layout.leftMargin: 15
            logo: true
        }

        // Fixed slot for plan indicators
        Item {
            id: planIndicatorsSlot
            Layout.preferredWidth: 120   // <-- set a fixed width big enough for PlanToolBarIndicators
            Layout.preferredHeight: viewButtonRow.height

            Loader {
                id: planIndicatorsLoader
                anchors.fill: parent
                source: currentToolbar === planViewToolbar
                          ? "qrc:/qml/PlanToolBarIndicators.qml"
                          : ""
            }
        }

        // Flexible spacer before center text
        Item { Layout.fillWidth: true }

        // Center label (always at same place)
        QGCLabel {
            text: "FWD DKS GCS"
            font.bold: true
            font.pointSize: ScreenTools.largeFontPointSize
            color: "white"
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
        }

        // Flexible spacer after center text
        Item { Layout.fillWidth: true }

        // Profile icon
        QGCToolBarButton {
            id: profileIcon
            Layout.preferredWidth: viewButtonRow.height
            icon.source: "/res/profile_icon"
            visible: currentToolbar === planViewToolbar
            logo: true
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            Layout.leftMargin: 10

            onClicked: {
                if (settingsPopup.visible) {
                    settingsPopup.close()
                } else {
                    settingsPopup.open()
                }
            }
        }

        // Right settings button
        QGCToolBarButton {
            id: settingsButton
            Layout.preferredHeight: viewButtonRow.height
            icon.source: "/res/settings_icon"
            logo: true
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            onClicked: mainWindow.showSettingsPage()
        }
    }


    Popup {
        id: settingsPopup
        x: settingsButton.x - 150   // position below the button
        y: settingsButton.y + settingsButton.height
        width: 180
        modal: false
        focus: true

        background: Rectangle {
            color: "#2c3e50"
            radius: 8
            border.color: "white"
            border.width: 1
        }

        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 15
            anchors.horizontalCenter: parent.horizontalCenter

            QGCLabel {
                text: "Pilot Details"
                anchors.horizontalCenter: parent.horizontalCenter
                color: "yellow"

            }

            Row {
                spacing: 15
                anchors.horizontalCenter: parent.horizontalCenter
                QGCLabel {
                    text: "Username:"
                    color: "white"
                    font.bold: true
                }
                QGCLabel {
                    text: userName
                    color: "white"
                }
            }

            // QGCButton {
            //     text: "Logout"
            //     backRadius: 7
            //     anchors.horizontalCenter: parent.horizontalCenter
            //     onClicked: {
            //         console.log("Logout clicked")
            //         settingsPopup.close()
            //         if(currentToolbar === planViewToolbar) {
            //             logOutRequested()
            //         } else {
            //             console.log("Go to plan view for logout")
            //         }
            //     }
            // }

            // QGCLabel {
            //     text: "If you want to logout Go to plan view and also there are no active vehicle connection"
            //     font.italic: true
            //     color: "yellow"
            //     font.pointSize: 10
            //     wrapMode: Text.WordWrap
            //     anchors.horizontalCenter: parent.horizontalCenter
            //     width: parent.width - 20  // subtract margins
            // }

        }
    }

    // Large parameter download progress bar
    Rectangle {
        id:             largeProgressBar
        anchors.bottom: parent.bottom
        anchors.left:   parent.left
        anchors.right:  parent.right
        height:         parent.height
        color:          qgcPal.window
        visible:        _showLargeProgress

        property bool _initialDownloadComplete: _activeVehicle ? _activeVehicle.initialConnectComplete : true
        property bool _userHide:                false
        property bool _showLargeProgress:       !_initialDownloadComplete && !_userHide && qgcPal.globalTheme === QGCPalette.Light

        Connections {
            target:                 QGroundControl.multiVehicleManager
            function onActiveVehicleChanged(activeVehicle) { largeProgressBar._userHide = false }
        }

        Rectangle {
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            width:          _activeVehicle ? _activeVehicle.loadProgress * parent.width : 0
            color:          qgcPal.colorGreen
        }

        QGCLabel {
            anchors.centerIn:   parent
            text:               qsTr("Downloading")
            font.pointSize:     ScreenTools.largeFontPointSize
        }

        QGCLabel {
            anchors.margins:    _margin
            anchors.right:      parent.right
            anchors.bottom:     parent.bottom
            text:               qsTr("Click anywhere to hide")

            property real _margin: ScreenTools.defaultFontPixelWidth / 2
        }

        MouseArea {
            anchors.fill:   parent
            onClicked:      largeProgressBar._userHide = true
        }
    }
}
