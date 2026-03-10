import QtQuick
import Quickshell

import qs.Services
import qs.Common
import qs.Common.Functions
import qs.Common.Widgets

QuickToggleModel {
    name: TranslationService.tr("Audio input")
    statusText: toggled ? TranslationService.tr("Enabled") : TranslationService.tr("Muted")
    toggled: !AudioService.source?.audio?.muted
    icon: AudioService.source?.audio?.muted ? "mic_off" : "mic"
    mainAction: () => {
        AudioService.toggleMicMute()
    }
    hasMenu: true

    tooltipText: TranslationService.tr("Audio input | Right-click for volume mixer & device selector")
}