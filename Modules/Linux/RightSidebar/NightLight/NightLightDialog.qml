import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

import qs.Services
import qs.Common
import qs.Common.Widgets
import qs.Common.Functions

WindowDialog {
    id: root
    property var screen: root.QsWindow.window?.screen
    property var brightnessMonitor: BrightnessService.getMonitorForScreen(screen)
    backgroundHeight: 600

    WindowDialogTitle {
        text: TranslationService.tr("Eye protection")
    }
    
    WindowDialogSectionHeader {
        text: TranslationService.tr("Night Light")
    }

    WindowDialogSeparator {
        Layout.topMargin: -22
        Layout.leftMargin: 0
        Layout.rightMargin: 0
    }

    Column {
        id: nightLightColumn
        Layout.topMargin: -16
        Layout.fillWidth: true

        ConfigSwitch {
            anchors {
                left: parent.left
                right: parent.right
            }
            iconSize: Appearance.font.pixelSize.larger
            buttonIcon: "lightbulb"
            text: TranslationService.tr("Enable now")
            checked: HyprsunsetService.active
            onCheckedChanged: {
                HyprsunsetService.toggle(checked)
            }
        }

        ConfigSwitch {
            anchors {
                left: parent.left
                right: parent.right
            }
            iconSize: Appearance.font.pixelSize.larger
            buttonIcon: "night_sight_auto"
            text: TranslationService.tr("Automatic")
            checked: Config.options.light.night.automatic
            onCheckedChanged: {
                Config.options.light.night.automatic = checked;
            }
        }

        WindowDialogSlider {
            anchors {
                left: parent.left
                right: parent.right
                leftMargin: 4
                rightMargin: 4
            }
            text: TranslationService.tr("Intensity")
            from: 6500
            to: 1200
            stopIndicatorValues: [5000, to]
            value: Config.options.light.night.colorTemperature
            onMoved: Config.options.light.night.colorTemperature = value
            tooltipContent: `${Math.round(value)}K`
        }
    }

    WindowDialogSectionHeader {
        text: TranslationService.tr("Anti-flashbang (experimental)")
    }

    WindowDialogSeparator {
        Layout.topMargin: -22
        Layout.leftMargin: 0
        Layout.rightMargin: 0
    }

    Column {
        id: antiFlashbangColumn
        Layout.topMargin: -16
        Layout.fillWidth: true

        ConfigSwitch {
            anchors {
                left: parent.left
                right: parent.right
            }
            iconSize: Appearance.font.pixelSize.larger
            buttonIcon: "flash_off"
            text: TranslationService.tr("Enable")
            checked: Config.options.light.antiFlashbang.enable
            onCheckedChanged: {
                Config.options.light.antiFlashbang.enable = checked;
            }
            StyledToolTip {
                text: TranslationService.tr("Example use case: eroge on one workspace, dark Discord window on another")
            }
        }
    }

    WindowDialogSectionHeader {
        text: TranslationService.tr("Brightness")
    }

    WindowDialogSeparator {
        Layout.topMargin: -22
        Layout.leftMargin: 0
        Layout.rightMargin: 0
    }

    Column {
        id: brightnessColumn
        Layout.topMargin: -16
        Layout.fillWidth: true
        Layout.fillHeight: true

        WindowDialogSlider {
            anchors {
                left: parent.left
                right: parent.right
                leftMargin: 4
                rightMargin: 4
            }
            // text: Translation.tr("Brightness")
            value: root.brightnessMonitor.brightness
            onMoved: root.brightnessMonitor.setBrightness(value)
        }
    }
    
    WindowDialogButtonRow {
        Layout.fillWidth: true

        Item {
            Layout.fillWidth: true
        }

        DialogButton {
            buttonText: TranslationService.tr("Done")
            onClicked: root.dismiss()
        }
    }
}