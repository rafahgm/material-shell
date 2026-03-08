import QtQuick
import QtQuick.Layouts

import qs.Modules.Common
import qs.Services

MouseArea {
    id: root
    property bool borderless: Config.options?.bar?.borderless ?? false
    property bool alwaysShowAllResources: false
    implicitWidth: rowLayout.implicitWidth + rowLayout.anchors.leftMargin + rowLayout.anchors.rightMargin
    implicitHeight: Appearance.sizes.barHeight
    hoverEnabled: true

    Component.onCompleted: ResourceUsageService.ensureRunning()

    RowLayout {
        id: rowLayout

        spacing: 0
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4

        Resource {
            iconName: "memory"
            percentage: ResourceUsageService.memoryUsedPercentage
            warningThreshold: Config.options?.bar?.resources?.memoryWarningThreshold ?? 90
        }

        Resource {
            iconName: "thermostat"
            percentage: ResourceUsageService.tempPercentage
            shown: (Config.options?.bar?.resources?.alwaysShowTemp ?? true) || 
                (MprisController.activePlayer?.trackTitle == null) ||
                root.alwaysShowAllResources
            Layout.leftMargin: shown ? 6 : 0
            cautionThreshold: Config.options?.bar?.resources?.tempCautionThreshold ?? 65
            warningThreshold: Config.options?.bar?.resources?.tempWarningThreshold ?? 80
        }

        Resource {
            iconName: "planner_review"
            percentage: ResourceUsageService.cpuUsage
            shown: (Config.options?.bar?.resources?.alwaysShowCpu ?? false) || 
                !(MprisController.activePlayer?.trackTitle?.length > 0) ||
                root.alwaysShowAllResources
            Layout.leftMargin: shown ? 6 : 0
            warningThreshold: Config.options?.bar?.resources?.cpuWarningThreshold ?? 90
        }

    }

    ResourcesPopup {
        hoverTarget: root
    }
}