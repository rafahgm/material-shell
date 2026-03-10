pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Wayland
import Quickshell.Hyprland

import qs.Services
import qs.Common
import qs.Common.Widgets
import qs.Common.Functions

ColumnLayout {
    id: root
    readonly property MprisPlayer activePlayer: MprisService.activePlayer
    readonly property var realPlayers: MprisService.players
    readonly property var meaningfulPlayers: filterDuplicatePlayers(realPlayers)
    property list<real> visualizerPoints: []

    function filterDuplicatePlayers(players) {
        let filtered = [];
        let used = new Set();

        for (let i = 0; i < players.length; ++i) {
            if (used.has(i))
                continue;
            let p1 = players[i];
            let group = [i];

            // Find duplicates by trackTitle prefix
            for (let j = i + 1; j < players.length; ++j) {
                let p2 = players[j];
                if (p1.trackTitle && p2.trackTitle && (p1.trackTitle.includes(p2.trackTitle) || p2.trackTitle.includes(p1.trackTitle)) || (p1.position - p2.position <= 2 && p1.length - p2.length <= 2)) {
                    group.push(j);
                }
            }

            // Pick the one with non-empty trackArtUrl, or fallback to the first
            let chosenIdx = group.find(idx => players[idx].trackArtUrl && players[idx].trackArtUrl.length > 0);
            if (chosenIdx === undefined)
                chosenIdx = group[0];

            filtered.push(players[chosenIdx]);
            group.forEach(idx => used.add(idx));
        }
        return filtered;
    }

    Process {
        id: cavaProc
        running: root.activePlayer?.isPlaying ?? false
        onRunningChanged: {
            if (!cavaProc.running) {
                root.visualizerPoints = [];
            }
        }
        command: ["cava", "-p", FileUtils.trimFileProtocol(Qt.resolvedUrl('./raw_output_config.txt'))]
        stdout: SplitParser {
            onRead: data => {
                // Parse `;`-separated values into the visualizerPoints array
                let points = data.split(";").map(p => parseFloat(p.trim())).filter(p => !isNaN(p));
                root.visualizerPoints = points;
            }
        }
    }

    spacing: -Appearance.sizes.elevationMargin // Shadow overlap okay

    Repeater {
        model: ScriptModel {
            values: root.meaningfulPlayers
        }
        delegate: PlayerControl {
            required property MprisPlayer modelData
            player: modelData
            Layout.fillWidth: true
            Layout.fillHeight: true
        
            visualizerPoints: root.visualizerPoints
            radius: Appearance.rounding.small
        }
    }

    Item {
        // No player placeholder
        Layout.fillWidth: true
        Layout.alignment: {
            if (panelWindow.anchors.left)
                return Qt.AlignLeft;
            if (panelWindow.anchors.right)
                return Qt.AlignRight;
            return Qt.AlignHCenter;
        }
        visible: root.meaningfulPlayers.length === 0
        implicitWidth: placeholderBackground.implicitWidth + Appearance.sizes.elevationMargin
        implicitHeight: placeholderBackground.implicitHeight + Appearance.sizes.elevationMargin

        StyledRectangularShadow {
            target: placeholderBackground
        }

        Rectangle {
            id: placeholderBackground
            anchors.centerIn: parent
            color: Appearance.colors.colLayer0
            radius: Appearance.rounding.small
            property real padding: 20
            implicitWidth: placeholderLayout.implicitWidth + padding * 2
            implicitHeight: placeholderLayout.implicitHeight + padding * 2

            ColumnLayout {
                id: placeholderLayout
                anchors.centerIn: parent

                StyledText {
                    text: TranslationService.tr("No active player")
                    font.pixelSize: Appearance.font.pixelSize.large
                }
                StyledText {
                    color: Appearance.colors.colSubtext
                    text: TranslationService.tr("Make sure your player has MPRIS support\nor try turning off duplicate player filtering")
                    font.pixelSize: Appearance.font.pixelSize.small
                }
            }
        }
    }
}
