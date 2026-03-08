import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import qs.Common
import qs.Common.Functions

RippleButton {
    id: root
    required property string materialSymbol
    required property bool current
    property bool showLabel: true
    horizontalPadding: 10

    implicitHeight: 32
    readonly property real _iconOnlyImplicitWidth: icon.implicitWidth + horizontalPadding * 2
    implicitWidth: root.showLabel ? (implicitContentWidth + horizontalPadding * 2) : root._iconOnlyImplicitWidth
    buttonRadius: height / 2

    colBackground: "transparent"
    colBackgroundHover: current ? "transparent" 
        : ColorUtils.transparentize(Appearance.colors.colOnSurface, 0.95)
    colRipple: current ? "transparent" 
        : ColorUtils.transparentize(Appearance.colors.colOnSurface, 0.95)

    contentItem: Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: root.showLabel ? 6 : 0

        MaterialSymbol {
            id: icon
            anchors.verticalCenter: parent.verticalCenter
            iconSize: 22
            text: root.materialSymbol
            color: Appearance.m3colors.m3onSurface
        }
        Loader {
            id: labelLoader
            active: root.showLabel
            visible: root.showLabel
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: StyledText {
                text: root.text
                color: Appearance.m3colors.m3onSurface
            }
        }
    }
}