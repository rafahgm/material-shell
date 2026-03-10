import QtQuick

import qs.Services
import qs.Common
import qs.Common.Functions
import qs.Common.Widgets

QuickToggleModel {
    name: TranslationService.tr("Audio output")
    statusText: toggled ? `${Math.round((AudioService.sink?.audio.volume ?? 0) * 100)}%` : TranslationService.tr("Muted")
    tooltipText: TranslationService.tr("Audio output | Right-click for volume mixer & device selector")
    toggled: !AudioService.sink?.audio?.muted
    icon: AudioService.sink?.audio?.muted ? "volume_off" : "volume_up"
    mainAction: () => {
        AudioService.toggleMute()
    }
    hasMenu: true
}