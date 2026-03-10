import QtQuick
import Quickshell
import Quickshell.Bluetooth

import qs.Services
import qs.Common
import qs.Common.Models.QuickToggles
import qs.Common.Functions
import qs.Common.Widgets

AndroidQuickToggleButton {
    id: root
    
    toggleModel: BluetoothToggle {}
}