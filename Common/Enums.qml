pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

import qs.Common

Singleton {
    id: root

    enum CornerStyle {
        Hug,
        Float,
        PlainRectangle
    }

    enum AiPolicy {
        Disabled,
        Enabled,
        Local
    }

    enum WeebPolicy {
        Disabled,
        Enabled,
        Closet
    }
}