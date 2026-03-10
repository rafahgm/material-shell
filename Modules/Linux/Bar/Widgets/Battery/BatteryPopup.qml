import QtQuick
import QtQuick.Layouts

import qs.Common
import qs.Common.Widgets
import qs.Services

StyledPopup {
    id: root
    
    ColumnLayout {
        id: columnLayout
        anchors.centerIn: parent
        spacing: 4

        // Header
        StyledPopupHeaderRow {
            icon: "battery_android_full"
            label: TranslationService.tr("Battery")
        }

        StyledPopupValueRow {
            visible: {
                let timeValue = BatteryService.isCharging ? BatteryService.timeToFull : BatteryService.timeToEmpty;
                let power = BatteryService.energyRate;
                return !(BatteryService.chargeState == 4 || timeValue <= 0 || power <= 0.01);
            }
            icon: "schedule"
            label: BatteryService.isCharging ? TranslationService.tr("Time to full:") : TranslationService.tr("Time to empty:")
            value: {
                function formatTime(seconds) {
                    var h = Math.floor(seconds / 3600);
                    var m = Math.floor((seconds % 3600) / 60);
                    if (h > 0)
                        return `${h}h, ${m}m`;
                    else
                        return `${m}m`;
                }
                if (BatteryService.isCharging)
                    return formatTime(BatteryService.timeToFull);
                else
                    return formatTime(BatteryService.timeToEmpty);
            }
        }

        StyledPopupValueRow {
            visible:  !(BatteryService.chargeState != 4 && BatteryService.energyRate == 0)
            icon: "bolt"
            label: {
                if (BatteryService.chargeState == 4) {
                    return TranslationService.tr("Fully charged");
                } else if (BatteryService.chargeState == 1) {
                    return TranslationService.tr("Charging:");
                } else {
                    return TranslationService.tr("Discharging:");
                }
            }
            value: {
                if (BatteryService.chargeState == 4) {
                    return "";
                } else {
                    return `${BatteryService.energyRate.toFixed(2)}W`;
                }
            }
        }

        StyledPopupValueRow {
            icon: "heart_check"
            label: TranslationService.tr("Health:")
            value: `${(BatteryService.health).toFixed(1)}%`
        }
    }
}