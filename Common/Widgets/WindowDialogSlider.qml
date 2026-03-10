pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets

import qs.Common
import qs.Services

Column {
    id: root

    property alias text: sliderName.text
    property alias from: sliderWidget.from
    property alias to: sliderWidget.to
    property alias value: sliderWidget.value
    property alias tooltipContent: sliderWidget.tooltipContent
    property alias stopIndicatorValues: sliderWidget.stopIndicatorValues

    signal moved()
    
    spacing: -2
    ContentSubsectionLabel {
        id: sliderName
        visible: text?.length > 0
        text: ""
        anchors {
            left: parent.left
            right: parent.right
        }
    }
    StyledSlider {
        id: sliderWidget
        anchors {
            left: parent.left
            right: parent.right
            leftMargin: 4
            rightMargin: 4
        }
        configuration: StyledSlider.Configuration.S
        onMoved: root.moved()
    }
}