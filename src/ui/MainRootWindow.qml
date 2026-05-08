/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.11
import QtQuick.Controls 2.4
import QtQuick.Dialogs  1.3
import QtQuick.Layouts  1.11
import QtQuick.Window   2.11

import QGroundControl               1.0
import QGroundControl.Palette       1.0
import QGroundControl.Controls      1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap     1.0

/// @brief Native QML top level window
/// All properties defined here are visible to all QML pages.
ApplicationWindow {
    id:             mainWindow
    minimumWidth:   ScreenTools.isMobile ? Screen.width  : Math.min(ScreenTools.defaultFontPixelWidth * 100, Screen.width)
    minimumHeight:  ScreenTools.isMobile ? Screen.height : Math.min(ScreenTools.defaultFontPixelWidth * 50, Screen.height)
    visible:        true

    property bool loggedIn: false
    property bool linkDisconnected: false
    property bool loggedOut: false
    property bool videoPanelVisible: true

    property alias settingsDrawer: qgcSettingsDrawer

    Keys.onReleased: (event) => {
        if (event.key === Qt.Key_Escape && toolDrawer.visible) {
            toolDrawer.visible = false
            event.accepted = true
        }
    }

    Loader {
        id: pageLoader
        anchors.fill: parent
        source: mainWindow.loggedIn ? "" : "LoginPage.qml"

        Connections {
            target: pageLoader.item
            ignoreUnknownSignals: true
            onLoginSuccess: {
                //console.log("Login success signal received")
                mainWindow.loggedIn = true
                //toolbar.currentToolbar = toolbar.planViewToolbar
                // Hide LoginPage
                pageLoader.source = ""
                planView.visible = true
            }
        }
    }


    Component.onCompleted: {
        //-- Full screen on mobile or tiny screens
        if (ScreenTools.isMobile || Screen.height / ScreenTools.realPixelDensity < 120) {
            mainWindow.showFullScreen()
        } else {
            width   = ScreenTools.isMobile ? Screen.width  : Math.min(250 * Screen.pixelDensity, Screen.width)
            height  = ScreenTools.isMobile ? Screen.height : Math.min(150 * Screen.pixelDensity, Screen.height)
        }

        // Start the sequence of first run prompt(s)
        firstRunPromptManager.nextPrompt()
    }

    QtObject {
        id: firstRunPromptManager

        property var currentDialog:     null
        property var rgPromptIds:       QGroundControl.corePlugin.firstRunPromptsToShow()
        property int nextPromptIdIndex: 0

        function clearNextPromptSignal() {
            if (currentDialog) {
                currentDialog.closed.disconnect(nextPrompt)
            }
        }

        function nextPrompt() {
            if (nextPromptIdIndex < rgPromptIds.length) {
                var component = Qt.createComponent(QGroundControl.corePlugin.firstRunPromptResource(rgPromptIds[nextPromptIdIndex]));
                currentDialog = component.createObject(mainWindow)
                currentDialog.closed.connect(nextPrompt)
                currentDialog.open()
                nextPromptIdIndex++
            } else {
                currentDialog = null
                showPreFlightChecklistIfNeeded()
            }
        }
    }

    property var                _rgPreventViewSwitch:       [ false ]

    readonly property real      _topBottomMargins:          ScreenTools.defaultFontPixelHeight * 0.5

    property string loggedInUser: ""

    //-------------------------------------------------------------------------
    //-- Global Scope Variables

    QtObject {
        id: globals

        readonly property var       activeVehicle:                  QGroundControl.multiVehicleManager.activeVehicle
        readonly property real      defaultTextHeight:              ScreenTools.defaultFontPixelHeight
        readonly property real      defaultTextWidth:               ScreenTools.defaultFontPixelWidth
        readonly property var       planMasterControllerFlyView:    /*flightViewLoader.item*/flightView.planController /*null*/
        readonly property var       guidedControllerFlyView:        /*flightViewLoader.item*/flightView.guidedController /*null*/

        property var                planMasterControllerPlanView:   null
        property var                currentPlanMissionItem:         planMasterControllerPlanView ? planMasterControllerPlanView.missionController.currentPlanViewItem : null

        // Property to manage RemoteID quick acces to settings page
        property bool               commingFromRIDIndicator:        false
        property bool               commingFromCommLinks:           false
    }

    /// Default color palette used throughout the UI
    QGCPalette { id: qgcPal; colorGroupEnabled: true }

    //-----------------------------------------------------------
    // State variables--------------
    //-- Actions

    signal armVehicleRequest
    signal forceArmVehicleRequest
    signal disarmVehicleRequest
    signal vtolTransitionToFwdFlightRequest
    signal vtolTransitionToMRFlightRequest
    signal showPreFlightChecklistIfNeeded

    //-------------------------------------------------------------------------
    //-- Global Scope Functions

    /// Prevent view switching
    function pushPreventViewSwitch() {
        _rgPreventViewSwitch.push(true)
    }

    /// Allow view switching
    function popPreventViewSwitch() {
        if (_rgPreventViewSwitch.length == 1) {
            console.warn("mainWindow.popPreventViewSwitch called when nothing pushed")
            return
        }
        _rgPreventViewSwitch.pop()
    }

    /// @return true: View switches are not currently allowed
    function preventViewSwitch() {
        return _rgPreventViewSwitch[_rgPreventViewSwitch.length - 1]
    }

    function viewSwitch(currentToolbar) {
        toolDrawer.visible      = false
        toolDrawer.toolSource   = ""
        flightView/*flightViewLoader.item*/.visible      = false
        planView.visible        = false
        toolBar.currentToolbar  = currentToolbar
    }

    function showFlyView() {
        if (!flightView.visible) {
            mainWindow.showPreFlightChecklistIfNeeded()
        }
        viewSwitch(toolBar.flyViewToolbar)
        planView.visible = false
        flightView.visible = true
    }

    function showPlanView() {
        viewSwitch(toolBar.planViewToolbar)
        flightView.visible = false
        planView.visible = true
    }

    function showTool(toolTitle, toolSource, toolIcon) {
        toolDrawer.backIcon     = flightView.visible ? "/res/backward" : "/res/backward"
        toolDrawer.toolTitle    = toolTitle
        toolDrawer.toolSource   = toolSource
        toolDrawer.toolIcon     = toolIcon
        toolDrawer.visible      = true
    }

    // function showSettingsPage() {
    //     showTool(qsTr("Settings"), "Settings.qml", "/res/settings_icon")
    // }

    function showAnalyzeTool() {
        qgcSettingsDrawer.visible = false
        showTool(qsTr("Analyze Tools"), "AnalyzeView.qml", "/qmlimages/Analyze.svg")
    }

    function showSetupTool() {
        qgcSettingsDrawer.visible = false
        showTool(qsTr("Vehicle Setup"), "SetupView.qml", "/qmlimages/Gears.svg")
    }

    function showSettingsTool() {
        qgcSettingsDrawer.visible = false
        showTool(qsTr("Application Settings"), "AppSettings.qml", "/res/FWD_only_logo")
    }

    function showCommLinksSettings() {
        qgcSettingsDrawer.visible = false
        globals.commingFromCommLinks = true
        showTool(qsTr("Application Settings"), "AppSettings.qml", "/res/FWD_only_logo")
    }

    //-------------------------------------------------------------------------
    //-- Global simple message dialog

    function showMessageDialog(dialogTitle, dialogText, buttons = StandardButton.Ok, acceptFunction = null) {
        simpleMessageDialogComponent.createObject(mainWindow, { title: dialogTitle, text: dialogText, buttons: buttons, acceptFunction: acceptFunction }).open()
    }

    // This variant is only meant to be called by QGCApplication
    function _showMessageDialog(dialogTitle, dialogText) {
        showMessageDialog(dialogTitle, dialogText)
    }


    Component {
        id: simpleMessageDialogComponent

        QGCSimpleMessageDialog {
        }
    }

    /// Saves main window position and size
    MainWindowSavedState {
        window: mainWindow
    }

    property bool _forceClose: false

    function logOutProfile() {
        _forceClose = true
        firstRunPromptManager.clearNextPromptSignal()
        mainWindow.linkDisconnected = true
        mainWindow.loggedIn = false
        //console.log("Mainwindow.loggedIn", mainWindow.loggedIn)
        mainWindow.loggedOut = true
        planView.visible = false
        flightView.visible = false
        //Qt.quit()
        pageLoader.source = "LoginPage.qml"
    }

    function finishCloseProcess() {
        _forceClose = true
        // For some reason on the Qml side Qt doesn't automatically disconnect a signal when an object is destroyed.
        // So we have to do it ourselves otherwise the signal flows through on app shutdown to an object which no longer exists.
        firstRunPromptManager.clearNextPromptSignal()
        QGroundControl.linkManager.shutdown()
        QGroundControl.videoManager.stopVideo();
        mainWindow.close()
    }

    // On attempting an application close we check for:
    //  Unsaved missions - then
    //  Pending parameter writes - then
    //  Active connections

    property string closeDialogTitle: qsTr("Close %1").arg(QGroundControl.appName)

    function checkForUnsavedMission() {
        if (globals.planMasterControllerPlanView && globals.planMasterControllerPlanView.dirty) {
            showMessageDialog(closeDialogTitle,
                              qsTr("You have a mission edit in progress which has not been saved/sent. If you close you will lose changes. Are you sure you want to close?"),
                              StandardButton.Yes | StandardButton.No,
                              function() { checkForPendingParameterWrites() })
        } else {
            checkForPendingParameterWrites()
        }
    }

    function checkForPendingParameterWrites() {
        for (var index=0; index<QGroundControl.multiVehicleManager.vehicles.count; index++) {
            if (QGroundControl.multiVehicleManager.vehicles.get(index).parameterManager.pendingWrites) {
                mainWindow.showMessageDialog(closeDialogTitle,
                    qsTr("You have pending parameter updates to a vehicle. If you close you will lose changes. Are you sure you want to close?"),
                    StandardButton.Yes | StandardButton.No,
                    function() { checkForActiveConnections() })
                return
            }
        }
        checkForActiveConnections()
    }

    function checkForActiveConnections() {
        if (QGroundControl.multiVehicleManager.activeVehicle) {
            mainWindow.showMessageDialog(closeDialogTitle,
                qsTr("There are still active connections to vehicles. Are you sure you want to exit?"),
                StandardButton.Yes | StandardButton.No,
                function() { finishCloseProcess() })
        } else {
            finishCloseProcess()
        }
    }

    function checkForActiveConnectionsForLogout() {
        if (globals.activeVehicle) {
            mainWindow.showMessageDialog(closeDialogTitle,
                qsTr("Logout is not allowed while there are active connections."),
                StandardButton.Ok)/* | StandardButton.No,*/
                //function() { logOutProfile() })
        } else {
            //console.log("Logic comes here")
            logOutProfile()
        }
    }


    onClosing: {
        if (!_forceClose) {
            close.accepted = false
            checkForUnsavedMission()
        }
    }

    //-------------------------------------------------------------------------
    // Main, full window background (Fly View)
    background: Item {
        id:             rootBackground
        anchors.fill:   parent
    }

    // //-------------------------------------------------------------------------
    // //Toolbar
    header: MainToolBar {
        //id: toolBar
    //}
        id:         toolBar
        height:     ScreenTools.isMobile ? ScreenTools.toolbarHeight - 30 : ScreenTools.toolbarHeight
        //height:     ScreenTools.toolbarHeight
        visible:    !(QGroundControl.videoManager.fullScreen && flightView.visible) && loggedIn
        //userName:   mainWindow.loggedInUser
        onLogOutRequested: {
            checkForActiveConnectionsForLogout()
        }
    }

    footer: LogReplayStatusBar {
        visible: QGroundControl.settingsManager.flyViewSettings.showLogReplayStatusBar.rawValue && loggedIn
    }

    FlyView {
        id: flightView
        anchors.fill: parent
        visible: mainWindow.loggedIn && toolBar.currentToolbar === toolBar.flyViewToolbar
    }

    PlanView {
        id: planView
        anchors.fill: parent
        visible: mainWindow.loggedIn && toolBar.currentToolbar === toolBar.planViewToolbar
    }



    Drawer {
        id:             toolDrawer
        width:          mainWindow.width
        height:         mainWindow.height
        edge:           Qt.RightEdge
        dragMargin:     0
        closePolicy:    Drawer.NoAutoClose
        interactive:    false
        visible:        false

        property alias backIcon:    backIcon.source
        property alias toolTitle:   toolbarDrawerText.text
        property alias toolSource:  toolDrawerLoader.source
        property alias toolIcon:    toolIcon.source

        // Unload the loader only after closed, otherwise we will see a "blank" loader in the meantime
        onClosed: {
            toolDrawer.toolSource = ""
        }

        Rectangle {
            id:             toolDrawerToolbar
            anchors.left:   parent.left
            anchors.right:  parent.right
            anchors.top:    parent.top
            height:         ScreenTools.toolbarHeight
            color:          qgcPal.toolbarBackground

            Shortcut {
                sequence: "Esc"
                onActivated: toolDrawer.visible = false
            }

            RowLayout {
                anchors.left:   parent.left
                anchors.right:  parent.right
                anchors.top:    parent.top
                anchors.bottom: parent.bottom
                spacing:        ScreenTools.defaultFontPixelWidth
                Layout.leftMargin: 50

                // Tool icon + title (stay on the LEFT)
                QGCColoredImage {
                    id:                     toolIcon
                    width:                  ScreenTools.defaultFontPixelHeight * 2
                    height:                 ScreenTools.defaultFontPixelHeight * 2
                    fillMode:               Image.PreserveAspectFit
                    mipmap:                 true
                    color:                  qgcPal.text
                    //visible: false
                }

                Item {
                    Layout.fillWidth: true
                }

                QGCLabel {
                    id:             toolbarDrawerText
                    font.pointSize: ScreenTools.largeFontPointSize
                    Layout.alignment: Qt.AlignVCenter
                }

                // Spacer to push "Back" button to the RIGHT
                Item {
                    Layout.fillWidth: true
                }

                RowLayout {
                    spacing: ScreenTools.defaultFontPixelWidth
                    Layout.rightMargin: 20

                    QGCLabel {
                        id:     backTextLabel
                        text:   qsTr("Back")
                        verticalAlignment: Text.AlignVCenter
                    }

                    QGCColoredImage {
                        id:                     backIcon
                        width:                  /*ScreenTools.isMobile ? ScreenTools.defaultFontPixelwidth * 2 :*/ ScreenTools.defaultFontPixelWidth * 5
                        height:                 /*ScreenTools.isMobile ? ScreenTools.defaultFontPixelHeight * 2 :*/ ScreenTools.defaultFontPixelHeight * 2.5
                        fillMode:               Image.PreserveAspectFit
                        mipmap:                 true
                        color:                  qgcPal.text
                        //visible: false
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                toolDrawer.visible = false
                            }
                        }
                    }
                }
            }
        }


        Loader {
            id:             toolDrawerLoader
            anchors.left:   parent.left
            anchors.right:  parent.right
            anchors.top:    toolDrawerToolbar.bottom
            anchors.bottom: parent.bottom

            Connections {
                target:                 toolDrawerLoader.item
                ignoreUnknownSignals:   true
                onPopout:               toolDrawer.visible = false
            }
        }
    }

    Drawer {
        id: qgcSettingsDrawer
        width: ScreenTools.isMobile ? mainWindow.width * 0.08 : mainWindow.width * 0.10
        height: mainWindow.height
        edge: Qt.RightEdge
        dragMargin: 0
        closePolicy: Drawer.NoAutoClose
        visible: false

        SettingsDrawer {
            anchors.fill: parent
            onCloseDrawer: qgcSettingsDrawer.visible = false
        }
    }

    //-------------------------------------------------------------------------
    //-- Critical Vehicle Message Popup

    function showCriticalVehicleMessage(message) {
        indicatorPopup.close()
        if (criticalVehicleMessagePopup.visible || QGroundControl.videoManager.fullScreen) {
            // We received additional wanring message while an older warning message was still displayed.
            // When the user close the older one drop the message indicator tool so they can see the rest of them.
            criticalVehicleMessagePopup.dropMessageIndicatorOnClose = true
        } else {
            criticalVehicleMessagePopup.criticalVehicleMessage      = message
            criticalVehicleMessagePopup.dropMessageIndicatorOnClose = false
            criticalVehicleMessagePopup.open()
        }
    }

    Popup {
        id:                 criticalVehicleMessagePopup
        y:                  ScreenTools.defaultFontPixelHeight
        x:                  Math.round((mainWindow.width - width) * 0.5)
        width:              mainWindow.width  * 0.55
        height:             criticalVehicleMessageText.contentHeight + ScreenTools.defaultFontPixelHeight * 2
        modal:              false
        focus:              true
        closePolicy:        Popup.CloseOnEscape

        property alias  criticalVehicleMessage:        criticalVehicleMessageText.text
        property bool   dropMessageIndicatorOnClose:   false

        background: Rectangle {
            anchors.fill:   parent
            color:          /*qgcPal.alertBackground*/ "#2c3e50"
            radius:         ScreenTools.defaultFontPixelHeight * 0.5
            border.color:   qgcPal.alertBorder
            border.width:   2

            Rectangle {
                anchors.horizontalCenter:   parent.horizontalCenter
                anchors.top:                parent.top
                anchors.topMargin:          -(height / 2)
                color:                      qgcPal.alertBackground
                radius:                     ScreenTools.defaultFontPixelHeight * 0.25
                border.color:               qgcPal.alertBorder
                border.width:               1
                width:                      vehicleWarningLabel.contentWidth + _margins + 30
                height:                     vehicleWarningLabel.contentHeight + _margins + 20

                property real _margins: ScreenTools.defaultFontPixelHeight * 0.25

                QGCLabel {
                    id:                 vehicleWarningLabel
                    anchors.centerIn:   parent
                    text:               qsTr("Vehicle Error")
                    font.pointSize:     /*ScreenTools.smallFontPointSize*/ 10
                    color:              qgcPal.alertText
                }
            }

            Rectangle {
                id:                         additionalErrorsIndicator
                anchors.horizontalCenter:   parent.horizontalCenter
                anchors.bottom:             parent.bottom
                anchors.bottomMargin:       -(height / 2)
                color:                      qgcPal.alertBackground
                radius:                     ScreenTools.defaultFontPixelHeight * 0.25
                border.color:               qgcPal.alertBorder
                border.width:               1
                width:                      additionalErrorsLabel.contentWidth + _margins
                height:                     additionalErrorsLabel.contentHeight + _margins
                visible:                    criticalVehicleMessagePopup.dropMessageIndicatorOnClose

                property real _margins: ScreenTools.defaultFontPixelHeight * 0.25

                QGCLabel {
                    id:                 additionalErrorsLabel
                    anchors.centerIn:   parent
                    text:               qsTr("Additional errors received")
                    font.pointSize:     ScreenTools.smallFontPointSize
                    color:              qgcPal.alertText
                }
            }
        }

        QGCLabel {
            id:                 criticalVehicleMessageText
            width:              criticalVehicleMessagePopup.width - ScreenTools.defaultFontPixelHeight
            anchors.centerIn:   parent
            wrapMode:           Text.WordWrap
            color:              /*qgcPal.alertText*/ "white"
            textFormat:         TextEdit.RichText
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                criticalVehicleMessagePopup.close()
                if (criticalVehicleMessagePopup.dropMessageIndicatorOnClose) {
                    criticalVehicleMessagePopup.dropMessageIndicatorOnClose = false;
                    QGroundControl.multiVehicleManager.activeVehicle.resetErrorLevelMessages();
                    toolbar.dropMessageIndicatorTool();
                }
            }
        }
    }

    //-------------------------------------------------------------------------
    //-- Indicator Popups

    function showIndicatorPopup(item, dropItem, position, dim = true) {
        indicatorPopup.currentIndicator = dropItem
        indicatorPopup.currentItem = item
        indicatorPopup.dim = dim
        indicatorPopup.position = position
        indicatorPopup.open()
    }

    function hideIndicatorPopup() {
        indicatorPopup.close()
        indicatorPopup.currentItem = null
        indicatorPopup.currentIndicator = null
    }

    Popup {
        id:             indicatorPopup
        padding:        ScreenTools.defaultFontPixelWidth * 0.75
        modal:          true
        focus:          true
        dim:            false
        closePolicy:    Popup.CloseOnEscape | Popup.CloseOnPressOutside
        property var    currentItem:        null
        property var    currentIndicator:   null
        property var    position:           null
        background: Rectangle {
            width:  loader.width
            height: loader.height
            color:  Qt.rgba(0,0,0,0)
        }
        Loader {
            id:             loader
            onLoaded: {
                var centerX = mainWindow.contentItem.mapFromItem(indicatorPopup.currentItem, 0, 0).x - (loader.width * 0.5)
                if((centerX + indicatorPopup.width) > (mainWindow.width - ScreenTools.defaultFontPixelWidth)) {
                    centerX = mainWindow.width - indicatorPopup.width - ScreenTools.defaultFontPixelWidth
                }
                indicatorPopup.x = centerX - 5

                indicatorPopup.y = mainWindow.contentItem.mapFromItem(indicatorPopup.currentItem, 0, 0).y

                // if(indicatorPopup.position === "bottom") {
                //     indicatorPopup.y = mainWindow.contentItem.mapFromItem(indicatorPopup.currentItem, 0, indicatorPopup.currentItem.height).y
                // } else if(indicatorPopup.position === "top"){
                //     indicatorPopup.y = 0
                // } else {
                //     indicatorPopup.y = (mainWindow.height - indicatorPopup.height) / 2
                // }
            }
        }
        onOpened: {
            loader.sourceComponent = indicatorPopup.currentIndicator
        }
        onClosed: {
            loader.sourceComponent = null
            indicatorPopup.currentIndicator = null
        }
    }

    // We have to create the popup windows for the Analyze pages here so that the creation context is rooted
    // to mainWindow. Otherwise if they are rooted to the AnalyzeView itself they will die when the analyze viewSwitch
    // closes.

    function createrWindowedAnalyzePage(title, source) {
        var windowedPage = windowedAnalyzePage.createObject(mainWindow)
        windowedPage.title = title
        windowedPage.source = source
    }

    Component {
        id: windowedAnalyzePage

        Window {
            width:      ScreenTools.defaultFontPixelWidth  * 100
            height:     ScreenTools.defaultFontPixelHeight * 40
            visible:    true

            property alias source: loader.source

            Rectangle {
                color:          QGroundControl.globalPalette.window
                anchors.fill:   parent

                Loader {
                    id:             loader
                    anchors.fill:   parent
                    onLoaded:       item.popped = true
                }
            }

            onClosing: {
                visible = false
                source = ""
            }
        }
    }
}
