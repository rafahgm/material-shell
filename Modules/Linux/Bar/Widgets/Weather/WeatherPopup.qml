

import QtQuick
import QtQuick.Layouts

import qs.Services
import qs.Common
import qs.Common.Widgets

StyledPopup {
    id: root

    ColumnLayout {
        id: columnLayout
        anchors.centerIn: parent
        implicitWidth: Math.max(header.implicitWidth, gridLayout.implicitWidth)
        implicitHeight: gridLayout.implicitHeight
        spacing: 5

        // Header
        ColumnLayout {
            id: header
            Layout.alignment: Qt.AlignHCenter
            spacing: 2

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 6

                MaterialSymbol {
                    fill: 0
                    font.weight: Font.Medium
                    text: "location_on"
                    iconSize: Appearance.font.pixelSize.large
                    color: Appearance.colors.colOnSurfaceVariant
                }

                StyledText {
                    text: WeatherService.data.city
                    font {
                        weight: Font.Medium
                        pixelSize: Appearance.font.pixelSize.normal
                    }
                    color: Appearance.colors.colOnSurfaceVariant
                }
            }
            StyledText {
                id: temp
                font.pixelSize: Appearance.font.pixelSize.smaller
                color: Appearance.colors.colOnSurfaceVariant
                text: WeatherService.data.temp + " • " + TranslationService.tr("Feels like %1").arg(WeatherService.data.tempFeelsLike)
            }
        }

        // Metrics grid
        GridLayout {
            id: gridLayout
            columns: 2
            rowSpacing: 5
            columnSpacing: 5
            uniformCellWidths: true

            WeatherCard {
                title: TranslationService.tr("UV Index")
                symbol: "wb_sunny"
                value: WeatherService.data.uv
            }
            WeatherCard {
                title: TranslationService.tr("Wind")
                symbol: "air"
                value: `(${WeatherService.data.windDir}) ${WeatherService.data.wind}`
            }
            WeatherCard {
                title: TranslationService.tr("Precipitation")
                symbol: "rainy_light"
                value: WeatherService.data.precip
            }
            WeatherCard {
                title: TranslationService.tr("Humidity")
                symbol: "humidity_low"
                value: WeatherService.data.humidity
            }
            WeatherCard {
                title: TranslationService.tr("Visibility")
                symbol: "visibility"
                value: WeatherService.data.visib
            }
            WeatherCard {
                title: TranslationService.tr("Pressure")
                symbol: "readiness_score"
                value: WeatherService.data.press
            }
            WeatherCard {
                title: TranslationService.tr("Sunrise")
                symbol: "wb_twilight"
                value: WeatherService.data.sunrise
            }
            WeatherCard {
                title: TranslationService.tr("Sunset")
                symbol: "bedtime"
                value: WeatherService.data.sunset
            }
        }

        // Footer: last refresh
        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: TranslationService.tr("Last refresh: %1").arg(WeatherService.data.lastRefresh)
            font {
                weight: Font.Medium
                pixelSize: Appearance.font.pixelSize.smaller
            }
            color: Appearance.colors.colOnSurfaceVariant
        }
    }
}