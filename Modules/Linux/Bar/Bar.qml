pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import qs.Common
import qs.Common.Widgets

Scope {
    id: root

    property bool showBarBackground: Config.options.bar.showBackground

    // Para cada monitor
    Variants {
        model: {
            const screens = Quickshell.screens;
            const list = Config.options.bar.screenList;
            
            if (!list || list.length === 0)
                return screens;

            return screens.filter(s => list.includes(s.name));
        }
        LazyLoader {
            id: barLoader
            active: GlobalStates.barOpen && !GlobalStates.screenLocked
            required property ShellScreen modelData
            component: PanelWindow {
                // Bar Window
                id: barRoot

                property bool superShow: false
                property bool mustShow: hoverRegion.containsMouse || superShow

                screen: barLoader.modelData
                exclusionMode: ExclusionMode.Ignore
                exclusiveZone: (Config?.options.bar.autoHide.enable && (!mustShow || !Config?.options.bar.autoHide.pushWindows)) ? 0 : Appearance.sizes.baseBarHeight + (Config.options.bar.cornerStyle === 1 ? Appearance.sizes.gapsOut : 0)
                WlrLayershell.namespace: "shell:bar"
                implicitHeight: Appearance.sizes.barHeight + Appearance.rounding.screenRounding
                mask: Region {
                    item: hoverMaskRegion
                }
                anchors.top: !Config.options.bar.bottom
                anchors.bottom: Config.options.bar.bottom
                anchors.left: true
                anchors.right: true
                margins.right: ((Config.options?.interactions?.deadPixelWorkaround?.enable ?? false) && barRoot.anchors.right) * -1
                margins.bottom: ((Config.options?.interactions?.deadPixelWorkaround?.enable ?? false) && barRoot.anchors.bottom) * -1
                color: "transparent"

                Timer {
                    id: showBarTimer
                    interval: (Config.options.bar.autoHide.showWhenPressingSuper.delay ?? 100)
                    repeat: false
                    onTriggered: {
                        barRoot.superShow = true;
                    }
                }

                Connections {
                    target: GlobalStates

                    function onSuperDownChanged() {
                        if (!Config.options.bar.autoHide.showWhenPressingSuper.enable)
                            return;
                        if (GlobalStates.superDown)
                            showBarTimer.restart();
                        else {
                            showBarTimer.stop();
                            barRoot.superShow = false;
                        }
                    }
                }

                MouseArea {
                    id: hoverRegion

                    hoverEnabled: true
                    anchors.fill: parent
                    anchors.rightMargin: ((Config.options?.interactions?.deadPixelWorkaround?.enable ?? false) && barRoot.anchors.right) * -1
                    anchors.bottomMargin: ((Config.options?.interactions?.deadPixelWorkaround?.enable ?? false) && barRoot.anchors.bottom) * -1

                    Item {
                        id: hoverMaskRegion
                        anchors.fill: barContent
                        anchors.topMargin: -Config.options.bar.autoHide.hoverRegionWidth
                        anchors.bottomMargin: -Config.options.bar.autoHide.hoverRegionWidth
                    }

                    BarContent {
                        id: barContent

                        implicitHeight: Appearance.sizes.barHeight
                        anchors.right: parent.right
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: undefined
                        anchors.topMargin: (Config?.options.bar.autoHide.enable && !mustShow) ? -Appearance.sizes.barHeight : 0
                        anchors.bottomMargin: (Config.options.interactions.deadPixelWorkaround.enable && barRoot.anchors.bottom) * -1
                        anchors.rightMargin: (Config.options.interactions.deadPixelWorkaround.enable && barRoot.anchors.right) * -1

                        Behavior on anchors.topMargin {
                            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                        }

                        Behavior on anchors.bottomMargin {
                            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                        }

                        states: State {
                            name: "bottom"
                            when: Config.options.bar.bottom
                            AnchorChanges {
                                target: barContent
                                anchors.right: parent.right
                                anchors.left: parent.left
                                anchors.top: undefined
                                anchors.bottom: parent.bottom
                            }
                            PropertyChanges {
                                target: barContent
                                anchors.topMargin: 0
                                anchors.bottomMargin: (Config?.options.bar.autoHide.enable && !mustShow) ? -Appearance.sizes.barHeight : 0
                            }
                        }
                    }

                    // RoundDecorators
                    Loader {
                        id: roundDecorators
                        active: showBarBackground && Config.options.bar.cornerStyle === Enums.CornerStyle.Hug

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: barContent.bottom
                        anchors.bottom: undefined
                        height: Appearance.rounding.screenRounding

                        states: State {
                            name: "bottom"
                            when: Config.options.bar.bottom
                            AnchorChanges {
                                target: roundDecorators
                                anchors {
                                    right: parent.right
                                    left: parent.left
                                    top: undefined
                                    bottom: barContent.top
                                }
                            }
                        }

                        sourceComponent: Item {
                            implicitHeight: Appearance.rounding.screenRounding
                            RoundCorner {
                                id: leftCorner
                                anchors {
                                    top: parent.top
                                    bottom: parent.bottom
                                    left: parent.left
                                }

                                implicitSize: Appearance.rounding.screenRounding
                                color: showBarBackground ? Appearance.colors.colLayer0 : "transparent"

                                corner: RoundCorner.CornerEnum.TopLeft
                                states: State {
                                    name: "bottom"
                                    when: Config.options.bar.bottom
                                    PropertyChanges {
                                        leftCorner.corner: RoundCorner.CornerEnum.BottomLeft
                                    }
                                }
                            }
                            RoundCorner {
                                id: rightCorner
                                anchors {
                                    right: parent.right
                                    top: !Config.options.bar.bottom ? parent.top : undefined
                                    bottom: Config.options.bar.bottom ? parent.bottom : undefined
                                }
                                implicitSize: Appearance.rounding.screenRounding
                                color: showBarBackground ? Appearance.colors.colLayer0 : "transparent"

                                corner: RoundCorner.CornerEnum.TopRight
                                states: State {
                                    name: "bottom"
                                    when: Config.options.bar.bottom
                                    PropertyChanges {
                                        rightCorner.corner: RoundCorner.CornerEnum.BottomRight
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
