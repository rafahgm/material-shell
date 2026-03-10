import QtQuick
import Quickshell
import QtQuick.Layouts

import qs.Common
import qs.Common.Widgets
import qs.Services

Item {
    id: root
    property bool borderless: Config.options.bar.borderless
    property bool verbose
    implicitWidth: rowLayout.implicitWidth
    implicitHeight: Appearance.sizes.barHeight

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: 4

        Item {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: timeTextMetric.width
            implicitHeight: timeText.implicitHeight

            TextMetrics {
                id: timeTextMetric
                text: root.verbose ? "22:22:21" : "22:21"
                font.pixelSize: Appearance.font.pixelSize.large
            }

            StyledText {
                id: timeText
                font.pixelSize: Appearance.font.pixelSize.large
                color: Appearance.colors.colOnLayer1
                text: root.verbose ? DateTimeService.time : DateTimeService.shortTime
            }
        }
        

        StyledText {
            visible: root.verbose
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnLayer1
            text: "•"
        }

        StyledText {
            visible: root.verbose
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnLayer1
            text:  DateTimeService.longDate
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: !Config.options.bar.tooltips.clickToShow

        ClockWidgetPopup {
            hoverTarget: mouseArea
        }
    }
}