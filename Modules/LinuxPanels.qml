import QtQuick
import Quickshell

import qs.Modules.Common

import qs.Modules.Linux
import qs.Modules.Linux.Bar
import qs.Modules.Linux.Background
import qs.Modules.Linux.WallpaperSelector

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
        identifier: "linuxBackground"
        component: Background {}
    }

    PanelLoader {
        identifier: "linuxNotificationPopup"
        component: NotificationPopup {}
    }

    PanelLoader {
        identifier: "linuxWallpaperSelector"
        component: WallpaperSelector {}
    }
}
