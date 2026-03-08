pragma Singleton
import Quickshell
import QtQuick

import qs.Services
import qs.Modules.Common

Singleton {
    id: root

    Timer {
        id: _hibernateMonitorsOffTimer
        interval: 450
        repeat: false
        onTriggered: {
            Quickshell.execDetached(["/usr/bin/niri", "msg", "action", "power-off-monitors"])
            
        }
    }

    Timer {
        id: _hibernateTimer
        interval: 900
        repeat: false
        onTriggered: {
            Quickshell.execDetached(["/usr/bin/systemctl", "hibernate", "-i"])
            Quickshell.execDetached(["/usr/bin/loginctl", "hibernate"])
        }
    }

    Timer {
        id: _suspendTimer
        interval: 600
        repeat: false
        onTriggered: {
            Quickshell.execDetached(["/usr/bin/systemctl", "suspend", "-i"])
        }
    }

    function lock() {
        Quickshell.execDetached(["/usr/bin/qs", "-c", "ii", "ipc", "call", "lock", "activate"]);
    }

    function suspend() {
        if (Config.options?.idle?.lockBeforeSleep !== false) {
            lock()
            _suspendTimer.restart()
        } else {
            Quickshell.execDetached(["/usr/bin/systemctl", "suspend", "-i"])
        }
    }

    function logout() {
        NiriService.quit();
    }

    function launchTaskManager() {
        const cmd = Config.options?.apps?.taskManager ?? "missioncenter"
        Quickshell.execDetached(["/usr/bin/bash", "-lc", cmd])
    }

    function hibernate() {
        lock();
        _hibernateMonitorsOffTimer.restart()
        _hibernateTimer.restart()
    }

    function poweroff() {
        closeAllWindows();
        Quickshell.execDetached(["/usr/bin/systemctl", "poweroff", "-i"])
        Quickshell.execDetached(["/usr/bin/loginctl", "poweroff"])
    }

    function reboot() {
        closeAllWindows();
        Quickshell.execDetached(["/usr/bin/systemctl", "reboot", "-i"])
        Quickshell.execDetached(["/usr/bin/loginctl", "reboot"])
    }

    function rebootToFirmware() {
        closeAllWindows();
        Quickshell.execDetached(["/usr/bin/systemctl", "reboot", "--firmware-setup"])
        Quickshell.execDetached(["/usr/bin/loginctl", "reboot", "--firmware-setup"])
    }
}