// /****************************************************************************
//  *
//  * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
//  *
//  * QGroundControl is licensed according to the terms in the file
//  * COPYING.md in the root of the source code directory.
//  *
//  ****************************************************************************/

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
    id: _root
    anchors.fill: parent

    // These should only be used by MainRootWindow
    property var planController:    _planController
    property var guidedController:  _guidedController

    PlanMasterController {
        id:                     _planController
        flyView:                true
        Component.onCompleted:  start()
    }

    property bool   _mainWindowIsMap:       mapControl.pipState.state === mapControl.pipState.fullState
    property bool   _isFullWindowItemDark:  _mainWindowIsMap ? mapControl.isSatelliteMap : true
    property var    _activeVehicle:         QGroundControl.multiVehicleManager.activeVehicle
    property var    _missionController:     _planController.missionController
    property var    _geoFenceController:    _planController.geoFenceController
    property var    _rallyPointController:  _planController.rallyPointController
    property real   _margins:               ScreenTools.defaultFontPixelWidth / 2
    property var    _guidedController:      guidedActionsController
    property var    _guidedActionList:      guidedActionList
    property var    _guidedValueSlider:     guidedValueSlider
    property var    _widgetLayer:           widgetLayer
    property real   _toolsMargin:           ScreenTools.defaultFontPixelWidth * 0.75
    property rect   _centerViewport:        Qt.rect(0, 0, width, height)
    property real   _rightPanelWidth:       ScreenTools.defaultFontPixelWidth * 30
    property var    _mapControl:            mapControl

    property real   _fullItemZorder:    0
    property real   _pipItemZorder:     QGroundControl.zOrderWidgets

    property bool   _communicationLost: _activeVehicle ? _activeVehicle.vehicleLinkManager.communicationLost : false
    property bool   _healthAndArmingChecksSupported: _activeVehicle ? _activeVehicle.healthAndArmingCheckReport.supported : false
    property color  _mainStatusBGColor: qgcPal.brandingPurple
    property var    _vehicleInAir:      _activeVehicle ? _activeVehicle.flying || _activeVehicle.landing : false

    property bool   _armed:             _activeVehicle ? _activeVehicle.armed : false
    //property real   _margins:           ScreenTools.defaultFontPixelWidth
    property real   _spacing:           ScreenTools.defaultFontPixelWidth /

    function _calcCenterViewPort() {
        var newToolInset = Qt.rect(0, 0, width, height)
        toolstrip.adjustToolInset(newToolInset)
        if (QGroundControl.corePlugin.options.instrumentWidget) {
            flightDisplayViewWidgets.adjustToolInset(newToolInset)
        }
    }

    QGCToolInsets {
        id:                     _toolInsets
        leftEdgeBottomInset:    _pipOverlay.visible ? _pipOverlay.x + _pipOverlay.width : 0
        bottomEdgeLeftInset:    _pipOverlay.visible ? parent.height - _pipOverlay.y : 0
    }

    FlyViewWidgetLayer {
        id:                     widgetLayer
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.left:           parent.left
        anchors.right:          guidedValueSlider.visible ? guidedValueSlider.left : parent.right
        z:                      _fullItemZorder + 1
        parentToolInsets:       _toolInsets
        mapControl:             _mapControl
        visible:                /*!QGroundControl.videoManager.fullScreen*/ true
    }


    FlyViewCustomLayer {
        id:                 customOverlay
        anchors.fill:       widgetLayer
        z:                  _fullItemZorder + 2
        parentToolInsets:   widgetLayer.totalToolInsets
        mapControl:         _mapControl
        visible:            !QGroundControl.videoManager.fullScreen
    }

    MapScale {
        id:                 mapScale
        anchors.margins:    _toolsMargin
        //anchors.left:       toolStrip.right
        anchors.top:        parent.top
        mapControl:         _mapControl
        buttonsOnLeft:      true
        visible:            !ScreenTools.isTinyScreen && QGroundControl.corePlugin.options.flyView.showMapScale && mapControl.pipState.state === mapControl.pipState.fullState

        property real topEdgeCenterInset: visible ? y + height : 0
        //visible: false
    }

    // Development tool for visualizing the insets for a paticular layer, enable if needed
    /*
    FlyViewInsetViewer {
        id:                     widgetLayerInsetViewer
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        anchors.left:           parent.left
        anchors.right:          guidedValueSlider.visible ? guidedValueSlider.left : parent.right

        z:                      widgetLayer.z + 1

        insetsToView:           customOverlay.totalToolInsets
    }*/

    GuidedActionsController {
        id:                 guidedActionsController
        missionController:  _missionController
        actionList:         _guidedActionList
        guidedValueSlider:     _guidedValueSlider
    }

    /*GuidedActionConfirm {
        id:                         guidedActionConfirm
        anchors.margins:            _margins
        anchors.bottom:             parent.bottom
        anchors.horizontalCenter:   parent.horizontalCenter
        z:                          QGroundControl.zOrderTopMost
        guidedController:           _guidedController
        guidedValueSlider:             _guidedValueSlider
    }*/

    GuidedActionList {
        id:                         guidedActionList
        anchors.margins:            _margins
        anchors.bottom:             parent.bottom
        anchors.horizontalCenter:   parent.horizontalCenter
        z:                          QGroundControl.zOrderTopMost
        guidedController:           _guidedController
    }

    //-- Guided value slider (e.g. altitude)
    GuidedValueSlider {
        id:                 guidedValueSlider
        anchors.margins:    _toolsMargin
        anchors.right:      parent.right
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        z:                  QGroundControl.zOrderTopMost
        radius:             ScreenTools.defaultFontPixelWidth / 2
        width:              ScreenTools.defaultFontPixelWidth * 10
        color:              qgcPal.window
        visible:            false
    }

    FlyViewMap {
        id:                     mapControl
        //anchors.fill: parent
        planMasterController:   _planController
        rightPanelWidth:        ScreenTools.defaultFontPixelHeight * 9
        pipMode:                !_mainWindowIsMap
        toolInsets:             customOverlay.totalToolInsets
        mapName:                "FlightDisplayView"
    }

    FlyViewVideo {
        id: videoControl
    }

    QGCPipOverlay {
        id:                     _pipOverlay
        //anchors.left:           parent.left
        anchors.right:          parent.right
        anchors.bottom:         parent.bottom
        anchors.margins:        _toolsMargin
        anchors.rightMargin: 10
        item1IsFullSettingsKey: "MainFlyWindowIsMap"
        item1:                  mapControl
        item2:                  QGroundControl.videoManager.hasVideo ? videoControl : null
        fullZOrder:             _fullItemZorder
        pipZOrder:              _pipItemZorder
        show:                   !QGroundControl.videoManager.fullScreen &&
                                    (videoControl.pipState.state === videoControl.pipState.pipState || mapControl.pipState.state === mapControl.pipState.pipState)
        onVideoClose: photoVideoControl.visible = false
        onVideoOpen: photoVideoControl.visible = true
    }

    MultiVehicleList {
        anchors.margins:    _toolsMargin
        anchors.top:        multiVehiclePanelSelector.bottom
        anchors.right:      parent.right
        width:              _rightPanelWidth
        height:             parent.height - y - _toolsMargin
        visible:            !multiVehiclePanelSelector.showSingleVehiclePanel
    }


    ToolStrip {
        id: toolStrip
        width: parent.width
        //orientation: Qt.Horizontal
        title: qsTr("Fly")
        // anchors.top: parent.top
        // anchors.topMargin: 80
        signal displayPreFlightChecklist

        FlyViewToolStripActionList {
            id: flyViewToolStripActionList
            //mapTypePanel: mapTypeDropPanel
            onDisplayPreFlightChecklist: toolStrip.displayPreFlightChecklist()
        }
        model: flyViewToolStripActionList.model
    }


    PhotoVideoControl {
        id: photoVideoControl
        anchors.right: videoControl.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 5
        anchors.rightMargin: 5
        width: _rightPanelWidth
    }

    FlyViewInstrumentPanel {
        id:                         instrumentPanel
        width:                      _rightPanelWidth
        spacing:                    _toolsMargin
        visible:                    /*QGroundControl.corePlugin.options.flyView.showInstrumentPanel && multiVehiclePanelSelector.showSingleVehiclePanel*/true
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 125
        anchors.topMargin: 80
        // availableHeight:            parent.height - y - _toolsMargin
        // anchors.top:                parent.top
        // anchors.left:              parent.left
        // anchors.topMargin:        50
        //anchors.margins:            _toolsMargin

        // property real rightEdgeTopInset:    visible ? parent.width - x : 0
        // property real topEdgeRightInset:    visible ? y + height : 0
    }

    ParameterDetails {
        id: parameterDetailsPanel
        anchors.right: parent.right
        anchors.top: instrumentPanel.bottom
        anchors.rightMargin: 10
        anchors.topMargin: 20
        visible: _activeVehicle !== null
    }

    FlyViewTopBar {
        id: topBar
        anchors.top: parent.top
        anchors.topMargin: 15
        anchors.horizontalCenter: parent.horizontalCenter
        visible: _activeVehicle !== null
    }

    MessageToolBar {
        id: messageBar
        anchors.top: parent.top
        anchors.left: topBar.right
        anchors.topMargin: 19
        anchors.leftMargin: 20
        z: 100   // make sure it’s above topBar
        visible: _activeVehicle !== null
    }

    MapTools {
        id: mapTools
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.bottomMargin: 20
    }


    // Rectangle {
    //     id: valuesSection
    //     width: parent.width * 0.16
    //     // anchors.top: vehicleDetailsSection.bottom
    //     // anchors.right: parent.right
    //     // anchors.rightMargin: 20
    //     // anchors.topMargin: 30
    //     color: "#80CCCCCC"

    //     property bool expanded: false
    //     property int collapsedHeight: 40
    //     property int expandedHeight: 220

    //     x: parent.width - width - 20   // initial position
    //     y: 370                          // initial position

    //     height: expanded ? expandedHeight : collapsedHeight

    //     Behavior on height {
    //         NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
    //     }

    //     Rectangle {
    //         id: header2
    //         width: parent.width
    //         height: 40
    //         color: "#80CCCCCC"

    //         RowLayout {
    //             anchors.fill: parent
    //             anchors.margins: 10
    //             spacing: 10

    //             Text {
    //                 text: "Values"
    //                 font.bold: true
    //                 font.pointSize: 13
    //                 color: "black"
    //                 Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
    //             }

    //             Item { Layout.fillWidth: true }

    //             Text {
    //                 id: arrow2
    //                 text: valuesSection.expanded ? "▲" : "▼"
    //                 font.pointSize: 14
    //                 color: "black"
    //                 Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
    //             }
    //         }

    //         MouseArea {    // enable this mouse area to drag the component anywhere in the screen
    //             anchors.fill: parent
    //             drag.target: valuesSection
    //             drag.axis: Drag.XAndYAxis

    //             onClicked: {
    //                 // only toggle expand if it was a click, not a drag
    //                 if (!drag.active) {
    //                     valuesSection.expanded = !valuesSection.expanded
    //                 }
    //             }
    //         }

    //         // MouseArea {
    //         //     anchors.fill: parent
    //         //     onClicked: valuesSection.expanded = !valuesSection.expanded
    //         // }
    //     }

    //     Loader {
    //         id: contentLoader1
    //         anchors.top: header2.bottom
    //         anchors.left: parent.left
    //         anchors.right: parent.right
    //         anchors.margins: 10
    //         active: valuesSection.expanded

    //         sourceComponent: Column {
    //             id: content2
    //             spacing: 10
    //             anchors.margins: 10

    //             TelemetryValuesBar {
    //                 id: telemetryPanel
    //                 anchors.left: parent.left
    //             }
    //         }
    //     }
    // }

    Rectangle {
        id: messagesSection
        width: parent.width * 0.16
        // anchors.right: parent.right
        // anchors.bottom: parent.bottom
        // anchors.rightMargin: 5
        // anchors.bottomMargin: 5
        color: Qt.rgba(0.9, 0.9, 0.9, 0.6)
        visible: messageBar.showMessages

        x: telemetryPanel.x - 350
        y: telemetryPanel.y - 165   // places below timeDate

        property bool expanded: false
        property int collapsedHeight: 40
        property int expandedHeight: 200

        height: /*expanded ? */expandedHeight /*: collapsedHeight*/

        Behavior on height {
            NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
        }

        Rectangle {
            id: msgHeader
            width: parent.width
            height: 40
            color: "#80CCCCCC"

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 50

                Text {
                    text: "Messages"
                    font.bold: true
                    font.pointSize: 13
                    color: "black"
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignCenter
                    //anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {    // enable this mouse area to drag the component anywhere in the screen
                anchors.fill: parent
                drag.target: messagesSection
                drag.axis: Drag.XAndYAxis

                // onClicked: {
                //     // only toggle expand if it was a click, not a drag
                //     if (!drag.active) {
                //         valuesSection.expanded = !valuesSection.expanded
                //     }
                // }
            }
        }

        ListModel { id: messageListModel }

        ListView {
            id: listView
            anchors.top: msgHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            clip: true
            model: messageListModel

            delegate: Rectangle {
                width: listView.width
                color: "transparent"

                Text {
                    text: model.text
                    textFormat: Text.RichText
                    renderType: Text.NativeRendering
                    wrapMode: Text.Wrap
                    width: parent.width - 10
                    anchors.left: parent.left
                    anchors.margins: 5
                    //color: "black"
                    font.pointSize: 10
                    //height: contentHeigh
                }
                height: childrenRect.height + 10
            }
        }

        // Fill history when opened
        function populateFromFormattedMessages() {
            messageListModel.clear()
            if (!_activeVehicle || !_activeVehicle.formattedMessages) return
            var lines = _activeVehicle.formattedMessages.split("\n")
            for (var i = 0; i < lines.length; ++i) {
                var line = lines[i].trim()
                if (line.length > 0) {
                    messageListModel.append({ text: line })
                }
            }
            Qt.callLater(function(){ listView.positionViewAtEnd() })
        }

        // Handle new incoming messages
        Connections {
            target: QGroundControl.multiVehicleManager
            onActiveVehicleChanged: {
                if (QGroundControl.multiVehicleManager.activeVehicle) {
                    _activeVehicle = QGroundControl.multiVehicleManager.activeVehicle
                    if (messagesSection.expanded) populateFromFormattedMessages()
                }
            }
        }

        Connections {
            target: _activeVehicle
            onNewFormattedMessage: function(msg) {
                // add empty entry for the new message
                var newIndex = messageListModel.count
                messageListModel.append({ text: "" })

                // typewriter effect
                var i = 0
                var timer = Qt.createQmlObject('import QtQuick 2.0; Timer { interval: 30; repeat: true }',
                                               listView, "typewriterTimer")
                timer.triggered.connect(function() {
                    if (i < msg.length) {
                        // append next character
                        var current = messageListModel.get(newIndex).text
                        messageListModel.setProperty(newIndex, "text", current + msg[i])
                        i++
                        listView.positionViewAtEnd()
                    } else {
                        timer.stop()
                        timer.destroy()
                    }
                })
                timer.start()
            }
        }
    }


    Row {
        id:                 multiVehiclePanelSelector
        anchors.margins:    _toolsMargin
        anchors.top:        parameterDetailsPanel.bottom
        anchors.topMargin: 30
        anchors.right:      parent.right
        anchors.rightMargin: 60
        width:              _rightPanelWidth
        spacing:            ScreenTools.defaultFontPixelWidth
        visible:            QGroundControl.multiVehicleManager.vehicles.count > 1 && QGroundControl.corePlugin.options.flyView.showMultiVehicleList

        property bool showSingleVehiclePanel:  !visible ||   singleVehicleRadio.checked

        QGCMapPalette { id: mapPal; lightColors: true }

        QGCRadioButton {
            id:             singleVehicleRadio
            text:           qsTr("SINGLE")
            font.bold: true
            checked:        true
            textColor:      mapPal.text/*"black"*/
        }

        QGCRadioButton {
            text:           qsTr("MULTI-VEHICLE")
            font.bold: true
            textColor:      mapPal.text
        }
    }

    QGCButton {
       id: disconnectButton
       text: "Disconnect"
       backRadius: 7
       onClicked: _activeVehicle.closeVehicle()
       visible: _activeVehicle && _communicationLost
       anchors.horizontalCenter: parent.horizontalCenter
       anchors.top: parent.top
       anchors.topMargin: 75
    }


    // Rectangle {
    //     id: timeDate
    //     width: 120
    //     height: 27
    //     // color: "#2c3e50"
    //     color: "#80CCCCCC"
    //     anchors.horizontalCenter: parent.horizontalCenter
    //     anchors.bottom: parent.bottom
    //     // anchors.rightMargin: 5
    //     // anchors.bottomMargin: 5

    //     Timer {
    //         interval: 1000
    //         running: true
    //         repeat: true
    //         onTriggered: clockLabel.text = Qt.formatDateTime(new Date(), "hh:mm:ss | dd-MM-yyyy")
    //     }

    //     QGCLabel {
    //         id: clockLabel
    //         anchors.centerIn: parent
    //         text: Qt.formatDateTime(new Date, "hh:mm:ss | dd-MM-yyyy")
    //         font.pointSize: 8
    //         font.bold: true
    //         color: "black"
    //     }
    // }

    TelemetryValuesBar {
        id: telemetryPanel
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
