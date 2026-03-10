import QtQuick
import QtQuick.Layouts
import Quickshell

import qs.Services
import qs.Common
import qs.Common.Widgets

WindowDialog {
    id: root
    backgroundHeight: 600

    WindowDialogTitle {
        text: TranslationService.tr("Connect to Wi-Fi")
    }
    WindowDialogSeparator {
        visible: !NetworkService.wifiScanning
    }
    StyledIndeterminateProgressBar {
        visible: NetworkService.wifiScanning
        Layout.fillWidth: true
        Layout.topMargin: -8
        Layout.bottomMargin: -8
        Layout.leftMargin: -Appearance.rounding.large
        Layout.rightMargin: -Appearance.rounding.large
    }
    ListView {
        Layout.fillHeight: true
        Layout.fillWidth: true
        Layout.topMargin: -15
        Layout.bottomMargin: -16
        Layout.leftMargin: -Appearance.rounding.large
        Layout.rightMargin: -Appearance.rounding.large

        clip: true
        spacing: 0

        model: ScriptModel {
            values: NetworkService.friendlyWifiNetworks
        }
        delegate: WifiItem {
            required property WifiAccessPoint modelData
            wifiNetwork: modelData
            width: ListView.view.width
        }
    }
    WindowDialogSeparator {}
    WindowDialogButtonRow {
        DialogButton {
            buttonText: TranslationService.tr("Details")
            onClicked: {
                Quickshell.execDetached(["bash", "-c", `${NetworkService.ethernet ? Config.options.apps.networkEthernet : Config.options.apps.network}`]);
                GlobalStates.sidebarRightOpen = false;
            }
        }

        Item {
            Layout.fillWidth: true
        }

        DialogButton {
            buttonText: TranslationService.tr("Done")
            onClicked: root.dismiss()
        }
    }
}