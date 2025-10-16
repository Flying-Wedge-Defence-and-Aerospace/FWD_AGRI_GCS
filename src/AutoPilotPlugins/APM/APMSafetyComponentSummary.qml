import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.3

import QGroundControl.FactSystem 1.0
import QGroundControl.FactControls 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Palette 1.0

Item {
    anchors.fill:   parent

    FactPanelController { id: controller; }

    property Fact _copterFenceAction:       controller.getParameterFact(-1, "FENCE_ACTION", false /* reportMissing */)
    property Fact _copterFenceEnable:       controller.getParameterFact(-1, "FENCE_ENABLE", false /* reportMissing */)
    property Fact _copterFenceType:         controller.getParameterFact(-1, "FENCE_TYPE", false /* reportMissing */)

    property Fact _batt1Monitor:            controller.getParameterFact(-1, "BATT_MONITOR")
    property Fact _batt2Monitor:            controller.getParameterFact(-1, "BATT2_MONITOR", false /* reportMissing */)
    property bool _batt2MonitorAvailable:   controller.parameterExists(-1, "BATT2_MONITOR")
    property bool _batt1MonitorEnabled:     _batt1Monitor.rawValue !== 0
    property bool _batt2MonitorEnabled:     _batt2MonitorAvailable && _batt2Monitor.rawValue !== 0

    property Fact _batt1FSLowAct:           controller.getParameterFact(-1, "r.BATT_FS_LOW_ACT", false /* reportMissing */)
    property Fact _batt1FSCritAct:          controller.getParameterFact(-1, "BATT_FS_CRT_ACT", false /* reportMissing */)
    property Fact _batt2FSLowAct:           controller.getParameterFact(-1, "BATT2_FS_LOW_ACT", false /* reportMissing */)
    property Fact _batt2FSCritAct:          controller.getParameterFact(-1, "BATT2_FS_CRT_ACT", false /* reportMissing */)
    property bool _batt1FSCritActAvailable: controller.parameterExists(-1, "BATT_FS_CRT_ACT")

    property bool _roverFirmware:           controller.parameterExists(-1, "MODE1") // This catches all usage of ArduRover firmware vehicle types: Rover, Boat...


    ColumnLayout {
        anchors.fill:       parent

        VehicleSummaryRow {
            labelText: qsTr("Arming Checks")
            valueText: fact ? (fact.value & 1 ? qsTr("Enabled") : qsTr("Some disabled")) : ""

            property Fact fact: controller.getParameterFact(-1, "ARMING_CHECK")
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "white"
            opacity: 0.3
        }

        VehicleSummaryRow {
            id: multiRotorFailSafe
            labelText:  qsTr("Throttle failsafe")
            valueText:  fact ? fact.enumStringValue : ""
            visible:    controller.vehicle.multiRotor

            property Fact fact: controller.getParameterFact(-1, "FS_THR_ENABLE", false /* reportMissing */)
        }

        Rectangle {
            visible: multiRotorFailSafe.visible
            Layout.fillWidth: true
            height: 1
            color: "white"
            opacity: 0.3
        }

        VehicleSummaryRow {
            id: fixedWingFailSafe
            labelText:  qsTr("Throttle failsafe")
            valueText:  fact ? fact.enumStringValue : ""
            visible:    controller.vehicle.fixedWing

            property Fact fact: controller.getParameterFact(-1, "THR_FAILSAFE", false /* reportMissing */)
        }

        Rectangle {
            visible:  fixedWingFailSafe.visible ? true : false
            Layout.fillWidth: true
            height: 1
            color: "white"
            opacity: 0.3
        }

        VehicleSummaryRow {
            id: roverFailSafe
            labelText:  qsTr("Throttle failsafe")
            valueText:  fact ? fact.enumStringValue : ""
            visible:    _roverFirmware

            property Fact fact: controller.getParameterFact(-1, "FS_THR_ENABLE", false /* reportMissing */)
        }

        Rectangle {
            visible:  roverFailSafe.visible ? true : false
            Layout.fillWidth: true
            height: 1
            color: "white"
            opacity: 0.3
        }

        VehicleSummaryRow {
            id: roverFailSafeAction
            labelText:  qsTr("Failsafe Action")
            valueText:  fact ? fact.enumStringValue : ""
            visible:    _roverFirmware

            property Fact fact: controller.getParameterFact(-1, "FS_ACTION", false /* reportMissing */)
        }

        Rectangle {
            visible:  roverFailSafeAction.visible ? true : false
            Layout.fillWidth: true
            height: 1
            color: "white"
            opacity: 0.3
        }

        VehicleSummaryRow {
            id: roverFailSafeCrashCheck
            labelText:  qsTr("Failsafe Crash Check")
            valueText:  fact ? fact.enumStringValue : ""
            visible:    _roverFirmware

            property Fact fact: controller.getParameterFact(-1, "FS_CRASH_CHECK", false /* reportMissing */)
        }

        Rectangle {
            visible:  roverFailSafeCrashCheck.visible ? true : false
            Layout.fillWidth: true
            height: 1
            color: "white"
            opacity: 0.3
        }

        VehicleSummaryRow {
            id: batt1LowFailSafe
            labelText:  qsTr("Batt1 low failsafe")
            valueText:  _batt1MonitorEnabled ? _batt1FSLowAct.enumStringValue : ""
            visible:    _batt1MonitorEnabled
        }

        Rectangle {
            visible:  batt1LowFailSafe.visible ? true : false
            Layout.fillWidth: true
            height: 1
            color: "white"
            opacity: 0.3
        }

        VehicleSummaryRow {
            id: batt1CriticalFailSafe
            labelText:  qsTr("Batt1 critical failsafe")
            valueText:  _batt1FSCritActAvailable ? _batt1FSCritAct.enumStringValue : ""
            visible:    _batt1FSCritActAvailable
        }

        Rectangle {
            visible:  batt1CriticalFailSafe.visible ? true : false
            Layout.fillWidth: true
            height: 1
            color: "white"
            opacity: 0.3
        }

        VehicleSummaryRow {
            id: batt2LowFailSafe
            labelText:  qsTr("Batt2 low failsafe")
            valueText:  _batt2MonitorEnabled ? _batt2FSLowAct.enumStringValue : ""
            visible:    _batt2MonitorEnabled
        }

        Rectangle {
            visible:  batt2LowFailSafe.visible ? true : false
            Layout.fillWidth: true
            height: 1
            color: "white"
            opacity: 0.3
        }

        VehicleSummaryRow {
            id: batt2CriticalFailSafe
            labelText:  qsTr("Batt2 critical failsafe")
            valueText:  _batt2MonitorEnabled ? _batt2FSCritAct.enumStringValue : ""
            visible:    _batt2MonitorEnabled
        }

        Rectangle {
            visible:  batt2CriticalFailSafe.visible ? true : false
            Layout.fillWidth: true
            height: 1
            color: "white"
            opacity: 0.3
        }

        VehicleSummaryRow {
            id: geoFenceEnable
            labelText: qsTr("GeoFence")
            valueText: {
                if(_copterFenceEnable && _copterFenceType) {
                    if(_copterFenceEnable.value === 0 || _copterFenceType === 0) {
                        return qsTr("Disabled")
                    } else {
                        if(_copterFenceType.value === 1) {
                            return qsTr("Altitude")
                        }
                        if(_copterFenceType.value === 2) {
                            return qsTr("Circle")
                        }
                        return qsTr("Altitude,Circle")
                    }
                }
                return ""
            }
            visible: controller.vehicle.multiRotor
        }

        Rectangle {
            visible:  geoFenceEnable.visible ? true : false
            Layout.fillWidth: true
            height: 1
            color: "white"
            opacity: 0.3
        }

        VehicleSummaryRow {
            id: geoFenceAction
            labelText: qsTr("GeoFence")
            valueText: _copterFenceAction.value === 0 ?
                           qsTr("Report only") :
                           (_copterFenceAction.value === 1 ? qsTr("RTL or Land") : qsTr("Unknown"))
            visible: controller.vehicle.multiRotor && _copterFenceEnable.value !== 0
        }

        Rectangle {
            visible:  geoFenceAction.visible ? true : false
            Layout.fillWidth: true
            height: 1
            color: "white"
            opacity: 0.3
        }

        VehicleSummaryRow {
            id: rtlMinAltMR
            labelText:  qsTr("RTL min alt")
            valueText:  fact ? (fact.value === 0 ? qsTr("current") : fact.valueString + " " + fact.units) : ""
            visible:    controller.vehicle.multiRotor

            property Fact fact: controller.getParameterFact(-1, "RTL_ALT", false /* reportMissing */)
        }

        Rectangle {
            visible:  rtlMinAltMR.visible ? true : false
            Layout.fillWidth: true
            height: 1
            color: "white"
            opacity: 0.3
        }

        VehicleSummaryRow {
            labelText:  qsTr("RTL min alt")
            valueText:  fact ? (fact.value < 0 ? qsTr("current") : fact.valueString + " " + fact.units) : ""
            visible:    controller.vehicle.fixedWing

            property Fact fact: controller.getParameterFact(-1, "ALT_HOLD_RTL", false /* reportMissing */)
        }
    }
}
