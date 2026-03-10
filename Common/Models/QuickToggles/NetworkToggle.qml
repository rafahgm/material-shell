import QtQuick

import qs.Services
import qs.Common
import qs.Common.Functions
import qs.Common.Widgets

QuickToggleModel {
    name: TranslationService.tr("Internet")
    statusText: NetworkService.networkName
    tooltipText: TranslationService.tr("%1 | Right-click to configure").arg(NetworkService.networkName)
    icon: NetworkService.materialSymbol

    toggled: NetworkService.wifiStatus !== "disabled"
    mainAction: () => NetworkService.toggleWifi()
    hasMenu: true
}