import QtQuick
import Quickshell

import qs.Common
import qs.Common.Functions

StyledText {
    text: "Dialog Title"
    color: Appearance.colors.colOnSurface
    wrapMode: Text.Wrap
    font {
        family: Appearance.font.family.title
        pixelSize: Appearance.font.pixelSize.title
        variableAxes: Appearance.font.variableAxes.title
    }
}