/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick          2.11
import QtQuick.Layouts  1.11
import QtQuick.Controls 2.5

import QGroundControl                       1.0
import QGroundControl.Controls              1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.Palette               1.0
import QGroundControl.FactSystem            1.0

RowLayout {
   id:         _root
   spacing:    5

   property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
   property var    _vehicleInAir:      _activeVehicle ? _activeVehicle.flying || _activeVehicle.landing : false
   property bool   _vtolInFWDFlight:   _activeVehicle ? _activeVehicle.vtolInFwdFlight : false
   property bool   _armed:             _activeVehicle ? _activeVehicle.armed : false
   property real   _margins:           ScreenTools.defaultFontPixelWidth
   property real   _spacing:           ScreenTools.defaultFontPixelWidth / 2
   property bool   _healthAndArmingChecksSupported: _activeVehicle ? _activeVehicle.healthAndArmingCheckReport.supported : false

   Rectangle {
      color: mainStatusLabel._mainStatusBGColor
      width: 200
      height: 30
      radius: 10
      //Layout.preferredHeight: parent.height * 1
      //Layout.fillHeight: true
      // anchors.topMargin: 20
      // anchors.rightMargin: 20

      QGCLabel {
         id:             mainStatusLabel
         text:           mainStatusText()
         font.bold: true
         font.pointSize: /*_vehicleInAir ? ScreenTools.defaultFontPointSize : ScreenTools.largeFontPointSize*/ 12
         property color _mainStatusBGColor: "#696969"
         anchors.centerIn: parent


         property string _commLostText:      qsTr("Communication Lost")
         property string _readyToFlyText:    qsTr("Ready To Fly")
         property string _notReadyToFlyText: qsTr("Not Ready")
         property string _disconnectedText:  qsTr("Disconnected")
         property string _armedText:         qsTr("Armed")
         property string _flyingText:        qsTr("Flying")
         property string _landingText:       qsTr("Landing")

         function mainStatusText() {
            if (_activeVehicle) {
               if (_communicationLost) {
                  _mainStatusBGColor = "#8B0000"
                  return _commLostText
               }

               if (_activeVehicle.armed) {
                  // armed → check flight state
                  if (_activeVehicle.flying) {
                     _mainStatusBGColor = "#1E90FF"
                     return _flyingText
                  } else if (_activeVehicle.landing) {
                     _mainStatusBGColor = "#FF8C00"
                     return _landingText
                  } else {
                     _mainStatusBGColor = "#006400"
                     return _armedText
                  }
               }
               // not armed → check readiness
               if (_healthAndArmingChecksSupported)
               {
                  if (_activeVehicle.healthAndArmingCheckReport.canArm)
                  {
                     if (_activeVehicle.healthAndArmingCheckReport.hasWarningsOrErrors)
                     {
                        _mainStatusBGColor = "#999900"
                     }
                     else
                     {
                        _mainStatusBGColor = "#006400"
                     }
                     return _readyToFlyText
                  }
                  else
                  {
                     _mainStatusBGColor = "#8B0000"
                     return _notReadyToFlyText
                  }
               }
               else if (_activeVehicle.readyToFlyAvailable)
               {
                  if (_activeVehicle.readyToFly) {
                     _mainStatusBGColor = "#006400"
                     return _readyToFlyText
                  }
                  else
                  {
                     _mainStatusBGColor = "#999900"
                     return _notReadyToFlyText
                  }
               }
               else
               {
                  if (_activeVehicle.allSensorsHealthy && _activeVehicle.autopilot.setupComplete)
                  {
                     _mainStatusBGColor = "#006400"
                     return _readyToFlyText
                  }
                  else
                  {
                     _mainStatusBGColor = "#999900"
                     return _notReadyToFlyText
                  }
               }
            }
            // fallback case: no vehicle connected
            _mainStatusBGColor = qgcPal.brandingPurple
            return _disconnectedText
         }

         ToolTip.visible: statusText.containsMouse
         ToolTip.text: "Vehicle Status"

         QGCMouseArea {
            id: statusText
            anchors.left:           parent.left
            anchors.right:          parent.right
            anchors.verticalCenter: parent.verticalCenter
            height:                 _root.height
            enabled:                _activeVehicle
            hoverEnabled: true
            onClicked:              mainWindow.showIndicatorPopup(mainStatusLabel, sensorStatusInfoComponent)
         }
      }
   }

   Item {
      Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * ScreenTools.largeFontPointRatio * 1.5
      height:                 1
   }

   // FlightModeMenuIndicator {
   //    id:                     flightModeMenu
   //    Layout.preferredHeight: _root.height
   //    fontPointSize:          _vehicleInAir ?  ScreenTools.largeFontPointSize : ScreenTools.defaultFontPointSize
   //    visible:                _activeVehicle
   // }

   // QGCButton {
   //    id: disconnectButton
   //    text: "Disconnect"
   //    backRadius: 7
   //    onClicked: _activeVehicle.closeVehicle()
   //    visible: _activeVehicle && _communicationLost
   // }

   Item {
      Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * ScreenTools.largeFontPointRatio * 1.5
      height:                 1
      visible:                vtolModeLabel.visible
   }

   QGCLabel {
      id:                     vtolModeLabel
      Layout.preferredHeight: _root.height
      verticalAlignment:      Text.AlignVCenter
      text:                   _vtolInFWDFlight ? qsTr("FW(vtol)") : qsTr("MR(vtol)")
      font.pointSize:         ScreenTools.largeFontPointSize
      visible:                _activeVehicle ? _activeVehicle.vtol && _vehicleInAir : false

      QGCMouseArea {
         anchors.fill:   parent
         onClicked:      mainWindow.showIndicatorPopup(vtolModeLabel, vtolTransitionComponent)
      }
   }

   Component {
      id: sensorStatusInfoComponent

      Rectangle {
         width:          flickable.width + (_margins * 2)
         height:         flickable.height + (_margins * 2)
         radius:         ScreenTools.defaultFontPixelHeight * 0.5
         color:          /*qgcPal.window*/ "#2c3e50"
         border.color:   qgcPal.text

         QGCFlickable {
            id:                 flickable
            anchors.margins:    _margins
            anchors.top:        parent.top
            anchors.left:       parent.left
            width:              mainLayout.width
            height:             mainWindow.contentItem.height - (indicatorPopup.padding * 2) - (_margins * 2)
            flickableDirection: Flickable.VerticalFlick
            contentHeight:      mainLayout.height
            contentWidth:       mainLayout.width

            ColumnLayout {
               id:         mainLayout
               spacing:    _spacing + 15

               QGCButton {
                  Layout.topMargin: 15
                  Layout.leftMargin:  _healthAndArmingChecksSupported ? width / 2 : 0
                  Layout.alignment:   _healthAndArmingChecksSupported ? Qt.AlignLeft : Qt.AlignHCenter
                  Layout.fillWidth: true
                  // FIXME: forceArm is not possible anymore if _healthAndArmingChecksSupported == true
                  enabled:            _armed || !_healthAndArmingChecksSupported || _activeVehicle.healthAndArmingCheckReport.canArm
                  text:               _armed ?  qsTr("Disarm") : (forceArm ? qsTr("Force Arm") : qsTr("Arm"))
                  font.bold: true
                  backRadius: 7

                  property bool forceArm: false

                  onPressAndHold: forceArm = true

                  onClicked: {
                     if (_armed) {
                        mainWindow.disarmVehicleRequest()
                     } else {
                        if (forceArm) {
                           mainWindow.forceArmVehicleRequest()
                        } else {
                           mainWindow.armVehicleRequest()
                        }
                     }
                     forceArm = false
                     mainWindow.hideIndicatorPopup()
                  }
               }

               QGCLabel {
                  Layout.alignment:   Qt.AlignHCenter
                  text:               qsTr("SENSOR STATUS")
                  font.bold: true
                  visible:            !_healthAndArmingChecksSupported
               }

               GridLayout {
                  rowSpacing:     _spacing + 10
                  columnSpacing:  _spacing + 50
                  rows:           _activeVehicle.sysStatusSensorInfo.sensorNames.length
                  flow:           GridLayout.TopToBottom
                  visible:        !_healthAndArmingChecksSupported

                  Repeater {
                     model: _activeVehicle.sysStatusSensorInfo.sensorNames

                     QGCLabel {
                        text: modelData
                        font.bold: true
                     }
                  }

                  Repeater {
                     model: _activeVehicle.sysStatusSensorInfo.sensorStatus

                     QGCLabel {
                        text: modelData
                     }
                  }
               }


               QGCLabel {
                  text:               qsTr("Arming Check Report:")
                  visible:            _healthAndArmingChecksSupported && _activeVehicle.healthAndArmingCheckReport.problemsForCurrentMode.count > 0
               }

               // List health and arming checks
               QGCListView {
                  visible:            _healthAndArmingChecksSupported
                  anchors.margins:    ScreenTools.defaultFontPixelHeight
                  spacing:            ScreenTools.defaultFontPixelWidth
                  width:              mainWindow.width * 0.66666
                  height:             contentHeight
                  model:              _activeVehicle ? _activeVehicle.healthAndArmingCheckReport.problemsForCurrentMode : null
                  delegate:           listdelegate
               }

               FactPanelController {
                  id: controller
               }

               Component {
                  id: listdelegate

                  Column {
                     width:      parent ? parent.width : 0

                     Row {
                        width:  parent.width

                        QGCLabel {
                           id:           message
                           text:         object.message
                           wrapMode:     Text.WordWrap
                           textFormat:   TextEdit.RichText
                           width:        parent.width - arrowDownIndicator.width
                           color:        object.severity === 'error' ? qgcPal.colorRed : object.severity === 'warning' ? qgcPal.colorOrange : qgcPal.text

                           MouseArea {
                              anchors.fill: parent
                              onClicked: {
                                 if (object.description !== "") {
                                    object.expanded = !object.expanded
                                 }
                              }
                           }
                        }

                        QGCColoredImage {
                           id:                     arrowDownIndicator
                           height:                 1.5 * ScreenTools.defaultFontPixelWidth
                           width:                  height
                           source:                 "/qmlimages/arrow-down.png"
                           color:                  qgcPal.text
                           visible:                object.description !== ""

                           MouseArea {
                              anchors.fill:       parent
                              onClicked:          object.expanded = !object.expanded
                           }
                        }
                     }

                     Rectangle {
                        property var margin:      ScreenTools.defaultFontPixelWidth
                        id:                       descriptionRect
                        width:                    parent.width
                        height:                   description.height + margin
                        color:                    qgcPal.windowShade
                        visible:                  false

                        Connections {
                           target:               object
                           function onExpandedChanged() {
                              if (object.expanded) {
                                 description.height = description.preferredHeight
                              } else {
                                 description.height = 0
                              }
                           }
                        }

                        Behavior on height {
                           NumberAnimation {
                           id: animation
                           duration: 150
                           onRunningChanged: {
                              descriptionRect.visible = animation.running || object.expanded
                              }
                           }
                        }

                        QGCLabel {
                           id:                 description
                           anchors.centerIn:   parent
                           width:              parent.width - parent.margin * 2
                           height:             0
                           text:               object.description
                           textFormat:         TextEdit.RichText
                           wrapMode:           Text.WordWrap
                           clip:               true
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
                              fact:           description.fact
                              destroyOnClose: true
                           }
                        }
                     }
                  }
               }
            }
         }
      }
   }

   Component {
      id: vtolTransitionComponent

      Rectangle {
         width:          mainLayout.width   + (_margins * 2)
         height:         mainLayout.height  + (_margins * 2)
         radius:         ScreenTools.defaultFontPixelHeight * 0.5
         color:          qgcPal.window
         border.color:   qgcPal.text

         QGCButton {
            id:                 mainLayout
            anchors.margins:    _margins
            anchors.top:        parent.top
            anchors.left:       parent.left
            text:               _vtolInFWDFlight ? qsTr("Transition to Multi-Rotor") : qsTr("Transition to Fixed Wing")

            onClicked: {
               if (_vtolInFWDFlight) {
                  mainWindow.vtolTransitionToMRFlightRequest()
               } else {
                  mainWindow.vtolTransitionToFwdFlightRequest()
               }
               mainWindow.hideIndicatorPopup()
            }
         }
      }
   }
}

