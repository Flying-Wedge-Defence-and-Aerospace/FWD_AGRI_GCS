import QtQuick                  2.12
import QtQuick.Controls         2.15
import QtQuick.Dialogs          1.3
import QtQuick.Layouts          1.12

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

Rectangle {
    id: root
    implicitHeight: ScreenTools.defaultFontPixelHeight * 8
    implicitWidth: mainLayout.implicitWidth + ScreenTools.defaultFontPixelWidth * 1.5
    color: qgcPal.globalTheme === QGCPalette.Light ? Qt.rgba(1, 1, 1, 0.5) : "#88000000"
    radius: ScreenTools.defaultFontPixelWidth / 2

    property bool settingsUnlocked: false

    QGCPalette { id: qgcPal }

    // Fact Groups and their available facts mapping
    property var factGroupsMap: {
        "Vehicle": ["roll", "pitch", "heading", "rollRate", "pitchRate", "yawRate", "groundSpeed", "airSpeed", "climbRate", "altitudeRelative", "altitudeAMSL", "altitudeAboveTerr", "flightDistance", "distanceToHome", "timeToHome", "headingToHome", "distanceToGCS", "missionItemIndex", "headingToNextWP", "distanceToNextWP", "flightTime", "hobbs", "throttlePct", "imuTemp"],
        "Battery": ["id", "batteryFunction", "batteryType", "voltage", "percentRemaining", "mahConsumed", "current", "temperature", "instantPower", "timeRemaining", "timeRemainingStr", "chargeState"],
        "Clock": ["currentTime", "currentUTCTime", "currentDate"],
        "GPS": ["lat", "lon", "mgrs", "hdop", "vdop", "courseOverGround", "lock", "count"],
        "GPS2": ["lat", "lon", "mgrs", "hdop", "vdop", "courseOverGround", "lock", "count"],
        "GPSRTK": ["connected", "currentAccuracy", "currentLatitude", "currentLongitude", "currentAltitude", "currentDuration", "valid", "active", "numSatellites"],
        "Wind": ["direction", "speed", "verticalSpeed"],
        "LocalPosition": ["x", "y", "z", "vx", "vy", "vz"],
        "LocalPositionSetpoint": ["roll", "pitch", "yaw", "rollRate", "pitchRate", "yawRate"],
        "Vibration": ["xAxis", "yAxis", "zAxis", "clipCount1", "clipCount2", "clipCount3"],
        "Temperature": ["temperature1", "temperature2", "temperature3"],
        "EstimatorStatus": ["goodAttitudeEsimate", "goodHorizVelEstimate", "goodVertVelEstimate", "goodHorizPosRelEstimate", "goodHorizPosAbsEstimate", "goodVertPosAbsEstimate", "velRatio", "horizPosRatio", "vertPosRatio", "magRatio", "haglRatio", "tasRatio", "horizPosAccuracy", "vertPosAccuracy"],
        "ESC Status": ["index", "rpmFirst", "rpmSecond", "rpmThird", "rpmFourth", "currentFirst", "currentSecond", "currentThird", "currentFourth", "voltageFirst", "voltageSecond", "voltageThird", "voltageFourth"],
        "Generator": ["status", "genSpeed", "batteryCurrent", "loadCurrent", "powerGenerated", "busVoltage", "rectifierTemp", "batCurrentSetpoint", "genTemp", "runtime", "timeMaintenance"],
        "EFI": ["health", "ecuIndex", "rpm", "fuelConsumed", "fuelFlow", "engineLoad", "throttlePos", "sparkTime", "baroPress", "intakePress", "intakeTemp", "cylinderTemp", "ignTime", "injTime", "exGasTemp", "throttleOut", "ptComp"],
        "Terrain": ["blocksPending", "blocksLoaded"],
        "Hygrometer": ["temperature", "humidity", "hygrometerid"],
        "DistanceSensor": ["rotationNone", "rotationYaw45", "rotationYaw90", "rotationYaw135", "rotationYaw180", "rotationYaw225", "rotationYaw270", "rotationYaw315", "rotationPitch90", "rotationPitch270", "minDistance", "maxDistance"],
        "Submarine": ["cameraTilt", "tetherTurns", "lights1", "lights2", "pilotGain", "inputHold", "rangefinderDistance", "rollPitchToggle"]
    }

    // Function to add a new telemetry value
    function addTelemetryValue(factGroup, factName, label) {
        telemetryValues.push({ "factGroup": factGroup, "factName": factName, "label": label })
        telemetryValuesChanged()
    }

    // Function to remove last telemetry value
    function removeLastTelemetryValue() {
        if (telemetryValues.length > 1) {
            telemetryValues.pop()
            telemetryValuesChanged()
        }
    }

    // Model to store selected telemetry values
    property var telemetryValues: [
        { "factGroup": "Vehicle", "factName": "altitudeRelative", "label": "Alt Rel" },
        { "factGroup": "Vehicle", "factName": "flightTime", "label": "Time" },
        { "factGroup": "Battery", "factName": "voltage", "label": "Volt" },
        { "factGroup": "Battery", "factName": "current", "label": "Amp" },
        { "factGroup": "Vehicle", "factName": "distanceToHome", "label": "Dist to Home" },
        { "factGroup": "Vehicle", "factName": "climbRate", "label": "Climb Rate" },
        { "factGroup": "Vehicle", "factName": "flightDistance", "label": "Flight Dist" },
        { "factGroup": "Vehicle", "factName": "airSpeed", "label": "Air Speed" }
    ]

    Flickable {
        id: flickable
        anchors.fill: parent
        anchors.margins: ScreenTools.defaultFontPixelWidth / 2
        contentHeight: mainLayout.implicitHeight
        clip: true

        GridLayout {
            id: mainLayout
            width: parent.width
            columns: 4
            columnSpacing: ScreenTools.defaultFontPixelWidth * 4
            rowSpacing: ScreenTools.defaultFontPixelWidth * 2

            Repeater {
                model: root.telemetryValues

                Rectangle {
                    id: delegateRect
                    Layout.fillWidth: true
                    Layout.preferredWidth: 100  // Allow it to shrink/expand
                    implicitHeight: labelsRow.implicitHeight + ScreenTools.defaultFontPixelHeight
                    color: "transparent"
                    // border.color: "yellow"

                    property var factData: {
                        if (!_activeVehicle) return null
                        var groupName = modelData.factGroup
                        if (groupName === "Battery") {
                            return (_activeVehicle.batteries && _activeVehicle.batteries.count > 0)
                                    ? _activeVehicle.batteries.get(0)[modelData.factName] : null
                        }
                        var groupPropertyMap = {
                            "Vehicle": "", "GPS": "gps", "GPS2": "gps2", "GPSRTK": "gpsRTK",
                            "Wind": "wind", "LocalPosition": "localPosition",
                            "LocalPositionSetpoint": "localPositionSetpoint",
                            "Vibration": "vibration", "Temperature": "temperature",
                            "EstimatorStatus": "estimatorStatus", "ESC Status": "escStatus",
                            "Generator": "generator", "EFI": "efi", "Terrain": "terrain",
                            "Hygrometer": "hygrometer", "DistanceSensor": "distanceSensor",
                            "Submarine": "submarine", "Clock": "clock"
                        }
                        var propertyName = groupPropertyMap[groupName]
                        if (groupName === "Vehicle") {
                            return _activeVehicle[modelData.factName] || null
                        }
                        if (propertyName && _activeVehicle[propertyName]) {
                            return _activeVehicle[propertyName][modelData.factName] || null
                        }
                        return null
                    }

                    RowLayout {
                        id: labelsRow
                        anchors.centerIn: parent
                        spacing: ScreenTools.defaultFontPixelWidth

                        Column {
                            spacing: 0
                            QGCLabel {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.label
                                color: qgcPal.buttonText
                                font.pointSize: 7
                                font.bold: true
                            }
                            QGCLabel {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: delegateRect.factData ? delegateRect.factData.valueString : "N/A"
                                font.pointSize: 11
                                font.bold: true
                                color: qgcPal.text
                            }
                        }
                    }

                    // Delete label (visible in edit mode)
                    QGCLabel {
                        visible: root.settingsUnlocked
                        anchors.top: parent.top
                        anchors.right: parent.right
                        text: "X"
                        font.pointSize: 8
                        color: "red"
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.telemetryValues.splice(index, 1)
                                root.telemetryValuesChanged()
                            }
                        }
                    }
                }
            }
        }
    }

    QGCColoredImage {
        //anchors.margins:    _margins
        anchors.top:        parent.top
        anchors.right:      parent.right
        source:             "/res/gear-black.svg"
        mipmap:             true
        height:             ScreenTools.defaultFontPixelHeight * 1.5
        width:              height /*- 10*/
        sourceSize.height:  height
        color:              qgcPal.text
        fillMode:           Image.PreserveAspectFit

        QGCMouseArea {
            anchors.fill: parent
            onClicked: if(_activeVehicle) {
                root.settingsUnlocked = !root.settingsUnlocked
            }
        }
    }

    QGCButton {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 2
        visible: root.settingsUnlocked
        text: qsTr("+ Add")
        font.pointSize: 7
        backRadius: 3
        onClicked: valuePickerPopup.visible = true
    }

    Rectangle {
        id: valuePickerPopup
        visible: false
        x: -root.x
        y: -root.y
        width: mainWindow.width
        height: mainWindow.height
        color: "#80000000"

        MouseArea {
            anchors.fill: parent
            onClicked: valuePickerPopup.visible = false
        }

        Rectangle {
            id: dialogBox
            x: (mainWindow.width - width) / 2
            y: (mainWindow.height - height) / 2
            width: pickerColumn.implicitWidth + ScreenTools.defaultFontPixelWidth * 4
            height: pickerColumn.implicitHeight + ScreenTools.defaultFontPixelHeight * 2
            color: qgcPal.window
            radius: ScreenTools.defaultFontPixelWidth
            border.color: "yellow"
            border.width: 1

            property var selectedFactGroup: "Vehicle"
            property var selectedFactName: "altitudeRelative"

            ColumnLayout {
                id: pickerColumn
                anchors.fill: parent
                anchors.margins: ScreenTools.defaultFontPixelWidth * 2
                spacing: ScreenTools.defaultFontPixelHeight / 2

                QGCLabel {
                    text: qsTr("Add Telemetry Value")
                    font.bold: true
                    font.pointSize: 10
                    Layout.alignment: Qt.AlignHCenter
                }

                QGCLabel { text: qsTr("Fact Group:"); Layout.fillWidth: true }

                QGCComboBox {
                    id: factGroupCombo
                    Layout.fillWidth: true
                    Layout.preferredWidth: 200
                    model: Object.keys(root.factGroupsMap)
                    onCurrentTextChanged: {
                        dialogBox.selectedFactGroup = currentText
                        factNameCombo.model = root.factGroupsMap[currentText] || []
                        factNameCombo.currentIndex = 0
                    }
                }

                QGCLabel { text: qsTr("Fact Name:"); Layout.fillWidth: true }

                QGCComboBox {
                    id: factNameCombo
                    Layout.fillWidth: true
                    Layout.preferredWidth: 200
                    model: root.factGroupsMap[factGroupCombo.currentText] || []
                    onCurrentTextChanged: dialogBox.selectedFactName = currentText
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: ScreenTools.defaultFontPixelWidth

                    QGCButton {
                        text: qsTr("OK")
                        backRadius: 5
                        onClicked: {
                            var label = factNameCombo.currentText
                            root.addTelemetryValue(factGroupCombo.currentText, factNameCombo.currentText, label)
                            valuePickerPopup.visible = false
                        }
                    }

                    QGCButton {
                        text: qsTr("Cancel")
                        backRadius: 5
                        onClicked: valuePickerPopup.visible = false
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 2
        width: 4
        radius: 2
        color: qgcPal.buttonText
        opacity: 0.3
        visible: flickable.contentHeight > flickable.height

        Rectangle {
            width: parent.width
            height: Math.max(20, (flickable.height / flickable.contentHeight) * flickable.height)
            y: (flickable.contentY / flickable.contentHeight) * (flickable.height - height)
            radius: 2
            color: qgcPal.buttonText
            opacity: 0.8
        }
    }
}
