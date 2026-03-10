import QtQuick
import QtQuick.Layouts

import qs.Common

Item {
    id: root
    property bool vertical: false
    property real padding: 5
    implicitWidth: vertical ? Appearance.sizes.baseVerticalBarWidth : (gridLayout.implicitWidth + padding * 2)
    implicitHeight: vertical ? (gridLayout.implicitHeight + padding * 2) : Appearance.sizes.baseBarHeight
    default property alias items: gridLayout.children

    Rectangle {
        id: background
        anchors.fill: parent
        anchors.topMargin: root.vertical ? 0 : 4
        anchors.bottomMargin: root.vertical ? 0 : 4
        anchors.leftMargin: root.vertical ? 4 : 0
        anchors.rightMargin: root.vertical ? 4 : 0

        color: Config.options?.bar.borderless ? "transparent" : Appearance.colors.colLayer1
        radius: Appearance.rounding.small
    }

    GridLayout {
        id: gridLayout
        columns: root.vertical ? 1 : -1
        anchors.verticalCenter: root.vertical ? undefined : parent.verticalCenter
        anchors.horizontalCenter: root.vertical ? parent.horizontalCenter : undefined
        anchors.left: root.vertical ? undefined : parent.left
        anchors.right: root.vertical ? undefined : parent.right
        anchors.top: root.vertical ? parent.top : undefined
        anchors.bottom: root.vertical ? parent.bottom : undefined
        anchors.margins: root.padding
        
        columnSpacing: 12
        rowSpacing: 12
    }
}