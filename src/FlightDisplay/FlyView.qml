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

    property bool logOut: false

    QGCPalette { id: qgcPal }

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

    property bool   telemetryVisible: QGroundControl.settingsManager.flyViewSettings.telemetryVisible.value
    property bool   hudVisible: QGroundControl.settingsManager.flyViewSettings.hudVisible.value
    property bool   toolStripVisible: QGroundControl.settingsManager.flyViewSettings.toolStripVisible.value
    property bool   videoVisible: QGroundControl.settingsManager.flyViewSettings.videoVisible.value

    // Loader {
    //     id: configPanelLoader
    //     anchors.fill: parent
    //     z: QGroundControl.zOrderTopMost
    //     source: "ConfigPanel.qml"

    //     onLoaded: {
    //         item._root = _root
    //     }
    // }

    //property real   _pipItemZorder:     QGroundControl.zOrderWidgets

    property bool   _communicationLost: _activeVehicle ? _activeVehicle.vehicleLinkManager.communicationLost : false
    property bool   _healthAndArmingChecksSupported: _activeVehicle ? _activeVehicle.healthAndArmingCheckReport.supported : false
    property color  _mainStatusBGColor: qgcPal.brandingPurple
    property var    _vehicleInAir:      _activeVehicle ? _activeVehicle.flying || _activeVehicle.landing : false

    property bool   _armed:             _activeVehicle ? _activeVehicle.armed : false
    //property real   _margins:           ScreenTools.defaultFontPixelWidth
    property real   _spacing:           ScreenTools.defaultFontPixelWidth
    property bool   _isVideoFullscreen: false

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
        visible:                !QGroundControl.videoManager.fullScreen
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
        anchors.margins:            _margins + 40
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
        color:               qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(1, 1, 1, 0.5) : Qt.rgba(0, 0, 0, 0.5) /*qgcPal.window*/
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
        visible:                !_isVideoFullscreen || !ScreenTools.isMobile
    }

    FlyViewVideo {
        id: videoControl
    }

    QGCPipOverlay {
        id:                     _pipOverlay
        anchors.left:           parent.left
        //anchors.right:          parent.right
        anchors.bottom:         parent.bottom
        anchors.margins:        _toolsMargin
        anchors.rightMargin: 10
        item1IsFullSettingsKey: "MainFlyWindowIsMap"
        item1:                  mapControl
        item2:                  QGroundControl.videoManager.hasVideo ? videoControl : null
        fullZOrder:             _fullItemZorder
        pipZOrder:              _pipItemZorder
        show:                   !QGroundControl.videoManager.fullScreen &&
                                    (videoControl.pipState.state === videoControl.pipState.pipState || mapControl.pipState.state === mapControl.pipState.pipState) && _root.videoVisible
    }

    MultiVehicleList {
        anchors.margins:    _toolsMargin
        anchors.top:        multiVehiclePanelSelector.bottom
        anchors.right:      parent.right
        //anchors.centerIn: parent
        width:              /*_rightPanelWidth*/ ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth * 47 : ScreenTools.defaultFontPixelWidth * 60
        height:             parent.height - y - _toolsMargin
        visible:            !multiVehiclePanelSelector.showSingleVehiclePanel
    }


    ToolStrip {
        id: toolStrip
        width: parent.width
        title: qsTr("Fly")
        anchors.bottom: parent.botto
        signal displayPreFlightChecklist
        anchors.margins: ScreenTools.defaultFontPixelWidth

        FlyViewToolStripActionList {
            id: flyViewToolStripActionList
            onDisplayPreFlightChecklist: toolStrip.displayPreFlightChecklist()
        }
        model: flyViewToolStripActionList.model
    }


    PhotoVideoControl {
        id: photoVideoControl
        anchors.right: ScreenTools.isMobile ? undefined : parent.right
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: ScreenTools.isMobile ? parent.horizontalCenter : undefined
        anchors.bottomMargin: 5
        anchors.rightMargin: 5
        width: _rightPanelWidth
        visible: mapControl.pipState.state === mapControl.pipState.pipState
    }

    FlyViewInstrumentPanel {
        id:                         instrumentPanel
        width:                      _rightPanelWidth
        spacing:                    _toolsMargin
        visible:                    _root.hudVisible && /*QGroundControl.corePlugin.options.flyView.showInstrumentPanel && */multiVehiclePanelSelector.showSingleVehiclePanel
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: ScreenTools.isMobile ? -150 : 25
        anchors.topMargin: ScreenTools.defaultFontPixelHeight * 2.5
    }

    ParameterDetails {
        id: parameterDetailsPanel
        anchors.left: parent.left
        anchors.top: toolStrip1.bottom
        anchors.margins: ScreenTools.defaultFontPixelWidth
        anchors.topMargin: ScreenTools.defaultFontPixelHeight
        visible: !(ScreenTools.isMobile) && _root.telemetryVisible
    }

    AndroidTelemetry {
        id: androidTelemetry
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: ScreenTools.defaultFontPixelWidth / 2
        visible: ScreenTools.isMobile && _root.telemetryVisible
    }

    Rectangle {
        id: multiVehiclePanelSelector
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins:    _toolsMargin
        //anchors.rightMargin: 60
        width:  multiVehiclePanelSelector1.implicitWidth
        height: multiVehiclePanelSelector1.implicitHeight
        color:              qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(1, 1, 1, 0.5) : Qt.rgba(0, 0, 0, 0.5)
        visible:            QGroundControl.multiVehicleManager.vehicles.count > 1 && QGroundControl.corePlugin.options.flyView.showMultiVehicleList
        property bool showSingleVehiclePanel:  !visible ||   singleVehicleRadio.checked

        QGCMapPalette { id: mapPal; lightColors: true }

        RowLayout {
            id: multiVehiclePanelSelector1
            anchors.fill: parent

            QGCRadioButton {
                id:             singleVehicleRadio
                text:           qsTr("SINGLE")
                font.bold: true
                checked:        true
            }

            QGCRadioButton {
                text:           qsTr("MULTI-VEHICLE")
                font.bold: true
            }
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

    Rectangle {
        id: signingIndicator
        width: 25
        height: 25
        radius: 12
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: _toolsMargin
        //anchors.centerIn: parent
        visible: _activeVehicle
        color: {
            if (!_activeVehicle) return "grey"
            var status = _activeVehicle.signingStatus()
            if (status.indexOf("ENABLED") !== -1 && status.indexOf("ON") !== -1) return "green"
            if (status.indexOf("key") !== -1 && status.indexOf("No key") === -1) return "orange"
            return "grey"
        }
        border.color: "white"
        border.width: 1

        QGCLabel {
            id: signingIndicatorTooltip
            anchors.centerIn: parent
            text: ""
            font.pointSize: 8
            color: "white"
            visible: parent.containsMouse
        }

        Timer {
            id: signingRefreshTimer
            interval: 3000
            running: _activeVehicle !== undefined
            repeat: true
            onTriggered: {
                // Force property re-evaluation by reassigning
                signingIndicator.color = signingIndicator.color
            }
        }

        MouseArea {
            id: signingIndicatorMouseArea
            anchors.fill: parent
            hoverEnabled: true
            onEntered: {
                if (_activeVehicle) {
                    signingIndicatorTooltip.text = _activeVehicle.signingStatus().substring(0, 100)
                }
            }
            onExited: {
                signingIndicatorTooltip.text = ""
            }
            onClicked: {
                mainWindow.showTool(qsTr("License Keys"), "LicensePage.qml", "/res/FWD_only_logo")
            }
        }
    }

    TelemetryValuesBar {
        id: telemetryPanel
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        visible: !(ScreenTools.isMobile) && _root.telemetryVisible
    }

    FlyViewToolStrip {
        id:                     toolStrip1
        //anchors.leftMargin:     _toolsMargin + 10/*+ parentToolInsets.leftEdgeCenterInset*/
        //anchors.topMargin:      _toolsMargin + 50 /*+ parentToolInsets.topEdgeLeftInset*/
        anchors.left:           parent.left
        anchors.top:            parent.top
        z:                      QGroundControl.zOrderWidgets
        maxHeight:              parent.height/* - y - parentToolInsets.bottomEdgeLeftInset - _toolsMargin*/
        visible:                !QGroundControl.videoManager.fullScreen && _root.toolStripVisible
        anchors.margins: ScreenTools.defaultFontPixelWidth

        onDisplayPreFlightChecklist: preFlightChecklistPopup.createObject(mainWindow).open()


        property real topEdgeLeftInset: visible ? y + height : 0
        property real leftEdgeTopInset: visible ? x + width : 0
    }

    Component {
        id: preFlightChecklistPopup
        FlyViewPreFlightChecklistPopup {
        }
    }
}
