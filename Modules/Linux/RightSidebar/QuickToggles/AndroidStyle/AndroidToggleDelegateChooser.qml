pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth

import qs.Services
import qs.Common
import qs.Common.Widgets

DelegateChooser {
    id: root
    required property real baseCellWidth
    required property real baseCellHeight
    required property real spacing
    required property int startingIndex
    signal openAudioOutputDialog
    signal openAudioInputDialog
    signal openBluetoothDialog
    signal openNightLightDialog
    signal openWifiDialog

    role: "type"

    DelegateChoice {
        roleValue: "antiFlashbang"
        AndroidAntiFlashbangToggle {
            required property int index
            required property var modelData
            buttonIndex: root.startingIndex + index
            buttonData: modelData
            expandedSize: modelData.size > 1
            baseCellWidth: root.baseCellWidth
            baseCellHeight: root.baseCellHeight
            cellSpacing: root.spacing
            cellSize: modelData.size
            onOpenMenu: {
                root.openNightLightDialog();
            }
        }
    }
    
    DelegateChoice {
        roleValue: "audio"
        AndroidAudioToggle {
            required property int index
            required property var modelData
            buttonIndex: root.startingIndex + index
            buttonData: modelData
            expandedSize: modelData.size > 1
            baseCellWidth: root.baseCellWidth
            baseCellHeight: root.baseCellHeight
            cellSpacing: root.spacing
            cellSize: modelData.size
            onOpenMenu: {
                root.openAudioOutputDialog();
            }
        }
    }

    DelegateChoice {
        roleValue: "bluetooth"
        AndroidBluetoothToggle {
            required property int index
            required property var modelData
            buttonIndex: root.startingIndex + index
            buttonData: modelData
            expandedSize: modelData.size > 1
            baseCellWidth: root.baseCellWidth
            baseCellHeight: root.baseCellHeight
            cellSpacing: root.spacing
            cellSize: modelData.size
            onOpenMenu: {
                root.openBluetoothDialog();
            }
        }
    }

    DelegateChoice {
        roleValue: "idleInhibitor"
        AndroidIdleInhibitorToggle {
            required property int index
            required property var modelData
            buttonIndex: root.startingIndex + index
            buttonData: modelData
            expandedSize: modelData.size > 1
            baseCellWidth: root.baseCellWidth
            baseCellHeight: root.baseCellHeight
            cellSpacing: root.spacing
            cellSize: modelData.size
        }
    }

    DelegateChoice {
        roleValue: "mic"
        AndroidMicToggle {
            required property int index
            required property var modelData
            buttonIndex: root.startingIndex + index
            buttonData: modelData
            expandedSize: modelData.size > 1
            baseCellWidth: root.baseCellWidth
            baseCellHeight: root.baseCellHeight
            cellSpacing: root.spacing
            cellSize: modelData.size
            onOpenMenu: {
                root.openAudioInputDialog();
            }
        }
    }

    DelegateChoice {
        roleValue: "network"
        AndroidNetworkToggle {
            required property int index
            required property var modelData
            buttonIndex: root.startingIndex + index
            buttonData: modelData
            expandedSize: modelData.size > 1
            baseCellWidth: root.baseCellWidth
            baseCellHeight: root.baseCellHeight
            cellSpacing: root.spacing
            cellSize: modelData.size
            onOpenMenu: {
                root.openWifiDialog();
            }
        }
    }

    DelegateChoice {
        roleValue: "nightLight"
        AndroidNightLightToggle {
            required property int index
            required property var modelData
            buttonIndex: root.startingIndex + index
            buttonData: modelData
            expandedSize: modelData.size > 1
            baseCellWidth: root.baseCellWidth
            baseCellHeight: root.baseCellHeight
            cellSpacing: root.spacing
            cellSize: modelData.size
            onOpenMenu: {
                root.openNightLightDialog();
            }
        }
    }
}
