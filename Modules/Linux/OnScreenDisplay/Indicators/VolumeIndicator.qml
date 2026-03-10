import QtQuick

import qs.Services
import qs.Modules.Linux.OnScreenDisplay

OnScreenDisplayValueIndicator {
    id: osdValues
    value: AudioService.sink?.audio.volume ?? 0
    scaleIcon: true
    icon: AudioService.sink?.audio.muted ? "volume_off" : "volume_up"
    name: TranslationService.tr("Volume")
}