import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import QtQuick.Effects
import Qt5Compat.GraphicalEffects as GE

import qs.Services
import qs.Common
import qs.Common.Models
import qs.Common.Widgets
import qs.Common.Functions

import qs.Modules.Linux.LeftSidebar.YTMusic

Item {
    id: root
    property int sidebarWidth: Appearance.sizes.sidebarWidth
    property int sidebarPadding: 10
    property int screenWidth: 1920
    property int screenHeight: 1080
    property var panelScreen: null

    // Delay content loading until after animation completes
    property bool contentReady: false

    Connections {
        target: GlobalStates
        function onSidebarLeftOpenChanged() {
            if (GlobalStates.sidebarLeftOpen) {
                root.contentReady = false
                contentDelayTimer.restart()
            }
        }
    }

    Timer {
        id: contentDelayTimer
        interval: 200
        onTriggered: root.contentReady = true
    }

    property bool aiChatEnabled: (Config.options?.policies?.ai ?? 0) !== 0
    property bool translatorEnabled: (Config.options?.sidebar?.translator?.enable ?? false)
    property bool animeEnabled: (Config.options?.policies?.weeb ?? 0) !== 0
    property bool animeCloset: (Config.options?.policies?.weeb ?? 0) === 2
    property bool animeScheduleEnabled: Config.options?.sidebar?.animeSchedule?.enable ?? false
    property bool redditEnabled: Config.options?.sidebar?.reddit?.enable ?? false
    property bool wallhavenEnabled: Config.options?.sidebar?.wallhaven?.enable !== false
    property bool widgetsEnabled: Config.options?.sidebar?.widgets?.enable ?? true
    property bool toolsEnabled: Config.options?.sidebar?.tools?.enable ?? false
    property bool ytMusicEnabled: Config.options?.sidebar?.ytMusic?.enable ?? false

    // Tab button list - simple static order
    property var tabButtonList: {
        const result = []
        if (root.widgetsEnabled) result.push({ icon: "widgets", name: TranslationService.tr("Widgets") })
        if (root.aiChatEnabled) result.push({ icon: "neurology", name: TranslationService.tr("Intelligence") })
        if (root.translatorEnabled) result.push({ icon: "translate", name: TranslationService.tr("Translator") })
        if (root.animeEnabled && !root.animeCloset) result.push({ icon: "bookmark_heart", name: TranslationService.tr("Anime") })
        if (root.animeScheduleEnabled) result.push({ icon: "calendar_month", name: TranslationService.tr("Schedule") })
        if (root.redditEnabled) result.push({ icon: "forum", name: TranslationService.tr("Reddit") })
        if (root.wallhavenEnabled) result.push({ icon: "collections", name: TranslationService.tr("Wallhaven") })
        if (root.ytMusicEnabled) result.push({ icon: "library_music", name: TranslationService.tr("YT Music") })
        if (root.toolsEnabled) result.push({ icon: "build", name: TranslationService.tr("Tools") })
        return result
    }

    function focusActiveItem() {
        swipeView.currentItem?.forceActiveFocus()
    }

    implicitHeight: sidebarLeftBackground.implicitHeight
    implicitWidth: sidebarLeftBackground.implicitWidth

    StyledRectangularShadow {
        target: sidebarLeftBackground
    }
    
    Rectangle {
        id: sidebarLeftBackground

        anchors.fill: parent
        implicitHeight: parent.height - Appearance.sizes.hyprlandGapsOut * 2
        implicitWidth: sidebarWidth - Appearance.sizes.hyprlandGapsOut * 2


        color: Appearance.colors.colLayer0
        border.width: 1
        border.color: Appearance.colors.colLayer0Border
        radius: (Appearance.rounding.screenRounding - Appearance.sizes.gapsOut + 1)
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: sidebarPadding
            anchors.topMargin: sidebarPadding
            spacing: sidebarPadding

            Toolbar {
                Layout.alignment: Qt.AlignHCenter
                enableShadow: false
                ToolbarTabBar {
                    id: tabBar
                    Layout.alignment: Qt.AlignHCenter
                    maxWidth: Math.max(0, root.width - (root.sidebarPadding * 2) - 16)
                    tabButtonList: root.tabButtonList
                    // Don't bind to swipeView - let tabBar be the source of truth
                    onCurrentIndexChanged: swipeView.currentIndex = currentIndex
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Appearance.rounding.normal
                color: Appearance.colors.colLayer1

                SwipeView {
                    id: swipeView
                    anchors.fill: parent
                    spacing: 10
                    // Sync back to tabBar when swiping
                    onCurrentIndexChanged: {
                        tabBar.setCurrentIndex(currentIndex)
                        const currentTab = root.tabButtonList[currentIndex]
                        if (currentTab?.icon === "neurology") {
                            Ai.ensureInitialized()
                        }
                    }
                    interactive: !(currentItem?.item?.editMode ?? false) && !(currentItem?.item?.dragPending ?? false)

                    clip: true
                    layer.enabled: root.contentReady
                    layer.effect: GE.OpacityMask {
                        maskSource: Rectangle {
                            width: swipeView.width
                            height: swipeView.height
                            radius: Appearance.rounding.small
                        }
                    }

                    Repeater {
                        model: root.contentReady ? root.tabButtonList : []
                        delegate: Loader {
                            required property var modelData
                            required property int index
                            active: SwipeView.isCurrentItem || SwipeView.isNextItem || SwipeView.isPreviousItem
                            sourceComponent: {
                                switch (modelData.icon) {
                                    case "widgets": return widgetsComp
                                    case "neurology": return aiChatComp
                                    case "translate": return translatorComp
                                    case "bookmark_heart": return animeComp
                                    case "calendar_month": return animeScheduleComp
                                    case "forum": return redditComp
                                    case "collections": return wallhavenComp
                                    case "library_music": return ytMusicComp
                                    case "build": return toolsComp
                                    default: return null
                                }
                            }
                        }
                    }
                }
            }
        }

        /* Component { id: widgetsComp; WidgetsView {} }
        Component { id: aiChatComp; AiChat {} }
        Component { id: translatorComp; Translator {} }
        Component { id: animeComp; Anime {} }
        Component { id: animeScheduleComp; AnimeScheduleView {} }
        Component { id: redditComp; RedditView {} }
        Component { id: wallhavenComp; WallhavenView {} }
        */Component { id: ytMusicComp; YTMusic {} }
        /*Component { id: toolsComp; ToolsView {} } */

        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Escape) {
                GlobalStates.sidebarLeftOpen = false
            }
            if (event.modifiers === Qt.ControlModifier) {
                if (event.key === Qt.Key_PageDown) {
                    swipeView.incrementCurrentIndex()
                    event.accepted = true
                }
                else if (event.key === Qt.Key_PageUp) {
                    swipeView.decrementCurrentIndex()
                    event.accepted = true
                }
            }
        }
    }
}