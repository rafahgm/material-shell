import QtQuick
import Quickshell.Bluetooth

import qs.Services
import qs.Common
import qs.Common.Functions
import qs.Common.Widgets

QuickToggleModel {
    name: TranslationService.tr("Bluetooth")
    statusText: BluetoothService.firstActiveDevice?.name ?? TranslationService.tr("Not connected")
    tooltipText: TranslationService.tr("%1 | Right-click to configure").arg(
        (BluetoothService.firstActiveDevice?.name ?? TranslationService.tr("Bluetooth"))
        + (BluetoothService.activeDeviceCount > 1 ? ` +${BluetoothService.activeDeviceCount - 1}` : "")
    )
    icon: BluetoothService.connected ? "bluetooth_connected" : BluetoothService.enabled ? "bluetooth" : "bluetooth_disabled"

    available: BluetoothService.available
    toggled: BluetoothService.enabled
    mainAction: () => {
        Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter?.enabled
    }
    hasMenu: true
}