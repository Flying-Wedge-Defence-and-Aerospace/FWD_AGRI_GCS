import QtQuick          2.12
import QtQuick.Layouts  1.12

import QGroundControl               1.0
import QGroundControl.Controls      1.0
import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0

Item {
    // id: root
    // anchors.fill: parent

    // // Properties to control visibility (passed from parent)
    // property var _root: null  // Will be set to parent _root object

    // property bool telemetryVisible: _root ? _root.telemetryVisible : true
    // property bool hudVisible: _root ? _root.hudVisible : true
    // property bool toolStripVisible: _root ? _root.toolStripVisible : true
    // property bool videoVisible: _root ? _root.videoVisible : true

    // property bool configPanelOpen: false

    // // Config button
    // Rectangle {
    //     id: configButton
    //     anchors.left: ScreenTools.isMobile ? parent.left : undefined
    //     anchors.verticalCenter: ScreenTools.isMobile ? parent.verticalCenter : undefined
    //     anchors.bottom: ScreenTools.isMobile ? undefined : parent.bottom
    //     anchors.right: ScreenTools.isMobile ? undefined : parent.right
    //     // anchors.margins: ScreenTools.defaultFontPixelWidth
    //     width: config.sourceSize.width /* +(ScreenTools.defaultFontPixelWidth / 2)*/
    //     height: config.sourceSize.height /*+ ScreenTools.defaultFontPixelHeight*/
    //     color: qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(1, 1, 1, 0.5) : Qt.rgba(0, 0, 0, 0.5)
    //     //radius: ScreenTools.defaultFontPixelWidth

    //     QGCColoredImage {
    //         id: config
    //         anchors.fill: parent
    //         anchors.margins: ScreenTools.defaultFontPixelWidth / 2
    //         fillMode: Image.PreserveAspectFit
    //         color: qgcPal.buttonText
    //         //source: "/res/config"
    //         source: "qrc:/res/cheveron-right.svg"
    //         sourceSize.width: ScreenTools.defaultFontPixelWidth * 4
    //         sourceSize.height: ScreenTools.defaultFontPixelHeight * 4
    //     }

    //     MouseArea {
    //         anchors.fill: parent
    //         onClicked: configPanelOpen = !configPanelOpen
    //     }
    // }

    // // Slide-in config panel
    // Rectangle {
    //     id: configPanel
    //     width: mainLayout.implicitWidth + ScreenTools.defaultFontPixelWidth * 2
    //     height: mainLayout.implicitHeight + ScreenTools.defaultFontPixelHeight * 2
    //     //y: parent.height - height - (ScreenTools.isMobile ? ScreenTools.defaultFontPixelHeight * 3 : ScreenTools.defaultFontPixelHeight * 2)
    //     //x: configPanelOpen ? parent.width - width - ScreenTools.defaultFontPixelWidth * 2 : parent.width
    //     x: configPanelOpen ? (ScreenTools.isMobile ? ScreenTools.defaultFontPixelWidth * 2 : parent.width - width - ScreenTools.defaultFontPixelWidth * 2) : (ScreenTools.isMobile ? -width : parent.width)
    //     y: ScreenTools.isMobile ? parent.height / 2 - height / 2 : parent.height - height - (ScreenTools.isMobile ? defaultFontPixelHeight * 3 : ScreenTools.defaultFontPixelHeight * 2)
    //     color: qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(1, 1, 1, 0.5) : Qt.rgba(0, 0, 0, 0.5)
    //     radius: ScreenTools.defaultFontPixelWidth

    //     Behavior on x {
    //         NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
    //     }

    //     ColumnLayout {
    //         id: mainLayout
    //         anchors.fill: parent
    //         anchors.margins: ScreenTools.defaultFontPixelWidth

    //         RowLayout {
    //             QGCLabel { text: "Telemetry" }
    //             Item { Layout.fillWidth: true }
    //             QGCToggleSwitch {
    //                 checked: QGroundControl.settingsManager.flyViewSettings.telemetryVisible.value
    //                 onCheckedChanged: QGroundControl.settingsManager.flyViewSettings.telemetryVisible.value = checked
    //             }
    //         }

    //         RowLayout {
    //             QGCLabel { text: "HUD" }
    //             Item { Layout.fillWidth: true }
    //             QGCToggleSwitch {
    //                 checked: QGroundControl.settingsManager.flyViewSettings.hudVisible.value
    //                 onCheckedChanged: QGroundControl.settingsManager.flyViewSettings.hudVisible.value = checked
    //             }
    //         }

    //         RowLayout {
    //             QGCLabel { text: "ToolStrip" }
    //             Item { Layout.fillWidth: true }
    //             QGCToggleSwitch {
    //                 checked: QGroundControl.settingsManager.flyViewSettings.toolStripVisible.value
    //                 onCheckedChanged: QGroundControl.settingsManager.flyViewSettings.toolStripVisible.value = checked
    //             }
    //         }

    //         RowLayout {
    //             QGCLabel { text: "Video" }
    //             Item { Layout.fillWidth: true }
    //             QGCToggleSwitch {
    //                 checked: QGroundControl.settingsManager.flyViewSettings.videoVisible.value
    //                 onCheckedChanged: QGroundControl.settingsManager.flyViewSettings.videoVisible.value = checked
    //             }
    //         }
    //     }
    // }
}
