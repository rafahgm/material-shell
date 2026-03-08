import QtQuick
import Quickshell.Io
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

import qs.Services
import qs.Common
import qs.Common.Widgets

Scope {
    id: root
    property int sidebarWidth: Appearance.sizes.sidebarWidth

    PanelWindow {
        id: sidebarRoot
        visible: GlobalStates.sidebarLeftOpen

        function hide() {
            GlobalStates.sidebarLeftOpen = false
        }

        exclusiveZone: 0
        implicitWidth: screen?.width ?? 1920
        WlrLayershell.namespace: "quickshell:sidebarLeft"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        color: "transparent"

        anchors {
            top: true
            left: true
            bottom: true
            right: true
        }

        MouseArea {
            id: backdropClickArea
            anchors.fill: parent
            onClicked: mouse => {
                const localPos = mapToItem(sidebarContentLoader, mouse.x, mouse.y)
                if (localPos.x < 0 || localPos.x > sidebarContentLoader.width
                        || localPos.y < 0 || localPos.y > sidebarContentLoader.height) {
                    sidebarRoot.hide()
                }
            }
        }

        Loader {
            id: sidebarContentLoader
            active: GlobalStates.sidebarLeftOpen || (Config?.options?.sidebar?.keepLeftSidebarLoaded ?? true)
            anchors {
                top: parent.top
                left: parent.left
                bottom: parent.bottom
                margins: Appearance.sizes.gapsOut
                rightMargin: Appearance.sizes.elevationMargin
            }
            width: sidebarWidth - Appearance.sizes.gapsOut - Appearance.sizes.elevationMargin
            height: parent.height - Appearance.sizes.gapsOut * 2

            // Simple slide animation using transform (GPU-accelerated)
            property bool animating: false
            transform: Translate {
                x: GlobalStates.sidebarLeftOpen ? 0 : -30
                Behavior on x {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                        onRunningChanged: sidebarContentLoader.animating = running
                    }
                }
            }
            opacity: GlobalStates.sidebarLeftOpen ? 1 : 0
            Behavior on opacity {
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }

            focus: GlobalStates.sidebarLeftOpen
            Keys.onPressed: (event) => {
                if (event.key === Qt.Key_Escape) {
                    sidebarRoot.hide();
                }
            }

            sourceComponent: LeftSidebarContent {
                screenWidth: sidebarRoot.screen?.width ?? 1920
                screenHeight: sidebarRoot.screen?.height ?? 1080
                panelScreen: sidebarRoot.screen ?? null
            }
        }
    }

    IpcHandler {
        target: "sidebarLeft"

        function toggle(): void {
            GlobalStates.sidebarLeftOpen = !GlobalStates.sidebarLeftOpen;
        }

        function close(): void {
            GlobalStates.sidebarLeftOpen = false;
        }

        function open(): void {
            GlobalStates.sidebarLeftOpen = true;
        }
    }
}