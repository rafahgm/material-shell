pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

import qs.Services

StyledListView { // Scrollable window
    id: root
    property bool popup: false

    spacing: 3

    model: ScriptModel {
        values: root.popup ? NotificationsService.popupAppNameList : NotificationsService.appNameList
    }
    delegate: NotificationGroup {
        required property int index
        required property var modelData
        popup: root.popup
        width: ListView.view.width // https://doc.qt.io/qt-6/qml-qtquick-listview.html
        notificationGroup: popup ? 
            NotificationsService.popupGroupsByAppName[modelData] :
            NotificationsService.groupsByAppName[modelData]
    }
}