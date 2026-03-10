import QtQuick
import Quickshell

import qs.Services
import qs.Common
import qs.Common.Functions
import qs.Common.Widgets

QuickToggleModel {
    property bool auto: Config.options.light.night.automatic

    name: TranslationService.tr("Night Light")
    statusText: (auto ? TranslationService.tr("Auto, ") : "") + (toggled ? TranslationService.tr("Active") : TranslationService.tr("Inactive"))

    toggled: HyprsunsetService.active
    icon: auto ? "night_sight_auto" : "bedtime"
    
    mainAction: () => {
        HyprsunsetService.toggle()
    }
    hasMenu: true

    Component.onCompleted: {
        HyprsunsetService.fetchState()
    }
    
    tooltipText: TranslationService.tr("Night Light | Right-click to configure")
}