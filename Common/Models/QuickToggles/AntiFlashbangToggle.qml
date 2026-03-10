import QtQuick

import qs.Services
import qs.Common
import qs.Common.Functions
import qs.Common.Widgets

QuickToggleModel {
    name: TranslationService.tr("Anti-flashbang")
    tooltipText: TranslationService.tr("Anti-flashbang")
    icon: "flash_off"
    toggled: Config.options.light.antiFlashbang.enable

    mainAction: () => {
        Config.options.light.antiFlashbang.enable = !Config.options.light.antiFlashbang.enable;
    }
    hasMenu: true
}