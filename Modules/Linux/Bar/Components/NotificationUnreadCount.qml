import QtQuick

import qs.Services
import qs.Modules.Common
import qs.Modules.Common.Widgets

MaterialSymbol {
    id: root
    readonly property bool showUnreadCount: Config.options.bar.indicators.notifications.showUnreadCount
    text: NotificationsService.silent ? "notifications_paused" : "notifications"
    iconSize: Appearance.font.pixelSize.larger
    color: rightSidebarButton.colText

    Rectangle {
        id: notifPing
        visible: !NotificationsService.silent && NotificationsService.unread > 0
        anchors {
            right: parent.right
            top: parent.top
            rightMargin: root.showUnreadCount ? 0 : 1
            topMargin: root.showUnreadCount ? 0 : 3
        }
        radius: Appearance.inirEverywhere ? Appearance.inir.roundingSmall : Appearance.rounding.full
        color: Appearance.inirEverywhere ? Appearance.inir.colPrimary : Appearance.colors.colOnLayer0
        z: 1

        implicitHeight: root.showUnreadCount ? Math.max(notificationCounterText.implicitWidth, notificationCounterText.implicitHeight) : 8
        implicitWidth: implicitHeight

        StyledText {
            id: notificationCounterText
            visible: root.showUnreadCount
            anchors.centerIn: parent
            font.pixelSize: Appearance.font.pixelSize.smallest
            color: Appearance.inirEverywhere ? Appearance.inir.colOnPrimary : Appearance.colors.colLayer0
            text: NotificationsService.unread
        }
    }
}