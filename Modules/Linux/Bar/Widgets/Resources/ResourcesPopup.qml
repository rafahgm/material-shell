import QtQuick
import QtQuick.Layouts

import qs.Common
import qs.Common.Widgets
import qs.Services

StyledPopup {
    id: root

    // Helper function to format KB to GB
    function formatKB(kb) {
        return (kb / (1024 * 1024)).toFixed(1) + " GB";
    }

    Row {
        anchors.centerIn: parent
        spacing: 12

        Column {
            anchors.top: parent.top
            spacing: 8

            StyledPopupHeaderRow {
                icon: "memory"
                label: "RAM"
            }
            Column {
                spacing: 4
                StyledPopupValueRow {
                    icon: "clock_loader_60"
                    label: TranslationService.tr("Used:")
                    value: root.formatKB(DgopService.memoryUsed)
                }
                StyledPopupValueRow {
                    icon: "check_circle"
                    label: TranslationService.tr("Free:")
                    value: root.formatKB(DgopService.memoryFree)
                }
                StyledPopupValueRow {
                    icon: "empty_dashboard"
                    label: TranslationService.tr("Total:")
                    value: root.formatKB(DgopService.memoryTotal)
                }
            }
        }

        Column {
            visible: DgopService.swapTotal > 0
            anchors.top: parent.top
            spacing: 8

            StyledPopupHeaderRow {
                icon: "swap_horiz"
                label: "Swap"
            }
            Column {
                spacing: 4
                StyledPopupValueRow {
                    icon: "clock_loader_60"
                    label: TranslationService.tr("Used:")
                    value: root.formatKB(DgopService.swapUsed)
                }
                StyledPopupValueRow {
                    icon: "check_circle"
                    label: TranslationService.tr("Free:")
                    value: root.formatKB(DgopService.swapFree)
                }
                StyledPopupValueRow {
                    icon: "empty_dashboard"
                    label: TranslationService.tr("Total:")
                    value: root.formatKB(DgopService.swapTotal)
                }
            }
        }

        Column {
            anchors.top: parent.top
            spacing: 8

            StyledPopupHeaderRow {
                icon: "planner_review"
                label: "CPU"
            }
            Column {
                spacing: 4
                StyledPopupValueRow {
                    icon: "percent"
                    label: TranslationService.tr("Load:")
                    value: `${Math.round(DgopService.cpuUsage)}%`
                }
                StyledPopupValueRow {
                    icon: "device_thermostat"
                    label: TranslationService.tr("Temp:")
                    value: `${Math.round(DgopService.cpuTemperature)} °C`
                }
                StyledPopupValueRow {
                    icon: "speed"
                    label: TranslationService.tr("Freq:")
                    value: `${Math.round(DgopService.cpuFrequency)} MHz`
                }
            }
        }
    }
}