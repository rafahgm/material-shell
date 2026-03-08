import QtQuick
import Quickshell

import qs.Modules.Common

import qs.Modules.Linux
import qs.Modules.Linux.Bar

Item {
    component PanelLoader: LazyLoader {
        required property string identifier
        property bool extraCondition: true
        active: Config.ready && (Config.options?.enabledPanels ?? []).includes(identifier) && extraCondition
    }

    PanelLoader {
        identifier: "linuxBar"
        extraCondition: !(Config.options?.bar?.vertical ?? false)
        component: Bar {}
    }
    
    PanelLoader {
        identifier: "linuxNotificationPopup"
        component: NotificationPopup {}
    }
}
