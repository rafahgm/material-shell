import QtQuick
import QtQuick.Layouts

import qs.Modules.Common
import qs.Modules.Common.Widgets
import qs.Modules.Linux.Bar
import qs.Services
import qs.Modules.Linux.Bar.Widgets

StyledPopup {
    id: popup

    onActiveChanged: {
        if (popup.active)
            ResourceUsageService.ensureRunning()
    }

    component ResourceItem: RowLayout {
        id: resourceItem
        required property string icon
        required property string label
        required property string value
        spacing: 4

        MaterialSymbol {
            text: resourceItem.icon
            color: Appearance.colors.colOnSurfaceVariant
            iconSize: Appearance.font.pixelSize.large
        }
        StyledText {
            text: resourceItem.label
            color: Appearance.colors.colOnSurfaceVariant
        }
        StyledText {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignRight
            visible: resourceItem.value !== ""
            color: Appearance.colors.colOnSurfaceVariant
            text: resourceItem.value
        }
    }

    component ResourceHeaderItem: Row {
        id: headerItem
        required property var icon
        required property var label
        spacing: 5

        MaterialSymbol {
            anchors.verticalCenter: parent.verticalCenter
            fill: 0
            font.weight: Font.Medium
            text: headerItem.icon
            iconSize: Appearance.font.pixelSize.large
            color: Appearance.colors.colOnSurfaceVariant
        }

        StyledText {
            anchors.verticalCenter: parent.verticalCenter
            text: headerItem.label
            font {
                weight: Font.Medium
                pixelSize: Appearance.font.pixelSize.normal
            }
            color: Appearance.colors.colOnSurfaceVariant
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 12

        // Helper functions inline
        function formatKB(kb) {
            return (kb / (1024 * 1024)).toFixed(1) + " GB";
        }
        function formatTemp(temp) {
            return temp + "°C"
        }

        Column {
            anchors.top: parent.top
            spacing: 8

            ResourceHeaderItem {
                icon: "memory"
                label: "RAM"
            }
            Column {
                spacing: 4
                ResourceItem {
                    icon: "clock_loader_60"
                    label: TranslationService.tr("Used:")
                    value: (ResourceUsageService.memoryUsed / (1024 * 1024)).toFixed(1) + " GB"
                }
                ResourceItem {
                    icon: "check_circle"
                    label: TranslationService.tr("Free:")
                    value: (ResourceUsageService.memoryFree / (1024 * 1024)).toFixed(1) + " GB"
                }
                ResourceItem {
                    icon: "empty_dashboard"
                    label: TranslationService.tr("Total:")
                    value: (ResourceUsageService.memoryTotal / (1024 * 1024)).toFixed(1) + " GB"
                }
            }
        }

        Column {
            anchors.top: parent.top
            spacing: 8

            ResourceHeaderItem {
                icon: "thermostat"
                label: TranslationService.tr("Temperature")
            }
            Column {
                spacing: 4
                ResourceItem {
                    icon: "memory"
                    label: "CPU:"
                    value: TranslationService.cpuTemp + "°C"
                }
                ResourceItem {
                    icon: "developer_board"
                    label: "GPU:"
                    value: TranslationService.gpuTemp + "°C"
                }
            }
        }

        Column {
            anchors.top: parent.top
            spacing: 8

            ResourceHeaderItem {
                icon: "planner_review"
                label: "CPU"
            }
            Column {
                spacing: 4
                ResourceItem {
                    icon: "bolt"
                    label: TranslationService.tr("Load:")
                    value: (ResourceUsageService.cpuUsage > 0.8 ? TranslationService.tr("High") : ResourceUsageService.cpuUsage > 0.4 ? TranslationService.tr("Medium") : TranslationService.tr("Low")) + ` (${Math.round(ResourceUsageService.cpuUsage * 100)}%)`
                }
            }
        }
    }
}