import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

import qs.Services
import qs.Modules.Common
import qs.Modules.Common.Widgets

Item {
    id: root
    readonly property HyprlandMonitor monitor: null
    readonly property Toplevel activeWindow: ToplevelManager.activeToplevel

    property string activeWindowAddress: ""
    property bool focusingThisMonitor: true
    property var biggestWindow: null

    // Ventana activa según Niri (focus global)
    property var niriFocusedWindow: {
        if (!NiriService.windows)
            return null;
        const wins = NiriService.windows;

        for (var i = 0; i < wins.length; ++i) {
            const w = wins[i];
            if (w && w.is_focused)
                return w;
        }
        return null;
    }

    function shortenText(str, maxLen) {
        if (!str)
            return "";
        const s = str.toString();
        if (s.length <= maxLen)
            return s;
        return s.slice(0, maxLen - 3) + "...";
    }

    property string displayAppName: {
        const w = niriFocusedWindow;
        if (w) {
            const base = w.app_id || w.appId || TranslationService.tr("Desktop");
            return shortenText(base, 40);
        }
        return TranslationService.tr("Desktop");
    }

    property string displayTitle: {
        const w = niriFocusedWindow;
        if (w && w.title) {
            return shortenText(w.title, 80);
        }
        const wsNum = NiriService.getCurrentWorkspaceNumber();
        return shortenText(`${TranslationService.tr("Workspace")} ${wsNum}`, 80);
    }

    implicitWidth: colLayout.implicitWidth

    ColumnLayout {
        id: colLayout

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: -1

        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: Appearance.inirEverywhere ? Appearance.inir.colTextSecondary : Appearance.colors.colSubtext
            elide: Text.ElideRight
            text: root.displayAppName
        }

        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.inirEverywhere ? Appearance.inir.colText : Appearance.colors.colOnLayer0
            elide: Text.ElideRight
            text: root.displayTitle
        }
    }
}
