pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower

import qs.Common
import qs.Common.Widgets
import qs.Services

Item {
    id: root
    property bool borderless: Config.options.bar.borderless
    implicitWidth: rowLayout.implicitWidth + rowLayout.spacing * 2
    implicitHeight: rowLayout.implicitHeight

    RowLayout {
        id: rowLayout

        spacing: 4
        anchors.centerIn: parent

        Loader {
            active: Config.options.bar.utilButtons.showScreenSnip
            visible: Config.options.bar.utilButtons.showScreenSnip
            sourceComponent: CircleUtilButton {
                Layout.alignment: Qt.AlignVCenter
                onClicked: Quickshell.execDetached(["qs", "-p", Quickshell.shellPath(""), "ipc", "call", "region", "screenshot"])
                MaterialSymbol {
                    horizontalAlignment: Qt.AlignHCenter
                    fill: 1
                    text: "screenshot_region"
                    iconSize: Appearance.font.pixelSize.large
                    color: Appearance.colors.colOnLayer2
                }
            }
        }

        Loader {
            active: Config.options.bar.utilButtons.showScreenRecord
            visible: Config.options.bar.utilButtons.showScreenRecord
            sourceComponent: CircleUtilButton {
                Layout.alignment: Qt.AlignVCenter
                onClicked: Quickshell.execDetached([Directories.recordScriptPath])
                MaterialSymbol {
                    horizontalAlignment: Qt.AlignHCenter
                    fill: 1
                    text: "videocam"
                    iconSize: Appearance.font.pixelSize.large
                    color: Appearance.colors.colOnLayer2
                }
            }
        }

        Loader {
            active: Config.options.bar.utilButtons.showColorPicker
            visible: Config.options.bar.utilButtons.showColorPicker
            sourceComponent: CircleUtilButton {
                Layout.alignment: Qt.AlignVCenter
                onClicked: Quickshell.execDetached(["hyprpicker", "-a"])
                MaterialSymbol {
                    horizontalAlignment: Qt.AlignHCenter
                    fill: 1
                    text: "colorize"
                    iconSize: Appearance.font.pixelSize.large
                    color: Appearance.colors.colOnLayer2
                }
            }
        }

        Loader {
            active: Config.options.bar.utilButtons.showKeyboardToggle
            visible: Config.options.bar.utilButtons.showKeyboardToggle
            sourceComponent: CircleUtilButton {
                Layout.alignment: Qt.AlignVCenter
                onClicked: GlobalStates.oskOpen = !GlobalStates.oskOpen
                MaterialSymbol {
                    horizontalAlignment: Qt.AlignHCenter
                    fill: 0
                    text: "keyboard"
                    iconSize: Appearance.font.pixelSize.large
                    color: Appearance.colors.colOnLayer2
                }
            }
        }

        Loader {
            readonly property bool isInUse: PrivacyService.micActive || (AudioService?.micBeingAccessed ?? false)

            active: (Config.options?.bar?.utilButtons?.showMicToggle ?? false) || isInUse
            visible: active
            sourceComponent: CircleUtilButton {
                id: micButton
                Layout.alignment: Qt.AlignVCenter

                readonly property bool isInUse: PrivacyService.micActive || (AudioService?.micBeingAccessed ?? false)
                readonly property bool isMuted: Pipewire.defaultAudioSource?.audio?.muted ?? false

                onClicked: Quickshell.execDetached(["/usr/bin/wpctl", "set-mute", "@DEFAULT_SOURCE@", "toggle"])
                Item {
                    anchors.fill: parent

                    MaterialSymbol {
                        anchors.centerIn: parent
                        horizontalAlignment: Qt.AlignHCenter
                        fill: micButton.isInUse ? 1 : 0
                        text: micButton.isMuted ? "mic_off" : "mic"
                        iconSize: Appearance.font.pixelSize.large
                        color: micButton.isInUse && !micButton.isMuted ? Appearance.colors.colError : Appearance.colors.colOnLayer2
                    }

                    Rectangle {
                        visible: micButton.isInUse && !micButton.isMuted
                        width: 6
                        height: 6
                        radius: 3
                        color: Appearance.colors.colError
                        x: parent.width - width
                        y: 0

                        SequentialAnimation on opacity {
                            running: micButton.isInUse && !micButton.isMuted
                            loops: Animation.Infinite
                            NumberAnimation {
                                to: 0.1
                                duration: 800
                            }
                            NumberAnimation {
                                to: 1.0
                                duration: 800
                            }
                        }
                    }
                }
            }
        }

        Loader {
            active: Config.options.bar.utilButtons.showDarkModeToggle
            visible: Config.options.bar.utilButtons.showDarkModeToggle
            sourceComponent: CircleUtilButton {
                Layout.alignment: Qt.AlignVCenter
                onClicked: event => {
                    if (Appearance.m3colors.darkmode) {
                    } else {
                    }
                }
                MaterialSymbol {
                    horizontalAlignment: Qt.AlignHCenter
                    fill: 0
                    text: Appearance.m3colors.darkmode ? "light_mode" : "dark_mode"
                    iconSize: Appearance.font.pixelSize.large
                    color: Appearance.colors.colOnLayer2
                }
            }
        }

        Loader {
            active: Config.options.bar.utilButtons.showPerformanceProfileToggle
            visible: Config.options.bar.utilButtons.showPerformanceProfileToggle
            sourceComponent: CircleUtilButton {
                Layout.alignment: Qt.AlignVCenter
                onClicked: event => {
                    if (PowerProfiles.hasPerformanceProfile) {
                        switch (PowerProfiles.profile) {
                        case PowerProfile.PowerSaver:
                            PowerProfiles.profile = PowerProfile.Balanced;
                            break;
                        case PowerProfile.Balanced:
                            PowerProfiles.profile = PowerProfile.Performance;
                            break;
                        case PowerProfile.Performance:
                            PowerProfiles.profile = PowerProfile.PowerSaver;
                            break;
                        }
                    } else {
                        PowerProfiles.profile = PowerProfiles.profile == PowerProfile.Balanced ? PowerProfile.PowerSaver : PowerProfile.Balanced;
                    }
                }
                MaterialSymbol {
                    horizontalAlignment: Qt.AlignHCenter
                    fill: 0
                    text: switch (PowerProfiles.profile) {
                    case PowerProfile.PowerSaver:
                        return "energy_savings_leaf";
                    case PowerProfile.Balanced:
                        return "airwave";
                    case PowerProfile.Performance:
                        return "local_fire_department";
                    }
                    iconSize: Appearance.font.pixelSize.large
                    color: Appearance.colors.colOnLayer2
                }
            }
        }
    }
}
