pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import qs.Modules.Common
import qs.Modules.Common.Widgets
import qs.Services

StyledListView { // Scrollable window
    id: root
    property bool popup: false

    spacing: 3

    // Sidebar: full transitions with pop-in; Popup: no built-in transitions
    popin: !popup
    animateAppearance: !popup

    // Custom removeDisplaced for popup mode: smooth gap-filling when a group is dismissed.
    // Uses elementMoveFast (200ms) for snappy feel without Wayland stair-stepping.
    removeDisplaced: Transition {
        enabled: root.popup
        NumberAnimation {
            property: "y"
            duration: Appearance.animation.elementMoveFast.duration
            easing.type: Appearance.animation.elementMoveFast.type
            easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
        }
        NumberAnimation {
            property: "opacity"
            to: 1
            duration: Appearance.animation.elementMoveFast.duration
            easing.type: Appearance.animation.elementMoveFast.type
            easing.bezierCurve: Appearance.animation.elementMoveFast.bezierCurve
        }
    }

    model: ScriptModel {
        values: root.popup ? NotificationsService.popupAppNameList : NotificationsService.appNameList
    }
    delegate: NotificationGroup {
        required property int index
        required property var modelData
        popup: root.popup
        anchors.left: parent?.left
        anchors.right: parent?.right
        notificationGroup: popup ?
            NotificationsService.popupGroupsByAppName[modelData] :
            NotificationsService.groupsByAppName[modelData]
    }
}