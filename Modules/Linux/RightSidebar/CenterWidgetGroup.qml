import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.Common
import qs.Common.Widgets
import qs.Services
import qs.Modules.Linux.RightSidebar.Notifications
import qs.Modules.Linux.RightSidebar.MediaControls

Rectangle {
    id: root

    radius: Appearance.rounding.normal
    color: Appearance.colors.colLayer1

    NotificationList {
        anchors.fill: parent
    }
}
