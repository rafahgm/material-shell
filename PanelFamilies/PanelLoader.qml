import QtQuick
import Quickshell

import qs.Common

LazyLoader {
    property bool extraCondition: true
    active: Config.ready && extraCondition
}