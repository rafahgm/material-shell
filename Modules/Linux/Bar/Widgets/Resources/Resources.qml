import QtQuick
import QtQuick.Layouts

import qs.Common
import qs.Services

MouseArea {
    id: root
    property bool borderless: Config.options.bar.borderless
    property bool alwaysShowAllResources: false
    implicitWidth: rowLayout.implicitWidth + rowLayout.anchors.leftMargin + rowLayout.anchors.rightMargin
    implicitHeight: Appearance.sizes.barHeight
    hoverEnabled: !Config.options.bar.tooltips.clickToShow
    
    Component.onCompleted: {
        DgopService.addRef(["memory", "cpu"])
    }

    Component.onDestruction: {
        DgopService.removeRef(["memory", "cpu"])
    }

    RowLayout {
        id: rowLayout

        spacing: 0
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4

        Resource {
            iconName: "memory"
            percentage: DgopService.memoryUsedPercent
            warningThreshold: Config.options.bar.resources.memoryWarningThreshold
        }

        Resource {
            iconName: "planner_review"
            percentage: DgopService.cpuUsage
            shown: Config.options.bar.resources.alwaysShowCpu || root.alwaysShowAllResources
            Layout.leftMargin: shown ? 6 : 0
            warningThreshold: Config.options.bar.resources.cpuWarningThreshold
        }
    }

    ResourcesPopup {
        hoverTarget: root
    }
}