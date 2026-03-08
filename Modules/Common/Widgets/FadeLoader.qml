import QtQuick

import qs.Modules.Common
import qs.Modules.Common.Widgets

Loader {
    id: root
    property bool shown: true
    opacity: shown ? 1 : 0
    visible: opacity > 0
    active: opacity > 0

    Behavior on opacity {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }
}