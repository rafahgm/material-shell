pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Qt5Compat.GraphicalEffects as GE
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

import qs.Common
import qs.Common.Widgets
import qs.Common.Widgets.CavaProcess
import qs.Common.Functions
import qs.Common.Models
import qs.Services

/**
 * YTMusic Now Playing Card - Compact player with visualizer and adaptive colors.
 */
Item {
    id: root
    implicitHeight: hasTrack ? card.implicitHeight + Appearance.sizes.elevationMargin : 0
    visible: hasTrack

    readonly property bool hasTrack: YTMusic.currentVideoId !== ""
    readonly property bool isPlaying: YTMusic.isPlaying

    // Cava visualizer - using shared CavaProcess component
    CavaProcess {
        id: cavaProcess
        active: root.visible && root.isPlaying && GlobalStates.sidebarLeftOpen && Appearance.effectsEnabled
    }

    property list<real> visualizerPoints: cavaProcess.points

    // Adaptive colors from thumbnail
    ColorQuantizer {
        id: colorQuantizer
        source: YTMusic.currentThumbnail
        depth: 0
        rescaleSize: 1
    }

    property color artColor: ColorUtils.mix(
        colorQuantizer?.colors[0] ?? Appearance.colors.colPrimary,
        Appearance.colors.colPrimaryContainer, 0.7
    )
    property QtObject blendedColors: AdaptedMaterialScheme { color: root.artColor }

    // Style tokens
    readonly property color colText: Appearance.inirEverywhere ? Appearance.inir.colText
        : (blendedColors?.colOnLayer0 ?? Appearance.colors.colOnLayer0)
    readonly property color colTextSecondary: Appearance.inirEverywhere ? Appearance.inir.colTextSecondary
        : (blendedColors?.colSubtext ?? Appearance.colors.colSubtext)
    readonly property color colPrimary: Appearance.inirEverywhere ? Appearance.inir.colPrimary
        : (blendedColors?.colPrimary ?? Appearance.colors.colPrimary)
    readonly property color colBg: Appearance.angelEverywhere ? Appearance.angel.colGlassCard
        : Appearance.inirEverywhere ? Appearance.inir.colLayer1
        : Appearance.auroraEverywhere ? ColorUtils.transparentize(blendedColors?.colLayer0 ?? Appearance.colors.colLayer0, 0.7)
        : (blendedColors?.colLayer0 ?? Appearance.colors.colLayer0)
    readonly property color colLayer2: Appearance.inirEverywhere ? Appearance.inir.colLayer2
        : (blendedColors?.colLayer1 ?? Appearance.colors.colLayer1)
    readonly property real radius: Appearance.angelEverywhere ? Appearance.angel.roundingNormal
        : Appearance.inirEverywhere ? Appearance.inir.roundingNormal : Appearance.rounding.normal
    readonly property real radiusSmall: Appearance.angelEverywhere ? Appearance.angel.roundingSmall
        : Appearance.inirEverywhere ? Appearance.inir.roundingSmall : Appearance.rounding.small

    StyledRectangularShadow { target: card; visible: Appearance.angelEverywhere || (!Appearance.inirEverywhere && !Appearance.auroraEverywhere) }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: parent.width - Appearance.sizes.elevationMargin
        implicitHeight: 140
        radius: root.radius
        color: root.colBg
        border.width: (Appearance.angelEverywhere || Appearance.inirEverywhere) ? 1 : 0
        border.color: Appearance.angelEverywhere ? Appearance.angel.colBorder
            : Appearance.inirEverywhere ? Appearance.inir.colBorder : "transparent"
        clip: true

        layer.enabled: true
        layer.effect: GE.OpacityMask {
            maskSource: Rectangle { width: card.width; height: card.height; radius: card.radius }
        }

        // Background art blur
        Image {
            anchors.fill: parent
            source: YTMusic.currentThumbnail
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            opacity: Appearance.inirEverywhere ? 0.15 : (Appearance.auroraEverywhere ? 0.25 : 0.5)
            visible: YTMusic.currentThumbnail !== ""
            layer.enabled: Appearance.effectsEnabled
            layer.effect: MultiEffect { blurEnabled: true; blur: 0.2; blurMax: 16; saturation: 0.2 }
        }

        // Gradient overlay for Material
        Rectangle {
            anchors.fill: parent
            visible: !Appearance.inirEverywhere && !Appearance.auroraEverywhere
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.4; color: ColorUtils.transparentize(root.colBg, 0.3) }
                GradientStop { position: 1.0; color: ColorUtils.transparentize(root.colBg, 0.15) }
            }
        }

        // Visualizer - only render when effects enabled
        WaveVisualizer {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 25
            visible: Appearance.effectsEnabled
            live: root.isPlaying
            points: root.visualizerPoints
            maxVisualizerValue: 1000
            smoothing: 2
            color: ColorUtils.transparentize(root.colPrimary, 0.6)
        }

        // Fallback gradient when effects disabled
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 25
            visible: !Appearance.effectsEnabled && root.isPlaying
            gradient: Gradient {
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 1.0; color: ColorUtils.transparentize(root.colPrimary, 0.7) }
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 12

            // Cover art
            Rectangle {
                Layout.preferredWidth: 100
                Layout.preferredHeight: 100
                radius: root.radiusSmall
                color: root.colLayer2
                clip: true

                layer.enabled: true
                layer.effect: GE.OpacityMask {
                    maskSource: Rectangle { width: 100; height: 100; radius: root.radiusSmall }
                }

                Image {
                    anchors.fill: parent
                    source: YTMusic.currentThumbnail
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }

                MaterialSymbol {
                    anchors.centerIn: parent
                    visible: !YTMusic.currentThumbnail
                    text: "music_note"
                    iconSize: 32
                    color: root.colTextSecondary
                }

                // Loading overlay
                Rectangle {
                    anchors.fill: parent
                    color: ColorUtils.transparentize("black", 0.5)
                    visible: YTMusic.loading

                    MaterialLoadingIndicator { anchors.centerIn: parent; implicitSize: 24; loading: true }
                }

                // Now Playing indicator
                Rectangle {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.margins: 6
                    width: 24
                    height: 16
                    radius: 4
                    color: ColorUtils.transparentize("black", 0.4)
                    visible: root.isPlaying && !YTMusic.loading

                    Row {
                        anchors.centerIn: parent
                        spacing: 2
                        Repeater {
                            model: 3
                            Rectangle {
                                required property int index
                                width: 3
                                height: 4 + Math.random() * 6
                                radius: 1
                                color: root.colPrimary
                                
                                SequentialAnimation on height {
                                    running: root.isPlaying
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 4 + index * 2; duration: 200 + index * 100; easing.type: Easing.InOutQuad }
                                    NumberAnimation { to: 10 - index; duration: 300 + index * 50; easing.type: Easing.InOutQuad }
                                }
                            }
                        }
                    }
                }
            }

            // Info & controls
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 0
                spacing: 4

                // Title
                StyledText {
                    Layout.fillWidth: true
                    text: YTMusic.currentTitle || "—"
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Medium
                    color: root.colText
                    elide: Text.ElideRight
                    animateChange: true
                    animationDistanceX: 6
                }

                // Artist
                StyledText {
                    Layout.fillWidth: true
                    text: YTMusic.currentArtist || ""
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: root.colTextSecondary
                    elide: Text.ElideRight
                    visible: text !== ""
                }

                Item { Layout.fillHeight: true }

                // Progress
                StyledSlider {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 14
                    configuration: StyledSlider.Configuration.Wavy
                    wavy: root.isPlaying
                    animateWave: root.isPlaying
                    highlightColor: root.colPrimary
                    trackColor: root.colLayer2
                    handleColor: root.colPrimary
                    value: YTMusic.currentDuration > 0 ? YTMusic.currentPosition / YTMusic.currentDuration : 0
                    onMoved: YTMusic.seek(value * YTMusic.currentDuration)
                    scrollable: true
                }

                // Time + controls
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    StyledText {
                        text: StringUtils.friendlyTimeForSeconds(YTMusic.currentPosition)
                        font.pixelSize: Appearance.font.pixelSize.smallest
                        font.family: Appearance.font.family.numbers
                        color: root.colText
                        Layout.preferredWidth: 28
                    }

                    Item { Layout.fillWidth: true; Layout.minimumWidth: 0 }

                    // Shuffle
                    RippleButton {
                        implicitWidth: 24; implicitHeight: 24
                        buttonRadius: 12
                        colBackground: YTMusic.shuffleMode ? root.colPrimary : "transparent"
                        colBackgroundHover: YTMusic.shuffleMode ? root.colPrimary : root.colLayer2
                        onClicked: YTMusic.toggleShuffle()
                        contentItem: MaterialSymbol { anchors.centerIn: parent; text: "shuffle"; iconSize: 14; color: YTMusic.shuffleMode ? Appearance.colors.colOnPrimary : root.colTextSecondary }
                        StyledToolTip { text: YTMusic.shuffleMode ? TranslationService.tr("Shuffle On") : TranslationService.tr("Shuffle Off") }
                    }

                    // Previous
                    RippleButton {
                        implicitWidth: 28; implicitHeight: 28
                        buttonRadius: 14
                        colBackground: "transparent"
                        colBackgroundHover: root.colLayer2
                        onClicked: YTMusic.playPrevious()
                        contentItem: MaterialSymbol { anchors.centerIn: parent; text: "skip_previous"; iconSize: 18; fill: 1; color: root.colText }
                    }

                    // Play/Pause
                    RippleButton {
                        implicitWidth: 36; implicitHeight: 36
                        buttonRadius: root.isPlaying ? root.radiusSmall : 18
                        colBackground: "transparent"
                        colBackgroundHover: root.colLayer2
                        onClicked: YTMusic.togglePlaying()
                        Behavior on buttonRadius { enabled: Appearance.animationsEnabled; NumberAnimation { duration: 150 } }
                        contentItem: MaterialSymbol { 
                            anchors.centerIn: parent
                            text: root.isPlaying ? "pause" : "play_arrow"
                            iconSize: 22; fill: 1
                            color: root.colPrimary
                        }
                    }

                    // Next
                    RippleButton {
                        implicitWidth: 28; implicitHeight: 28
                        buttonRadius: 14
                        colBackground: "transparent"
                        colBackgroundHover: root.colLayer2
                        onClicked: YTMusic.playNext()
                        contentItem: MaterialSymbol { anchors.centerIn: parent; text: "skip_next"; iconSize: 18; fill: 1; color: root.colText }
                    }

                    // Repeat
                    RippleButton {
                        implicitWidth: 24; implicitHeight: 24
                        buttonRadius: 12
                        colBackground: YTMusic.repeatMode > 0 ? root.colPrimary : "transparent"
                        colBackgroundHover: YTMusic.repeatMode > 0 ? root.colPrimary : root.colLayer2
                        onClicked: YTMusic.cycleRepeatMode()
                        contentItem: MaterialSymbol { 
                            anchors.centerIn: parent
                            text: YTMusic.repeatMode === 1 ? "repeat_one" : "repeat"
                            iconSize: 14
                            color: YTMusic.repeatMode > 0 ? Appearance.colors.colOnPrimary : root.colTextSecondary
                        }
                        StyledToolTip { text: YTMusic.repeatMode === 0 ? TranslationService.tr("Repeat Off") : YTMusic.repeatMode === 1 ? TranslationService.tr("Repeat One") : TranslationService.tr("Repeat All") }
                    }

                    // Volume
                    RippleButton {
                        id: volumeBtn
                        implicitWidth: 24; implicitHeight: 24
                        buttonRadius: 12
                        colBackground: "transparent"
                        colBackgroundHover: root.colLayer2
                        property real previousVolume: 1.0
                        onClicked: {
                            if (YTMusic.volume > 0) {
                                previousVolume = YTMusic.volume
                                YTMusic.setVolume(0)
                            } else {
                                YTMusic.setVolume(previousVolume)
                            }
                        }
                        contentItem: Item {
                            MaterialSymbol { 
                                anchors.centerIn: parent
                                text: YTMusic.volume <= 0 ? "volume_off" : YTMusic.volume < 0.5 ? "volume_down" : "volume_up"
                                iconSize: 14
                                color: YTMusic.volume <= 0 ? root.colTextSecondary : root.colText
                            }
                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.NoButton
                                onWheel: event => {
                                    const delta = event.angleDelta.y > 0 ? 0.05 : -0.05
                                    YTMusic.setVolume(Math.max(0, Math.min(1, YTMusic.volume + delta)))
                                }
                            }
                        }
                        StyledToolTip { text: TranslationService.tr("Volume") + ": " + Math.round(YTMusic.volume * 100) + "%" }
                    }

                    // Like
                    RippleButton {
                        readonly property bool isLiked: YTMusic.likedSongs.some(s => s.videoId === YTMusic.currentVideoId)
                        implicitWidth: 24; implicitHeight: 24
                        buttonRadius: 12
                        colBackground: "transparent"
                        colBackgroundHover: root.colLayer2
                        onClicked: isLiked ? YTMusic.unlikeSong(YTMusic.currentVideoId) : YTMusic.likeSong()
                        contentItem: MaterialSymbol { 
                            anchors.centerIn: parent
                            text: parent.isLiked ? "favorite" : "favorite_border"
                            iconSize: 14
                            fill: parent.isLiked ? 1 : 0
                            color: parent.isLiked ? Appearance.colors.colError : root.colTextSecondary
                        }
                        StyledToolTip { text: parent.isLiked ? TranslationService.tr("Remove from Liked") : TranslationService.tr("Add to Liked") }
                    }

                    Item { Layout.fillWidth: true; Layout.minimumWidth: 0 }

                    StyledText {
                        text: StringUtils.friendlyTimeForSeconds(YTMusic.currentDuration)
                        font.pixelSize: Appearance.font.pixelSize.smallest
                        font.family: Appearance.font.family.numbers
                        color: root.colText
                        Layout.preferredWidth: 28
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }
    }
}