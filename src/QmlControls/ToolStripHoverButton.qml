/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/

import QtQuick              2.3
import QtQuick.Controls     2.2
import QtGraphicalEffects   1.0

import QGroundControl.ScreenTools   1.0
import QGroundControl.Palette       1.0

Button {
    id:             control
    width:          contentLayoutItem.contentWidth + (contentMargins * 2)
    height:         width + 30
    hoverEnabled:   !ScreenTools.isMobile
    enabled:        toolStripAction.enabled
    visible:        toolStripAction.visible
    imageSource:    toolStripAction.showAlternateIcon ? modelData.alternateIconSource : modelData.iconSource
    text:           toolStripAction.text
    checked:        toolStripAction.checked
    checkable:      toolStripAction.dropPanelComponent || modelData.checkable

    property var    toolStripAction:    undefined
    property var    dropPanel:          undefined
    property alias  radius:             buttonBkRect.radius
    property alias  fontPointSize:      innerText.font.pointSize
    property alias  imageSource:        innerImage.source
    property alias  contentWidth:       innerText.contentWidth

    property bool forceImageScale11: false
    property real imageScale:        forceImageScale11 && (text == "") ? 0.8 : 0.6
    property real contentMargins:    innerText.height * 0.1

    property color _currentContentColor:  (checked || pressed) ? qgcPal.buttonHighlightText : qgcPal.buttonText
    property color _currentContentColorSecondary:  (checked || pressed) ? qgcPal.buttonText : qgcPal.buttonHighlight

    signal dropped(int index)

    onCheckedChanged: toolStripAction.checked = checked

    onClicked: {
        dropPanel.hide()
        if (!toolStripAction.dropPanelComponent) {
            toolStripAction.triggered(this)
        } else if (checked) {
            var panelEdgeTopPoint = mapToItem(_root, width, 0)
            dropPanel.show(panelEdgeTopPoint, toolStripAction.dropPanelComponent, this)
            checked = true
            control.dropped(index)
        }
    }

    QGCPalette { id: qgcPal; colorGroupEnabled: control.enabled }

    contentItem: Item {
        id:                 contentLayoutItem
        anchors.fill:       parent
        anchors.margins:    contentMargins

        Column {
            anchors.centerIn:   parent
            spacing:        (contentMargins * 2) - 5

            Image {
                id:                         innerImageColorful
                height:                     contentLayoutItem.height * imageScale - 50
                width:                      contentLayoutItem.width  * imageScale - 50
                smooth:                     true
                mipmap:                     true
                fillMode:                   Image.PreserveAspectFit
                antialiasing:               true
                sourceSize.height:          height
                sourceSize.width:           width
                anchors.horizontalCenter:   parent.horizontalCenter
                source:                     control.imageSource
                visible:                    source != "" && modelData.fullColorIcon
            }

            QGCColoredImage {
                id:                         innerImage
                height:                     contentLayoutItem.height * imageScale
                width:                      contentLayoutItem.width  * imageScale
                smooth:                     true
                mipmap:                     true
                color:                      /*_currentContentColor*/ "white"
                fillMode:                   Image.PreserveAspectFit
                antialiasing:               true
                sourceSize.height:          height
                sourceSize.width:           width
                anchors.horizontalCenter:   parent.horizontalCenter
                visible:                    source != "" && !modelData.fullColorIcon
                
                QGCColoredImage {
                    id:                         innerImageSecondColor
                    source:                     modelData.alternateIconSource
                    height:                     contentLayoutItem.height * imageScale
                    width:                      contentLayoutItem.width  * imageScale
                    smooth:                     true
                    mipmap:                     true
                    color:                      /*_currentContentColorSecondary*/ "white"
                    fillMode:                   Image.PreserveAspectFit
                    antialiasing:               true
                    sourceSize.height:          height
                    sourceSize.width:           width
                    anchors.horizontalCenter:   parent.horizontalCenter
                    visible:                    source != "" && modelData.biColorIcon
                }
            }

            QGCLabel {
                id:                         innerText
                text:                       control.text
                color:                      /*_currentContentColor*/ "white"
                anchors.horizontalCenter:   parent.horizontalCenter
                font.bold:                  !innerImage.visible && !innerImageColorful.visible
                opacity:                    !innerImage.visible ? 0.8 : 1.0
                //visible: false
            }
        }
    }

    // background: Rectangle {
    //     id:             buttonBkRect
    //     color:          /*(control.checked || control.pressed) ?
    //                         qgcPal.buttonHighlight :
    //                         (control.hovered ? qgcPal.toolStripHoverColor : qgcPal.toolbarBackground)*/ /*"darkred"*/ "black"
    //     anchors.fill:   parent
    //     //radius: 100                         // round corners (adjust value)
    //     border.width:2                   // thickness of border
    //     border.color: "white"
    // }

    // background: Rectangle {
    //     id: buttonBkRect
    //     anchors.fill: parent
    //     radius: 8
    //     border.width: 2
    //     // Border + fill change with enabled/disabled
    //     border.color: control.enabled ? "white" : "#5D6D7E"
    //     color: control.enabled ? "#000000" : "#7F8C8D"   // enabled / disabled

    //     // (optional) nice fade when state changes
    //     Behavior on color        { ColorAnimation { duration: 150 } }
    //     Behavior on border.color { ColorAnimation { duration: 150 } }
    //     // (optional) dim the whole button when disabled
    //     opacity: control.enabled ? 1.0 : 0.7
    // }

    background: Rectangle {
        id: buttonBkRect
        anchors.fill: parent
        radius: 1
        border.width: 1
        border.color: "white"

        color: !control.enabled
               ? "gray"                          // disabled
               : control.hovered
                 ? "#1aa1a1"                     // hover effect (slightly lighter black)
                 : "black"                       // normal enabled

        Behavior on color { ColorAnimation { duration: 150 } }
    }
}
