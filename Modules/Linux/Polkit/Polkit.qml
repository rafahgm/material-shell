import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.Services
import qs.Common
import qs.Common.Widgets
import qs.Common.Functions

FullscreenPolkitWindow {
    id: root
    contentComponent: Component {
        PolkitContent {}
    }
}