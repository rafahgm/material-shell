import QtQuick
import Quickshell

import qs.Services
import qs.Common
import qs.Common.Functions
import qs.Common.Widgets

QuickToggleModel {
    name: TranslationService.tr("Keep awake")

    toggled: IdleService.inhibit
    icon: "coffee"
    mainAction: () => {
        IdleService.toggleInhibit()
    }
    tooltipText: TranslationService.tr("Keep system awake")
}