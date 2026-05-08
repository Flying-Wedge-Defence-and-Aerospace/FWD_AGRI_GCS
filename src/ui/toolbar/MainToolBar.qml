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
    color:  /*qgcPal.toolbarBackground*//*_mainStatusBGColor*/ "#800000"
    signal toolSelectClicked
    signal logOutRequested

    property int currentToolbar: planViewToolbar
    property bool planViewVisible: false

    // Visibility toggle properties
    property bool telemetryVisible: true
    property bool hudVisible: true
    property bool toolStripVisible: true
    property bool videoVisible: true

    readonly property int flyViewToolbar:   1
    readonly property int planViewToolbar:  0
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

    Component {
        id: flightModeMenu

        Rectangle {
            width:          flickable.width + (ScreenTools.defaultFontPixelWidth * 2)
            height:         flickable.height + (ScreenTools.defaultFontPixelWidth * 2)
            radius:         ScreenTools.defaultFontPixelHeight * 0.5
            color:          qgcPal.window
            border.color:   qgcPal.text

            QGCFlickable {
                id:                     flickable
                anchors.margins:        ScreenTools.defaultFontPixelWidth
                anchors.top:            parent.top
                anchors.left:           parent.left
                width:                  mainLayout.width
                height:                 _fullWindowHeight <= mainLayout.height ? _fullWindowHeight : mainLayout.height
                flickableDirection:     Flickable.VerticalFlick
                contentHeight:          mainLayout.height
                contentWidth:           mainLayout.width

                property real _fullWindowHeight: mainWindow.contentItem.height - (indicatorPopup.padding * 2) - (ScreenTools.defaultFontPixelWidth * 2)

                ColumnLayout {
                    id:         mainLayout
                    spacing:    ScreenTools.defaultFontPixelWidth / 2

                    Repeater {
                        model: _activeVehicle ? _activeVehicle.flightModes : []

                        QGCButton {
                            text:               modelData
                            backRadius:         7
                            Layout.fillWidth:   true
                            onClicked: {
                                _activeVehicle.flightMode = text
                                mainWindow.hideIndicatorPopup()
                            }
                        }
                    }
                }
            }
        }
    }

    QGCPalette { id: qgcPal }

    QGCColoredImage {
        id: mainLogo
        height:                     ScreenTools.isMobile ? ScreenTools.defaultFontPixelHeight * 7 : ScreenTools.defaultFontPixelHeight * 9
        width:                      height + ScreenTools.defaultFontPixelHeight * 1.5
        source:                     "/res/FWD_logo"
        color:                      "white"
        anchors.left:   parent.left
        anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 2
        anchors.verticalCenter:     parent.verticalCenter
    }

    QGCFlickable {
        id: toolsFlickable
        anchors.left: mainLogo.right
        anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 3
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        //anchors.right:          parent.right
        width: ScreenTools.defaultFontPixelWidth * 23
        contentWidth:           indicatorLoader.item ? indicatorLoader.implicitWidth : 0
        flickableDirection:     Flickable.HorizontalFlick
        visible: ScreenTools.isMobile && currentToolbar === flyViewToolbar

        Loader {
            id:                 indicatorLoader
            anchors.left:       parent.left
            anchors.top:        parent.top
            anchors.bottom:     parent.bottom
            source:             /*currentToolbar === flyViewToolbar ?*/
                                    "qrc:/toolbar/MainToolBarIndicators.qml" /*:
                                    (currentToolbar == planViewToolbar ? "qrc:/qml/PlanToolBarIndicators.qml" : "")*/
        }
    }

    RowLayout {
        id:                     viewButtonRow
        anchors.left:   mainLogo.right
        anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 2.5
        anchors.top:    parent.top
        anchors.bottom: parent.bottom

        Item {
            id: planIndicatorsSlot
            Layout.preferredWidth: 120
            Layout.preferredHeight: viewButtonRow.height
            //visible: planViewVisible

            Loader {
                id: planIndicatorsLoader
                anchors.fill: parent
                source: currentToolbar === planViewToolbar
                          ? "qrc:/qml/PlanToolBarIndicators.qml"
                          : ""
            }
        }
    }

    RowLayout {
        id:             toolsRightLayout
        anchors.right:  parent.right
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        spacing:        ScreenTools.isMobile ? 0 : ScreenTools.defaultFontPixelWidth * 2.5
        visible: /*currentToolbar === flyViewToolbar &&*/ ScreenTools.isMobile === false

        Loader {
            id:                     mvsd
            Layout.fillHeight:      true
            Layout.alignment:       Qt.AlignHCenter | Qt.AlignVCenter
            Layout.preferredWidth:  item ? item.implicitWidth : 0
            Layout.preferredHeight: item ? item.implicitHeight : 0
            source:                 "qrc:/toolbar/MultiVehicleSelector.qml"
            visible:                QGroundControl.multiVehicleManager.vehicles.count >= 2
        }

        Rectangle {
            Layout.preferredHeight: parent.height * 0.8
            Layout.alignment: Qt.AlignVCenter
            width: ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth * 0.1 : ScreenTools.defaultFontPixelWidth * 0.2
        }

        QGCColoredImage {
            id:                     linkButton
            Layout.fillHeight:      true
            Layout.alignment:       Qt.AlignHCenter | Qt.AlignVCenter
            Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * 4
            source:                 "/res/con_icon"
            color:                  "white"
            fillMode:               Image.PreserveAspectFit

            QGCMouseArea {
                id: linkButtonMouseArea
                anchors.fill: parent
                onClicked: mainWindow.showCommLinksSettings()
            }
        }

        Rectangle {
            Layout.preferredHeight: parent.height * 0.8
            Layout.alignment: Qt.AlignVCenter
            width: ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth * 0.1 : ScreenTools.defaultFontPixelWidth * 0.2
        }


        Loader {
            id:                     batteryIndicatorLoader
            Layout.fillHeight:      true
            Layout.alignment:       Qt.AlignHCenter | Qt.AlignVCenter
            Layout.preferredWidth:  item ? item.implicitWidth : 0
            Layout.preferredHeight: item ? item.implicitHeight : 0
            source:                 "qrc:/toolbar/BatteryIndicator.qml"
        }

        Rectangle {
            Layout.preferredHeight: parent.height * 0.8
            Layout.alignment: Qt.AlignVCenter
            width: ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth * 0.1 : ScreenTools.defaultFontPixelWidth * 0.2
        }

        Loader {
            id:                     gpsIndicatorLoader1
            Layout.fillHeight:      true
            Layout.alignment:       Qt.AlignHCenter | Qt.AlignVCenter
            Layout.preferredWidth:  item ? item.implicitWidth : 0
            Layout.preferredHeight: item ? item.implicitHeight : 0
            source:                 "qrc:/toolbar/GPSIndicator.qml"
        }

        Rectangle {
            Layout.preferredHeight: parent.height * 0.8
            Layout.alignment: Qt.AlignVCenter
            width: ScreenTools.defaultFontPixelWidth * 0.2
        }

        ColumnLayout {
            id: statusModeLayout
            //spacing:
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            Layout.fillWidth: false

            Item {
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 0.1
                Layout.fillWidth: true
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredWidth: 120

                MainStatusIndicator {
                    anchors.centerIn: parent
                    Layout.fillHeight: true
                }
            }

            Item {
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 0.2
                Layout.fillWidth: true
            }

            QGCLabel {
                id:                 modeLabel
                //anchors.centerIn:   parent
                Layout.alignment: Qt.AlignHCenter
                text:               _activeVehicle ? _activeVehicle.flightMode : qsTr("N/A")
                color:              "white"
                font.pointSize:     ScreenTools.isMobile ? 8 : 11
                font.bold: true
                ToolTip.visible:    flightMode.containsMouse
                ToolTip.text:       "Mode"

                MouseArea {
                    id:             flightMode
                    anchors.fill:   parent
                    hoverEnabled:   true
                    onClicked: {
                        if (_activeVehicle) {
                            mainWindow.showIndicatorPopup(modeLabel, flightModeMenu, "top")
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.preferredHeight: parent.height * 0.8
            Layout.alignment: Qt.AlignVCenter
            width: ScreenTools.defaultFontPixelWidth * 0.2
            // Layout.alignment: Qt.AlignVCenter
        }

        Loader {
            id:                     messageIndicatorLoader
            Layout.fillHeight:      true
            Layout.alignment:       Qt.AlignHCenter | Qt.AlignVCenter
            Layout.preferredWidth:  item ? item.implicitWidth : 0
            Layout.preferredHeight: item ? item.implicitHeight : 0
            source:                 "qrc:/toolbar/MessageIndicator.qml"
        }

        Rectangle {
            Layout.preferredHeight: parent.height * 0.8
            Layout.alignment: Qt.AlignVCenter
            width: ScreenTools.defaultFontPixelWidth * 0.2
        }

        QGCColoredImage {
            id: settingsButton
            height: parent.height * 0.6
            width: ScreenTools.defaultFontPixelWidth * 4
            //Layout.leftMargin: -15
            source: "/res/hb_icon"

            QGCMouseArea {
                anchors.fill: parent
                onClicked: mainWindow.settingsDrawer.visible = !mainWindow.settingsDrawer.visible
            }
        }

        Item {
            Layout.fillWidth: true
        }
    }

    RowLayout {
        id:             toolsRightLayoutAnd
        anchors.right:  parent.right
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        spacing:        ScreenTools.defaultFontPixelWidth * 2
        visible: currentToolbar === flyViewToolbar && ScreenTools.isMobile === true

        Rectangle {
            Layout.preferredHeight: parent.height * 0.8
            Layout.alignment: Qt.AlignVCenter
            width: ScreenTools.defaultFontPixelWidth * 0.1
            opacity: 0.5
            visible: mvs.visible
        }

        Loader {
            id:                     mvs
            Layout.fillHeight:      true
            Layout.alignment:       Qt.AlignHCenter | Qt.AlignVCenter
            Layout.preferredWidth:  item ? item.implicitWidth : 0
            Layout.preferredHeight: item ? item.implicitHeight : 0
            source:                 "qrc:/toolbar/MultiVehicleSelector.qml"
            visible:                QGroundControl.multiVehicleManager.vehicles.count >= 2
        }

        Rectangle {
            Layout.preferredHeight: parent.height * 0.8
            Layout.alignment: Qt.AlignVCenter
            width: ScreenTools.defaultFontPixelWidth * 0.1
            opacity: 0.5
        }

        QGCColoredImage {
            id:                     linkButton1
            Layout.fillHeight:      true
            Layout.alignment:       Qt.AlignHCenter | Qt.AlignVCenter
            Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * 4
            source:                 "/res/con_icon"
            color:                  "white"
            fillMode:               Image.PreserveAspectFit

            QGCMouseArea {
                id: linkButtonMouseArea1
                anchors.fill: parent
                onClicked: mainWindow.showCommLinksSettings()
            }
        }

        Rectangle {
            Layout.preferredHeight: parent.height * 0.8
            Layout.alignment: Qt.AlignVCenter
            width: ScreenTools.defaultFontPixelWidth * 0.1
            opacity: 0.5
        }

        Loader {
            id:                     batteryIndicatorLoaderAnd
            Layout.fillHeight:      true
            Layout.alignment:       Qt.AlignHCenter | Qt.AlignVCenter
            Layout.preferredWidth:  item ? item.implicitWidth : 0
            Layout.preferredHeight: item ? item.implicitHeight : 0
            source:                 "qrc:/toolbar/BatteryIndicator.qml"
        }

        Rectangle {
            Layout.preferredHeight: parent.height * 0.8
            Layout.alignment: Qt.AlignVCenter
            width: ScreenTools.defaultFontPixelWidth * 0.1
            opacity: 0.5
        }

        Loader {
            id:                     gpsIndicatorLoader2
            Layout.fillHeight:      true
            Layout.alignment:       Qt.AlignHCenter | Qt.AlignVCenter
            Layout.preferredWidth:  item ? item.implicitWidth : 0
            Layout.preferredHeight: item ? item.implicitHeight : 0
            source:                 "qrc:/toolbar/GPSIndicator.qml"
        }

        Rectangle {
            Layout.preferredHeight: parent.height * 0.8
            Layout.alignment: Qt.AlignVCenter
            width: ScreenTools.defaultFontPixelWidth * 0.1
            opacity: 0.5
        }

        QGCLabel {
            id:                 modeLabel1
            //anchors.centerIn:   parent
            Layout.alignment: Qt.AlignVCenter
            text:               _activeVehicle ? _activeVehicle.flightMode : qsTr("N/A")
            color:              "white"
            font.pointSize:     ScreenTools.isMobile ? 9 : 11
            font.bold: true
            ToolTip.visible:    flightMode.containsMouse
            ToolTip.text:       "Mode"

            MouseArea {
                id:             flightMode1
                anchors.fill:   parent
                hoverEnabled:   true
                onClicked: {
                    if (_activeVehicle) {
                        mainWindow.showIndicatorPopup(modeLabel, flightModeMenu)
                    }
                }
            }
        }

        Rectangle {
            Layout.preferredHeight: parent.height * 0.8
            Layout.alignment: Qt.AlignVCenter
            width: ScreenTools.defaultFontPixelWidth * 0.1
            opacity: 0.5
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredWidth: 150

            MainStatusIndicator {
                anchors.centerIn: parent
                Layout.fillHeight: true
            }
        }

        Rectangle {
            Layout.preferredHeight: parent.height * 0.8
            Layout.alignment: Qt.AlignVCenter
            width: ScreenTools.defaultFontPixelWidth * 0.1
            opacity: 0.5
        }

        Loader {
            id:                     messageIndicatorLoader1
            Layout.fillHeight:      true
            Layout.alignment:       Qt.AlignHCenter | Qt.AlignVCenter
            Layout.preferredWidth:  item ? item.implicitWidth : 0
            Layout.preferredHeight: item ? item.implicitHeight : 0
            source:                 "qrc:/toolbar/MessageIndicator.qml"
        }

        Rectangle {
            Layout.preferredHeight: parent.height * 0.8
            Layout.alignment: Qt.AlignVCenter
            width: ScreenTools.defaultFontPixelWidth * 0.1
            opacity: 0.5
        }

        QGCColoredImage {
            //id: settingsButton
            height: parent.height * 0.6
            width: ScreenTools.defaultFontPixelWidth * 4
            //Layout.leftMargin: -15
            source: "/res/hb_icon"
            //logo: true

            QGCMouseArea {
                anchors.fill: parent
                onClicked: mainWindow.settingsDrawer.visible = !mainWindow.settingsDrawer.visible
            }
        }

        Item {
            Layout.fillWidth: true
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
