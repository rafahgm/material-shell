import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

import qs.Common
import qs.Common.Widgets
import qs.Services

Item {
    id: root
    required property PwNode node
    PwObjectTracker {
        objects: [root.node]
    }

    implicitHeight: rowLayout.implicitHeight

    RowLayout {
        id: rowLayout
        anchors.fill: parent
        spacing: 6

        Image {
            property real size: 36
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            visible: source != ""
            sourceSize.width: size
            sourceSize.height: size
            source: {
                let icon;
                icon = AppSearchService.guessIcon(root.node?.properties["application.icon-name"] ?? "");
                if (AppSearchService.iconExists(icon))
                    return Quickshell.iconPath(icon, "image-missing");
                icon = AppSearchService.guessIcon(root.node?.properties["node.name"] ?? "");
                return Quickshell.iconPath(icon, "image-missing");
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: -4

            StyledText {
                Layout.fillWidth: true
                font.pixelSize: Appearance.font.pixelSize.small
                color: Appearance.colors.colSubtext
                elide: Text.ElideRight
                text: {
                    // application.name -> description -> name
                    const app = Audio.appNodeDisplayName(root.node);
                    const media = root.node.properties["media.name"];
                    return media != undefined ? `${app} • ${media}` : app;
                }
            }

            StyledSlider {
                id: slider
                value: root.node?.audio.volume ?? 0
                onMoved: root.node.audio.volume = value
                configuration: StyledSlider.Configuration.S
            }
        }
    }
}