pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts


import qs.Common
import qs.Common.Widgets
import qs.Services

MouseArea {
    id: root
    property bool hovered: false
    implicitWidth: rowLayout.implicitWidth + 10 * 2
    implicitHeight: Appearance.sizes.barHeight

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    hoverEnabled: !Config.options.bar.tooltips.clickToShow

    onPressed: {
        if (mouse.button === Qt.RightButton) {
            WeatherService.getData();
            Quickshell.execDetached(["notify-send", 
                TranslationService.tr("Weather"), 
                TranslationService.tr("Refreshing (manually triggered)")
                , "-a", "Shell"
            ])
            mouse.accepted = false
        }
    }

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent

        MaterialSymbol {
            fill: 0
            text: Icons.getWeatherIcon(WeatherService.data.wCode) ?? "cloud"
            iconSize: Appearance.font.pixelSize.large
            color: Appearance.colors.colOnLayer1
            Layout.alignment: Qt.AlignVCenter
        }

        StyledText {
            visible: true
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colOnLayer1
            text: WeatherService.data?.temp ?? "--°"
            Layout.alignment: Qt.AlignVCenter
        }
    }

    WeatherPopup {
        id: weatherPopup
        hoverTarget: root
    }
}