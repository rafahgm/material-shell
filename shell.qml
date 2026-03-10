//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_LOGGING_RULES=quickshell.dbus.properties=false
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000
//@ pragma Env QT_SCALE_FACTOR=1

import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Io

import qs.Common
import qs.PanelFamilies
import qs.Services

ShellRoot {
    id: root

    ReloadPopup {}

    Component.onCompleted: {
        ConflictKiller.load()
    }

    property list<string> families: ["linux", "windows"]
    
    function cyclePanelFamily() {
        const currentIndex = families.indexOf(Config.options.panelFamily)
        const nextIndex = (currentIndex + 1) % families.length
        Config.options.panelFamily = families[nextIndex]
    }

    component PanelFamilyLoader: LazyLoader {
        required property string identifier
        property bool extraCondition: true
        active: Config.ready && Config.options.panelFamily === identifier  && extraCondition
    }

    PanelFamilyLoader {
        identifier: "linux"
        component: LinuxFamily {}
    }

    PanelFamilyLoader {
        identifier: "windows"
        component: WindowFamily {}
    }

    // Shortcuts
    IpcHandler {
        target: "panelFamily"

        function cycle(): void {
            root.cyclePanelFamily()
        }
    }
}