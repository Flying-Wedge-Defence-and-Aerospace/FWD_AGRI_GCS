import QtQuick          2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts  1.12

import QGroundControl.Palette       1.0
import QGroundControl.ScreenTools   1.0
import QGroundControl.Controls      1.0

Popup {
    id: _root

    property string updateVersion: ""
    property string changelog: ""
    property real   downloadProgress: 0
    property bool   downloading: false
    property string statusMessage: ""

    property var    _pal: QGroundControl.globalPalette

    parent: Overlay.overlay
    anchors.centerIn: parent
    width:  Math.min(ScreenTools.defaultFontPixelWidth * 60, parent.width * 0.8)
    height: mainColumn.height + padding * 2
    padding: ScreenTools.defaultFontPixelHeight
    modal: true
    focus: true
    closePolicy: Popup.NoAutoClose

    background: Rectangle {
        color: _pal.window
        border.color: _pal.text
        border.width: 1
        radius: ScreenTools.defaultFontPixelHeight / 2
    }

    ColumnLayout {
        id: mainColumn
        width: parent.width - _root.padding * 2
        spacing: ScreenTools.defaultFontPixelHeight

        // Title
        RowLayout {
            Layout.fillWidth: true

            QGCLabel {
                text: qsTr("Update Available")
                font.pointSize: ScreenTools.largeFontPointSize
                font.bold: true
                color: _pal.text
                Layout.fillWidth: true
            }

            QGCLabel {
                text: _root.updateVersion
                font.pointSize: ScreenTools.mediumFontPointSize
                color: _pal.colorGreen
            }
        }

        // Separator
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: _pal.text
            opacity: 0.3
        }

        // Changelog
        QGCLabel {
            text: qsTr("What's new:")
            font.bold: true
            color: _pal.text
        }

        Flickable {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 12
            clip: true
            contentHeight: changelogText.height

            QGCLabel {
                id: changelogText
                width: parent.width
                text: _root.changelog.isEmpty() ? qsTr("No changelog available.") : _root.changelog
                wrapMode: Text.WordWrap
                color: _pal.text
            }
        }

        // Progress bar (shown during download)
        ColumnLayout {
            Layout.fillWidth: true
            visible: _root.downloading
            spacing: ScreenTools.defaultFontPixelHeight / 2

            QGCLabel {
                text: qsTr("Downloading update...")
                color: _pal.text
            }

            ProgressBar {
                id: progressBar
                Layout.fillWidth: true
                from: 0
                to: 100
                value: _root.downloadProgress

                background: Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: ScreenTools.defaultFontPixelHeight
                    color: _pal.windowShade
                    radius: height / 2
                }

                contentItem: Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: ScreenTools.defaultFontPixelHeight
                    radius: height / 2
                    color: _pal.colorGreen

                    width: progressBar.visualPosition * parent.width
                }
            }

            QGCLabel {
                text: Math.round(_root.downloadProgress) + "%"
                color: _pal.text
                Layout.alignment: Qt.AlignHCenter
            }
        }

        // Status message
        QGCLabel {
            Layout.fillWidth: true
            visible: _root.statusMessage.length > 0
            text: _root.statusMessage
            color: _pal.colorRed
            wrapMode: Text.WordWrap
        }

        // Buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: ScreenTools.defaultFontPixelHeight

            QGCButton {
                text: _root.downloading ? qsTr("Cancel") : qsTr("Later")
                Layout.fillWidth: true
                onClicked: {
                    _root.close()
                }
            }

            QGCButton {
                text: qsTr("Update Now")
                primary: true
                Layout.fillWidth: true
                visible: !_root.downloading
                onClicked: {
                    _root.downloading = true
                    _root.downloadProgress = 0
                    _root.statusMessage = ""
                    // Signal to C++ to start download
                    _root.startDownload()
                }
            }

            QGCButton {
                text: qsTr("Restart Now")
                primary: true
                Layout.fillWidth: true
                visible: _root.statusMessage === "download_complete"
                onClicked: {
                    // Signal to C++ to install and restart
                    _root.installAndRestart()
                }
            }
        }
    }

    // Signals to communicate with C++
    signal startDownload()
    signal installAndRestart()

    // Called from C++ when download progress updates
    function updateProgress(received, total) {
        if (total > 0) {
            _root.downloadProgress = (received / total) * 100
        }
    }

    // Called from C++ when download is complete
    function downloadComplete(filePath) {
        _root.downloading = false
        _root.statusMessage = "download_complete"
    }

    // Called from C++ when download fails
    function downloadFailed(error) {
        _root.downloading = false
        _root.statusMessage = qsTr("Download failed: ") + error
    }
}
