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
import qs.Common.Functions
import qs.Common.Models
import qs.Services

Item {
    id: root

    readonly property bool isAvailable: YTMusic.available
    readonly property bool hasResults: YTMusic.searchResults.length > 0
    readonly property bool hasQueue: YTMusic.queue.length > 0
    readonly property bool isPlaying: YTMusic.isPlaying
    readonly property bool hasTrack: YTMusic.currentVideoId !== ""

    property string currentView: "search"

    function openAddToPlaylist(item) { 
        addToPlaylistPopup.targetItem = item
        addToPlaylistPopup.open() 
    }

    readonly property color colText: Appearance.inirEverywhere ? Appearance.inir.colText : Appearance.colors.colOnLayer0
    readonly property color colTextSecondary: Appearance.inirEverywhere ? Appearance.inir.colTextSecondary : Appearance.colors.colSubtext
    readonly property color colPrimary: Appearance.inirEverywhere ? Appearance.inir.colPrimary : Appearance.colors.colPrimary
    readonly property color colSurface: Appearance.angelEverywhere ? Appearance.angel.colGlassCard : Appearance.inirEverywhere ? Appearance.inir.colLayer1 : Appearance.auroraEverywhere ? "transparent" : Appearance.colors.colLayer1
    readonly property color colSurfaceHover: Appearance.angelEverywhere ? Appearance.angel.colGlassCardHover : Appearance.inirEverywhere ? Appearance.inir.colLayer1Hover : Appearance.auroraEverywhere ? Appearance.aurora.colSubSurface : Appearance.colors.colLayer1Hover
    readonly property color colLayer2: Appearance.angelEverywhere ? Appearance.angel.colGlassElevated : Appearance.inirEverywhere ? Appearance.inir.colLayer2 : Appearance.auroraEverywhere ? Appearance.aurora.colSubSurface : Appearance.colors.colLayer2
    readonly property color colLayer2Hover: Appearance.angelEverywhere ? Appearance.angel.colGlassCardHover : Appearance.inirEverywhere ? Appearance.inir.colLayer2Hover : Appearance.auroraEverywhere ? Appearance.aurora.colSubSurfaceHover : Appearance.colors.colLayer2Hover
    readonly property color colBorder: Appearance.angelEverywhere ? Appearance.angel.colCardBorder : Appearance.inirEverywhere ? Appearance.inir.colBorder : "transparent"
    readonly property int borderWidth: Appearance.angelEverywhere ? Appearance.angel.cardBorderWidth : Appearance.inirEverywhere ? 1 : 0
    readonly property real radiusSmall: Appearance.angelEverywhere ? Appearance.angel.roundingSmall : Appearance.inirEverywhere ? Appearance.inir.roundingSmall : Appearance.rounding.small
    readonly property real radiusNormal: Appearance.angelEverywhere ? Appearance.angel.roundingNormal : Appearance.inirEverywhere ? Appearance.inir.roundingNormal : Appearance.rounding.normal

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        Loader {
            Layout.fillWidth: true
            Layout.fillHeight: true
            active: !root.isAvailable
            visible: active
            sourceComponent: ColumnLayout {
                spacing: 16
                Item { Layout.fillHeight: true }
                MaterialSymbol { 
                    Layout.alignment: Qt.AlignHCenter
                    text: "music_off"
                    iconSize: 56
                    color: root.colTextSecondary 
                }
                StyledText { 
                    Layout.alignment: Qt.AlignHCenter
                    text: TranslationService.tr("yt-dlp not found")
                    font.pixelSize: Appearance.font.pixelSize.larger
                    font.weight: Font.Medium
                    color: root.colText 
                }
                StyledText { 
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillWidth: true
                    Layout.margins: 20
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: TranslationService.tr("Install yt-dlp and mpv to use YT Music")
                    font.pixelSize: Appearance.font.pixelSize.small
                    color: root.colTextSecondary 
                }
                RippleButton {
                    Layout.alignment: Qt.AlignHCenter
                    implicitWidth: 160
                    implicitHeight: 42
                    buttonRadius: root.radiusNormal
                    colBackground: root.colPrimary
                    onClicked: Qt.openUrlExternally("https://github.com/yt-dlp/yt-dlp#installation")
                    contentItem: StyledText { 
                        anchors.centerIn: parent
                        text: TranslationService.tr("Install Guide")
                        color: Appearance.colors.colOnPrimary
                        font.weight: Font.Medium 
                    }
                }
                Item { Layout.fillHeight: true }
            }
        }

        Loader {
            Layout.fillWidth: true
            Layout.fillHeight: true
            active: root.isAvailable
            visible: active
            
            sourceComponent: ColumnLayout {
                spacing: 8

                // Tab navigation - adaptive, subtle colors
                ButtonGroup {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 2

                    GroupButton {
                        toggled: root.currentView === "search"
                        bounce: true
                        colBackground: root.colSurface
                        colBackgroundHover: root.colSurfaceHover
                        colBackgroundToggled: root.colLayer2
                        colBackgroundToggledHover: root.colLayer2Hover
                        onClicked: root.currentView = "search"
                        contentItem: RowLayout {
                            spacing: 4
                            MaterialSymbol {
                                text: "search"
                                iconSize: 18
                                color: root.currentView === "search" ? root.colPrimary : root.colTextSecondary
                            }
                            StyledText {
                                text: TranslationService.tr("Search")
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: root.currentView === "search" ? root.colPrimary : root.colText
                            }
                        }
                    }

                    GroupButton {
                        toggled: root.currentView === "playlists"
                        bounce: true
                        colBackground: root.colSurface
                        colBackgroundHover: root.colSurfaceHover
                        colBackgroundToggled: root.colLayer2
                        colBackgroundToggledHover: root.colLayer2Hover
                        onClicked: root.currentView = "playlists"
                        contentItem: RowLayout {
                            spacing: 4
                            MaterialSymbol {
                                text: "library_music"
                                iconSize: 18
                                color: root.currentView === "playlists" ? root.colPrimary : root.colTextSecondary
                            }
                            StyledText {
                                text: TranslationService.tr("Library")
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: root.currentView === "playlists" ? root.colPrimary : root.colText
                            }
                        }
                    }

                    GroupButton {
                        toggled: root.currentView === "queue"
                        bounce: true
                        colBackground: root.colSurface
                        colBackgroundHover: root.colSurfaceHover
                        colBackgroundToggled: root.colLayer2
                        colBackgroundToggledHover: root.colLayer2Hover
                        onClicked: root.currentView = "queue"
                        contentItem: RowLayout {
                            spacing: 4
                            MaterialSymbol {
                                text: "queue_music"
                                iconSize: 18
                                color: root.currentView === "queue" ? root.colPrimary : root.colTextSecondary
                            }
                            StyledText {
                                visible: root.hasQueue
                                text: `${YTMusic.queue.length}`
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: root.currentView === "queue" ? root.colPrimary : root.colText
                            }
                        }
                    }
                }

                YTMusicPlayerCard {
                    Layout.fillWidth: true
                    visible: root.hasTrack
                }

                Loader {
                    Layout.fillWidth: true
                    active: YTMusic.error !== ""
                    visible: active
                    sourceComponent: Rectangle {
                        implicitHeight: 36
                        radius: root.radiusSmall
                        color: Appearance.colors.colErrorContainer
                        RowLayout {
                            anchors.centerIn: parent
                            width: parent.width - 16
                            spacing: 8
                            MaterialSymbol { text: "error"; iconSize: 18; color: Appearance.colors.colOnErrorContainer }
                            StyledText { 
                                Layout.fillWidth: true
                                text: YTMusic.error
                                color: Appearance.colors.colOnErrorContainer
                                font.pixelSize: Appearance.font.pixelSize.small
                                elide: Text.ElideRight 
                            }
                            RippleButton { 
                                implicitWidth: 24
                                implicitHeight: 24
                                buttonRadius: 12
                                colBackground: "transparent"
                                onClicked: YTMusic.error = ""
                                contentItem: MaterialSymbol { 
                                    anchors.centerIn: parent
                                    text: "close"
                                    iconSize: 16
                                    color: Appearance.colors.colOnErrorContainer 
                                } 
                            }
                        }
                    }
                }

                // Connection Banner - shows on non-library tabs when not connected
                ConnectionBanner {
                    Layout.fillWidth: true
                    extraHidden: root.currentView === "playlists"
                }

    Popup {
        id: advancedOptionsPopup
        anchors.centerIn: parent
        width: 300
        height: Math.min(400, advancedContent.implicitHeight + 40)
        padding: 16
        modal: true
        dim: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        background: Rectangle {
            color: Appearance.inirEverywhere ? Appearance.inir.colLayer2
                 : Appearance.auroraEverywhere ? Appearance.colors.colLayer1Base
                 : Appearance.colors.colLayer1
            radius: root.radiusNormal
            border.width: root.borderWidth
            border.color: root.colBorder
        }

        contentItem: ColumnLayout {
            id: advancedContent
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                StyledText {
                    text: TranslationService.tr("Connection Options")
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.weight: Font.Bold
                    color: root.colText
                }
                Item { Layout.fillWidth: true }
                RippleButton {
                    implicitWidth: 24
                    implicitHeight: 24
                    buttonRadius: 12
                    colBackground: "transparent"
                    colBackgroundHover: root.colLayer2Hover
                    onClicked: advancedOptionsPopup.close()
                    contentItem: MaterialSymbol { anchors.centerIn: parent; text: "close"; iconSize: 18; color: root.colTextSecondary }
                }
            }

            // Connected account section
            Rectangle {
                Layout.fillWidth: true
                visible: YTMusic.googleConnected
                implicitHeight: connectedContent.implicitHeight + 16
                radius: root.radiusSmall
                color: ColorUtils.transparentize(Appearance.colors.colPrimary, 0.92)
                border.width: root.borderWidth
                border.color: ColorUtils.transparentize(Appearance.colors.colPrimary, 0.7)

                ColumnLayout {
                    id: connectedContent
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: 16
                            color: ColorUtils.transparentize(root.colPrimary, 0.85)

                            Image {
                                anchors.fill: parent
                                anchors.margins: 1
                                source: YTMusic.userAvatar || ""
                                visible: YTMusic.userAvatar !== ""
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                layer.enabled: true
                                layer.effect: GE.OpacityMask {
                                    maskSource: Rectangle { width: 30; height: 30; radius: 15 }
                                }
                            }

                            MaterialSymbol {
                                anchors.centerIn: parent
                                visible: !YTMusic.userAvatar
                                text: "account_circle"
                                iconSize: 20
                                color: root.colPrimary
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            StyledText {
                                text: YTMusic.userName || TranslationService.tr("Connected")
                                font.pixelSize: Appearance.font.pixelSize.small
                                font.weight: Font.Medium
                                color: root.colText
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            StyledText {
                                text: YTMusic.googleBrowser
                                    ? TranslationService.tr("via %1").arg(YTMusic.getBrowserDisplayName(YTMusic.googleBrowser))
                                    : TranslationService.tr("Connected")
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: root.colTextSecondary
                            }
                        }
                    }

                    RippleButton {
                        Layout.fillWidth: true
                        implicitHeight: 32
                        buttonRadius: root.radiusSmall
                        colBackground: ColorUtils.transparentize(Appearance.colors.colError, 0.9)
                        colBackgroundHover: ColorUtils.transparentize(Appearance.colors.colError, 0.8)
                        onClicked: { YTMusic.disconnectGoogle(); advancedOptionsPopup.close() }
                        contentItem: RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            MaterialSymbol { text: "logout"; iconSize: 16; color: Appearance.colors.colError }
                            StyledText { text: TranslationService.tr("Disconnect"); color: Appearance.colors.colError; font.pixelSize: Appearance.font.pixelSize.smaller }
                        }
                    }
                }
            }

            // Instructions (only when not connected)
            Rectangle {
                Layout.fillWidth: true
                visible: !YTMusic.googleConnected
                implicitHeight: infoColPopup.implicitHeight + 16
                radius: root.radiusSmall
                color: ColorUtils.transparentize(root.colPrimary, 0.95)
                border.width: root.borderWidth
                border.color: ColorUtils.transparentize(root.colPrimary, 0.8)

                ColumnLayout {
                    id: infoColPopup
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 6

                    StyledText {
                        Layout.fillWidth: true
                        text: TranslationService.tr("Log in to YouTube Music in your browser, then select it below.")
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        color: root.colText
                        wrapMode: Text.WordWrap
                    }

                    RippleButton {
                        implicitWidth: 150
                        implicitHeight: 28
                        buttonRadius: 14
                        colBackground: root.colLayer2
                        onClicked: YTMusic.openYtMusicInBrowser()
                        contentItem: RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            MaterialSymbol { text: "open_in_new"; iconSize: 14; color: root.colPrimary }
                            StyledText { text: TranslationService.tr("Open YouTube Music"); color: root.colPrimary; font.pixelSize: Appearance.font.pixelSize.smaller }
                        }
                    }
                }
            }

            StyledText {
                text: TranslationService.tr("Select Browser")
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.DemiBold
                color: root.colText
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 6
                columnSpacing: 6
                visible: YTMusic.detectedBrowsers.length > 0

                Repeater {
                    model: YTMusic.detectedBrowsers
                    delegate: RippleButton {
                        required property string modelData
                        readonly property bool isConnected: YTMusic.googleConnected && YTMusic.googleBrowser === modelData
                        Layout.fillWidth: true
                        implicitHeight: 36
                        buttonRadius: root.radiusSmall
                        colBackground: isConnected ? ColorUtils.transparentize(root.colPrimary, 0.85) : root.colLayer2
                        colBackgroundHover: isConnected ? ColorUtils.transparentize(root.colPrimary, 0.75) : root.colSurfaceHover
                        onClicked: { YTMusic.connectGoogle(modelData); advancedOptionsPopup.close() }
                        contentItem: RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 6
                            StyledText { text: YTMusic.browserInfo[modelData]?.icon ?? "🌐"; font.pixelSize: 14 }
                            StyledText {
                                text: YTMusic.browserInfo[modelData]?.name ?? modelData
                                color: isConnected ? root.colPrimary : root.colText
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                font.weight: isConnected ? Font.Medium : Font.Normal
                                Layout.fillWidth: true
                            }
                            MaterialSymbol {
                                visible: isConnected
                                text: "check_circle"
                                iconSize: 16
                                color: root.colPrimary
                            }
                        }
                    }
                }
            }

            StyledText {
                text: TranslationService.tr("Custom Cookies File")
                font.pixelSize: Appearance.font.pixelSize.small
                font.weight: Font.DemiBold
                color: root.colText
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 36
                radius: root.radiusSmall
                color: root.colLayer2
                border.width: root.borderWidth
                border.color: cookiesFieldPopup.activeFocus ? root.colPrimary : root.colBorder

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 6
                    MaterialSymbol { text: "description"; iconSize: 16; color: root.colTextSecondary }
                    TextField {
                        id: cookiesFieldPopup
                        Layout.fillWidth: true
                        placeholderText: "/path/to/cookies.txt"
                        text: YTMusic.customCookiesPath
                        color: root.colText
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        placeholderTextColor: root.colTextSecondary
                        background: Item {}
                        onAccepted: if (text) { YTMusic.setCustomCookiesPath(text); advancedOptionsPopup.close() }
                    }
                }
            }
        }
    }
                StackLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: ["search", "playlists", "queue"].indexOf(root.currentView)

                    SearchView {}
                    LibraryView {}
                    QueueView {}
                }
            }
        }
    }

    Popup {
        id: addToPlaylistPopup
        anchors.centerIn: parent
        width: 220
        height: Math.min(300, Math.max(120, YTMusic.playlists.length * 40 + 80))
        padding: 12
        modal: true
        dim: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        property var targetItem: null

        background: Rectangle { 
            color: Appearance.inirEverywhere ? Appearance.inir.colLayer2
                 : Appearance.auroraEverywhere ? Appearance.colors.colLayer1Base
                 : Appearance.colors.colLayer1
            radius: root.radiusNormal
            border.width: root.borderWidth
            border.color: root.colBorder 
        }
        
        contentItem: ColumnLayout {
            spacing: 8
            StyledText { 
                Layout.alignment: Qt.AlignHCenter
                text: TranslationService.tr("Add to Playlist")
                font.weight: Font.Medium
                color: root.colText 
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                reuseItems: true
                model: YTMusic.playlists
                spacing: 2
                delegate: RippleButton {
                    required property var modelData
                    required property int index
                    width: ListView.view.width
                    implicitHeight: 36
                    buttonRadius: root.radiusSmall
                    colBackground: "transparent"
                    colBackgroundHover: root.colLayer2Hover
                    onClicked: { 
                        if (addToPlaylistPopup.targetItem) { 
                            YTMusic.addToPlaylist(index, addToPlaylistPopup.targetItem)
                            addToPlaylistPopup.close() 
                        } 
                    }
                    contentItem: StyledText { 
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        verticalAlignment: Text.AlignVCenter
                        text: modelData.name ?? ""
                        color: root.colText
                        elide: Text.ElideRight 
                    }
                }
            }
            
            RippleButton {
                Layout.fillWidth: true
                implicitHeight: 32
                buttonRadius: root.radiusSmall
                colBackground: root.colLayer2
                colBackgroundHover: root.colLayer2Hover
                onClicked: { 
                    addToPlaylistPopup.close()
                    createPlaylistPopup.open() 
                }
                contentItem: RowLayout { 
                    anchors.centerIn: parent
                    spacing: 4
                    MaterialSymbol { text: "add"; iconSize: 18; color: root.colPrimary }
                    StyledText { text: TranslationService.tr("New Playlist"); color: root.colPrimary } 
                }
            }
        }
    }

    Popup {
        id: createPlaylistPopup
        anchors.centerIn: parent
        width: 280
        height: 120
        modal: true
        dim: true
        background: Rectangle { 
            color: Appearance.inirEverywhere ? Appearance.inir.colLayer2
                 : Appearance.auroraEverywhere ? Appearance.colors.colLayer1Base
                 : Appearance.colors.colLayer1
            radius: root.radiusNormal
            border.width: root.borderWidth
            border.color: root.colBorder 
        }
        contentItem: ColumnLayout {
            spacing: 12
            StyledText { 
                text: TranslationService.tr("New Playlist")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: root.colText 
            }
            MaterialTextField {
                id: newPlaylistName
                Layout.fillWidth: true
                placeholderText: TranslationService.tr("Playlist name")
                onAccepted: createBtn.clicked()
            }
            RowLayout { 
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                RippleButton { 
                    id: createBtn
                    implicitWidth: 80
                    implicitHeight: 32
                    buttonRadius: root.radiusSmall
                    colBackground: root.colPrimary
                    onClicked: { 
                        if (newPlaylistName.text.trim()) { 
                            YTMusic.createPlaylist(newPlaylistName.text)
                            newPlaylistName.text = ""
                            createPlaylistPopup.close() 
                        } 
                    }
                    contentItem: StyledText { 
                        anchors.centerIn: parent
                        text: TranslationService.tr("Create")
                        color: Appearance.colors.colOnPrimary 
                    }
                }
            }
        }
    }

    // Save Queue as Playlist Popup
    Popup {
        id: saveQueuePopup
        anchors.centerIn: parent
        width: 280
        height: 120
        modal: true
        dim: true
        background: Rectangle {
            color: Appearance.inirEverywhere ? Appearance.inir.colLayer2
                 : Appearance.auroraEverywhere ? Appearance.colors.colLayer1Base
                 : Appearance.colors.colLayer1
            radius: root.radiusNormal
            border.width: root.borderWidth
            border.color: root.colBorder
        }
        contentItem: ColumnLayout {
            spacing: 12
            StyledText {
                text: TranslationService.tr("Save Queue as Playlist")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: root.colText
            }
            MaterialTextField {
                id: saveQueueName
                Layout.fillWidth: true
                placeholderText: TranslationService.tr("Playlist name")
                onAccepted: saveQueueBtn.clicked()
            }
            RowLayout {
                Layout.fillWidth: true
                Item { Layout.fillWidth: true }
                RippleButton {
                    id: saveQueueBtn
                    implicitWidth: 80
                    implicitHeight: 32
                    buttonRadius: root.radiusSmall
                    colBackground: root.colPrimary
                    onClicked: {
                        if (saveQueueName.text.trim() && YTMusic.queue.length > 0) {
                            YTMusic.createPlaylist(saveQueueName.text)
                            // Add all queue items to the new playlist
                            const newIdx = YTMusic.playlists.length - 1
                            for (let i = 0; i < YTMusic.queue.length; i++) {
                                YTMusic.addToPlaylist(newIdx, YTMusic.queue[i])
                            }
                            saveQueueName.text = ""
                            saveQueuePopup.close()
                        }
                    }
                    contentItem: StyledText {
                        anchors.centerIn: parent
                        text: TranslationService.tr("Save")
                        color: Appearance.colors.colOnPrimary
                    }
                }
            }
        }
    }


    component SearchView: ColumnLayout {
        spacing: 8

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 42
            radius: Appearance.inirEverywhere ? root.radiusSmall : Appearance.rounding.full
            color: root.colLayer2
            border.width: root.borderWidth
            border.color: root.colBorder

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 10
                spacing: 10
                
                MaterialSymbol { 
                    text: YTMusic.searching ? "hourglass_empty" : "search"
                    iconSize: 20
                    color: root.colTextSecondary
                    RotationAnimation on rotation { 
                        from: 0; to: 360; duration: 1000
                        loops: Animation.Infinite
                        running: YTMusic.searching 
                    }
                }
                
                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    placeholderText: TranslationService.tr("Search YouTube Music...")
                    color: root.colText
                    placeholderTextColor: root.colTextSecondary
                    font.pixelSize: Appearance.font.pixelSize.normal
                    font.family: Appearance.font.family.main
                    background: Item {}
                    selectByMouse: true
                    onAccepted: { if (text.trim()) YTMusic.search(text) }
                    Keys.onEscapePressed: { text = ""; focus = false }
                }
                
                RippleButton {
                    implicitWidth: 28
                    implicitHeight: 28
                    visible: searchField.text.length > 0
                    buttonRadius: 14
                    colBackground: "transparent"
                    colBackgroundHover: root.colLayer2Hover
                    onClicked: { searchField.text = ""; searchField.forceActiveFocus() }
                    contentItem: MaterialSymbol { 
                        anchors.centerIn: parent
                        text: "close"
                        iconSize: 18
                        color: root.colTextSecondary 
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            PagePlaceholder {
                anchors.fill: parent
                shown: !root.hasResults && !YTMusic.searching && YTMusic.recentSearches.length === 0
                icon: "library_music"
                title: TranslationService.tr("Search for music")
                description: TranslationService.tr("Find songs, artists, and albums")
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 6
                visible: !root.hasResults && !YTMusic.searching && YTMusic.recentSearches.length > 0
                
                RowLayout {
                    Layout.fillWidth: true
                    StyledText { 
                        text: TranslationService.tr("Recent")
                        font.pixelSize: Appearance.font.pixelSize.small
                        font.weight: Font.Medium
                        color: root.colTextSecondary 
                    }
                    Item { Layout.fillWidth: true }
                    RippleButton { 
                        implicitWidth: 24
                        implicitHeight: 24
                        buttonRadius: 12
                        colBackground: "transparent"
                        colBackgroundHover: root.colLayer2Hover
                        onClicked: YTMusic.clearRecentSearches()
                        contentItem: MaterialSymbol { 
                            anchors.centerIn: parent
                            text: "delete_sweep"
                            iconSize: 16
                            color: root.colTextSecondary 
                        }
                        StyledToolTip { text: TranslationService.tr("Clear") }
                    }
                }
                
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    reuseItems: true
                    model: YTMusic.recentSearches
                    spacing: 2
                    delegate: RippleButton {
                        required property string modelData
                        width: ListView.view.width
                        implicitHeight: 36
                        buttonRadius: root.radiusSmall
                        colBackground: "transparent"
                        colBackgroundHover: root.colSurfaceHover
                        onClicked: { searchField.text = modelData; YTMusic.search(modelData) }
                        contentItem: RowLayout { 
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 8
                            MaterialSymbol { text: "history"; iconSize: 18; color: root.colTextSecondary }
                            StyledText { Layout.fillWidth: true; text: modelData; color: root.colText; elide: Text.ElideRight }
                        }
                    }
                }
            }

            ListView {
                anchors.fill: parent
                visible: root.hasResults || YTMusic.searching
                clip: true
                reuseItems: true
                cacheBuffer: 200
                model: YTMusic.searchResults
                spacing: 4
                
                header: Column {
                    width: parent.width
                    spacing: 8
                    
                    // Artist header card - shows when artist info is available
                    Rectangle {
                        width: parent.width
                        height: YTMusic.currentArtistInfo ? 56 : 0
                        visible: YTMusic.currentArtistInfo !== null
                        radius: root.radiusSmall
                        color: Appearance.inirEverywhere ? Appearance.inir.colLayer2
                             : Appearance.auroraEverywhere ? Appearance.colors.colLayer1Base
                             : root.colLayer2
                        border.width: root.borderWidth
                        border.color: root.colBorder
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 10
                            
                            // Artist avatar
                            Rectangle {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                radius: 20
                                color: root.colSurfaceHover
                                
                                Image {
                                    anchors.fill: parent
                                    anchors.margins: 1
                                    source: YTMusic.currentArtistInfo?.thumbnail ?? ""
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    visible: source !== ""
                                    layer.enabled: true
                                    layer.effect: GE.OpacityMask {
                                        maskSource: Rectangle { width: 38; height: 38; radius: 19 }
                                    }
                                }
                                
                                MaterialSymbol {
                                    anchors.centerIn: parent
                                    visible: !YTMusic.currentArtistInfo?.thumbnail
                                    text: "person"
                                    iconSize: 24
                                    color: root.colTextSecondary
                                }
                            }
                            
                            // Artist name
                            StyledText {
                                Layout.fillWidth: true
                                text: YTMusic.currentArtistInfo?.name ?? ""
                                font.pixelSize: Appearance.font.pixelSize.normal
                                font.weight: Font.Medium
                                color: root.colText
                                elide: Text.ElideRight
                            }
                            
                            // Play all from this artist
                            RippleButton {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                buttonRadius: 16
                                colBackground: root.colPrimary
                                visible: root.hasResults
                                onClicked: {
                                    // Play first result
                                    if (YTMusic.searchResults.length > 0) {
                                        YTMusic.playFromSearch(0)
                                    }
                                }
                                contentItem: MaterialSymbol {
                                    anchors.centerIn: parent
                                    text: "play_arrow"
                                    iconSize: 20
                                    fill: 1
                                    color: Appearance.colors.colOnPrimary
                                }
                                StyledToolTip { text: TranslationService.tr("Play") }
                            }
                        }
                    }
                    
                    // Searching indicator
                    Loader {
                        width: parent.width
                        active: YTMusic.searching
                        height: active ? 40 : 0
                        sourceComponent: RowLayout {
                            spacing: 8
                            Item { Layout.fillWidth: true }
                            MaterialLoadingIndicator { implicitSize: 24; loading: true }
                            StyledText { text: TranslationService.tr("Searching..."); color: root.colTextSecondary }
                            Item { Layout.fillWidth: true }
                        }
                    }
                }
                
                delegate: YTMusicTrackItem {
                    required property var modelData
                    required property int index
                    width: ListView.view?.width ?? 200
                    track: modelData
                    showAddToPlaylist: true
                    onPlayRequested: YTMusic.playFromSearch(index)
                    onAddToPlaylistRequested: root.openAddToPlaylist(modelData)
                }
            }
        }
    }

    component LibraryView: ColumnLayout {
        spacing: 8
        property int expandedPlaylist: -1
        property bool showLiked: false

        // Account Card - always visible in main library view
        Rectangle {
            Layout.fillWidth: true
            visible: expandedPlaylist < 0 && !showLiked
            implicitHeight: visible ? accountCardContent.implicitHeight + 20 : 0
            radius: root.radiusSmall
            color: YTMusic.googleConnected
                ? root.colLayer2
                : ColorUtils.transparentize(root.colPrimary, 0.92)
            border.width: root.borderWidth
            border.color: YTMusic.googleConnected
                ? root.colBorder
                : ColorUtils.transparentize(root.colPrimary, 0.75)

            Behavior on color {
                enabled: Appearance.animationsEnabled
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
            }

            ColumnLayout {
                id: accountCardContent
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    // Avatar / connect icon
                    Rectangle {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        radius: 18
                        color: ColorUtils.transparentize(root.colPrimary, 0.85)

                        Image {
                            anchors.fill: parent
                            anchors.margins: 1
                            source: YTMusic.userAvatar || ""
                            visible: YTMusic.googleConnected && YTMusic.userAvatar !== ""
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            layer.enabled: true
                            layer.effect: GE.OpacityMask {
                                maskSource: Rectangle { width: 34; height: 34; radius: 17 }
                            }
                        }

                        MaterialSymbol {
                            anchors.centerIn: parent
                            visible: !YTMusic.googleConnected || !YTMusic.userAvatar
                            text: YTMusic.googleConnected ? "account_circle" : "link"
                            iconSize: 22
                            color: root.colPrimary
                        }
                    }

                    // Name / connect prompt
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        StyledText {
                            text: YTMusic.googleConnected
                                ? (YTMusic.userName || TranslationService.tr("Connected"))
                                : TranslationService.tr("Sign in to YouTube")
                            font.pixelSize: Appearance.font.pixelSize.small
                            font.weight: Font.Medium
                            color: root.colText
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        StyledText {
                            text: YTMusic.googleChecking ? TranslationService.tr("Connecting...")
                                : YTMusic.googleConnected
                                    ? (YTMusic.syncingLiked ? TranslationService.tr("Syncing...")
                                        : YTMusic.lastLikedSync ? TranslationService.tr("Synced %1").arg(YTMusic.lastLikedSync)
                                        : TranslationService.tr("Not synced yet"))
                                    : TranslationService.tr("Access liked songs & playlists")
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            color: YTMusic.googleChecking || YTMusic.syncingLiked ? root.colPrimary : root.colTextSecondary
                        }
                    }

                    // Connected: Sync button
                    RippleButton {
                        visible: YTMusic.googleConnected
                        implicitWidth: 32
                        implicitHeight: 32
                        buttonRadius: 16
                        colBackground: root.colSurfaceHover
                        colBackgroundHover: root.colLayer2Hover
                        enabled: !YTMusic.syncingLiked
                        onClicked: { YTMusic.fetchLikedSongs(); YTMusic.fetchYtMusicPlaylists() }
                        contentItem: MaterialSymbol {
                            anchors.centerIn: parent
                            text: "sync"
                            iconSize: 20
                            color: root.colPrimary
                            RotationAnimation on rotation {
                                from: 0; to: 360; duration: 1000
                                loops: Animation.Infinite
                                running: YTMusic.syncingLiked
                            }
                        }
                        StyledToolTip { text: TranslationService.tr("Sync library") }
                    }

                    // Connected: Disconnect button
                    RippleButton {
                        visible: YTMusic.googleConnected
                        implicitWidth: 32
                        implicitHeight: 32
                        buttonRadius: 16
                        colBackground: "transparent"
                        colBackgroundHover: ColorUtils.transparentize(Appearance.colors.colError, 0.85)
                        onClicked: YTMusic.disconnectGoogle()
                        contentItem: MaterialSymbol {
                            anchors.centerIn: parent
                            text: "logout"
                            iconSize: 18
                            color: root.colTextSecondary
                        }
                        StyledToolTip { text: TranslationService.tr("Disconnect") }
                    }

                    // Not connected: Connect button
                    RippleButton {
                        visible: !YTMusic.googleConnected && !YTMusic.googleChecking
                        implicitWidth: 80
                        implicitHeight: 32
                        buttonRadius: 16
                        colBackground: root.colPrimary
                        onClicked: YTMusic.quickConnect()
                        contentItem: StyledText {
                            anchors.centerIn: parent
                            text: TranslationService.tr("Connect")
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            font.weight: Font.Medium
                            color: Appearance.colors.colOnPrimary
                        }
                    }

                    // Checking: loading indicator
                    MaterialLoadingIndicator {
                        visible: YTMusic.googleChecking
                        implicitSize: 20
                        loading: visible
                    }
                }

                // Error row - shows inline when connection fails
                RowLayout {
                    Layout.fillWidth: true
                    visible: YTMusic.googleError !== "" && !YTMusic.googleChecking
                    spacing: 6

                    MaterialSymbol { text: "error"; iconSize: 14; color: Appearance.colors.colError }
                    StyledText {
                        Layout.fillWidth: true
                        text: YTMusic.googleError
                        font.pixelSize: Appearance.font.pixelSize.smallest
                        color: Appearance.colors.colError
                        wrapMode: Text.WordWrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }
                    RippleButton {
                        implicitWidth: 56
                        implicitHeight: 24
                        buttonRadius: 12
                        colBackground: ColorUtils.transparentize(Appearance.colors.colError, 0.85)
                        onClicked: YTMusic.quickConnect()
                        contentItem: StyledText {
                            anchors.centerIn: parent
                            text: TranslationService.tr("Retry")
                            font.pixelSize: Appearance.font.pixelSize.smallest
                            color: Appearance.colors.colError
                        }
                    }
                    RippleButton {
                        implicitWidth: 24
                        implicitHeight: 24
                        buttonRadius: 12
                        colBackground: "transparent"
                        onClicked: advancedOptionsPopup.open()
                        contentItem: MaterialSymbol {
                            anchors.centerIn: parent
                            text: "settings"
                            iconSize: 14
                            color: root.colTextSecondary
                        }
                        StyledToolTip { text: TranslationService.tr("Advanced") }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            
            RippleButton {
                visible: expandedPlaylist >= 0 || showLiked
                implicitWidth: 32
                implicitHeight: 32
                buttonRadius: 16
                colBackground: "transparent"
                colBackgroundHover: root.colLayer2Hover
                onClicked: { expandedPlaylist = -1; showLiked = false }
                contentItem: MaterialSymbol { anchors.centerIn: parent; text: "arrow_back"; iconSize: 20; color: root.colText }
            }
            
            StyledText { 
                text: showLiked ? TranslationService.tr("Liked Songs") 
                    : expandedPlaylist >= 0 ? (YTMusic.playlists[expandedPlaylist]?.name ?? "") 
                    : TranslationService.tr("Library")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: root.colText
            }
            
            Item { Layout.fillWidth: true }
            
            // Settings/connection options
            RippleButton {
                visible: expandedPlaylist < 0 && !showLiked
                implicitWidth: 32
                implicitHeight: 32
                buttonRadius: root.radiusSmall
                colBackground: root.colSurface
                colBackgroundHover: root.colSurfaceHover
                onClicked: advancedOptionsPopup.open()
                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: "tune"
                    iconSize: 18
                    color: root.colTextSecondary
                }
                StyledToolTip { text: TranslationService.tr("Connection settings") }
            }
            
            RippleButton {
                visible: (expandedPlaylist >= 0 && (YTMusic.playlists[expandedPlaylist]?.items?.length ?? 0) > 0) || (showLiked && YTMusic.likedSongs.length > 0)
                implicitWidth: 32
                implicitHeight: 32
                buttonRadius: 16
                colBackground: root.colPrimary
                onClicked: showLiked ? _playLiked(false) : YTMusic.playPlaylist(expandedPlaylist, false)
                contentItem: MaterialSymbol { anchors.centerIn: parent; text: "play_arrow"; iconSize: 20; color: Appearance.colors.colOnPrimary }
                StyledToolTip { text: TranslationService.tr("Play all") }
            }
            
            RippleButton {
                visible: (expandedPlaylist >= 0 && (YTMusic.playlists[expandedPlaylist]?.items?.length ?? 0) > 1) || (showLiked && YTMusic.likedSongs.length > 1)
                implicitWidth: 32
                implicitHeight: 32
                buttonRadius: 16
                colBackground: "transparent"
                colBackgroundHover: root.colLayer2Hover
                onClicked: showLiked ? _playLiked(true) : YTMusic.playPlaylist(expandedPlaylist, true)
                contentItem: MaterialSymbol { anchors.centerIn: parent; text: "shuffle"; iconSize: 20; color: root.colTextSecondary }
                StyledToolTip { text: TranslationService.tr("Shuffle") }
            }
            
            RippleButton {
                visible: expandedPlaylist < 0 && !showLiked
                implicitWidth: 32
                implicitHeight: 32
                buttonRadius: 16
                colBackground: root.colPrimary
                onClicked: createPlaylistPopup.open()
                contentItem: MaterialSymbol { anchors.centerIn: parent; text: "add"; iconSize: 20; color: Appearance.colors.colOnPrimary }
                StyledToolTip { text: TranslationService.tr("New playlist") }
            }
        }

        function _playLiked(shuffle) {
            let items = [...YTMusic.likedSongs]
            if (items.length === 0) return
            let startIndex = 0
            if (shuffle) { 
                for (let i = items.length - 1; i > 0; i--) { 
                    const j = Math.floor(Math.random() * (i + 1))
                    const temp = items[i]
                    items[i] = items[j]
                    items[j] = temp
                } 
            }
            YTMusic.playFromPlaylist(items, startIndex, "liked")
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: expandedPlaylist < 0 && !showLiked
            clip: true
            reuseItems: true
            spacing: 4
            model: ListModel {
                id: libraryModel
                Component.onCompleted: _rebuild()
                function _rebuild() {
                    clear()
                    // Liked Songs - heart icon
                    append({ type: "liked", name: TranslationService.tr("Liked Songs"), count: YTMusic.likedSongs.length, icon: "favorite", idx: -1, isCloud: false })
                    // Local playlists - playlist icon
                    for (let i = 0; i < YTMusic.playlists.length; i++) {
                        append({ type: "playlist", name: YTMusic.playlists[i].name, count: YTMusic.playlists[i].items?.length ?? 0, icon: "playlist_play", idx: i, isCloud: false })
                    }
                    // YouTube playlists (cloud) - with separator
                    if (YTMusic.googleConnected && YTMusic.ytMusicPlaylists.length > 0) {
                        append({ type: "separator", name: TranslationService.tr("YouTube Playlists"), count: 0, icon: "cloud_sync", idx: -1, isCloud: true })
                        for (let j = 0; j < YTMusic.ytMusicPlaylists.length; j++) {
                            const pl = YTMusic.ytMusicPlaylists[j]
                            append({ type: "cloud", name: pl.title, count: pl.count ?? 0, icon: "cloud_download", idx: j, isCloud: true, url: pl.url })
                        }
                    }
                }
            }
            Connections {
                target: YTMusic
                function onPlaylistsChanged() { libraryModel._rebuild() }
                function onLikedSongsChanged() { libraryModel._rebuild() }
                function onYtMusicPlaylistsChanged() { libraryModel._rebuild() }
                function onGoogleConnectedChanged() { libraryModel._rebuild() }
            }
            delegate: Item {
                required property var model
                required property int index
                width: ListView.view.width
                implicitHeight: model.type === "separator" ? 32 : 56

                // Separator for cloud playlists
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    visible: model.type === "separator"
                    spacing: 6

                    MaterialSymbol {
                        text: "cloud"
                        iconSize: 16
                        color: root.colTextSecondary
                    }
                    StyledText {
                        text: model.name
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        font.weight: Font.Medium
                        color: root.colTextSecondary
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: root.colBorder
                        visible: Appearance.inirEverywhere
                    }
                }

                // Regular playlist item
                RippleButton {
                    anchors.fill: parent
                    visible: model.type !== "separator"
                    buttonRadius: root.radiusSmall
                    colBackground: "transparent"
                    colBackgroundHover: root.colSurfaceHover
                    onClicked: {
                        if (model.type === "liked") {
                            showLiked = true
                        } else if (model.type === "cloud") {
                            // Import cloud playlist - get URL from ytMusicPlaylists array
                            const pl = YTMusic.ytMusicPlaylists[model.idx]
                            if (pl && pl.url) {
                                YTMusic.importYtMusicPlaylist(pl.url, pl.title)
                            }
                        } else {
                            expandedPlaylist = model.idx
                        }
                    }
                    contentItem: RowLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 10
                        Rectangle {
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40
                            radius: root.radiusSmall
                            color: root.colLayer2
                            MaterialSymbol {
                                anchors.centerIn: parent
                                text: model.icon
                                iconSize: 22
                                color: model.type === "liked" ? Appearance.colors.colError
                                     : model.isCloud ? root.colTextSecondary
                                     : root.colPrimary
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            StyledText {
                                Layout.fillWidth: true
                                text: model.name
                                font.pixelSize: Appearance.font.pixelSize.normal
                                font.weight: Font.Medium
                                color: root.colText
                                elide: Text.ElideRight
                            }
                            StyledText {
                                text: model.isCloud ? TranslationService.tr("%1 tracks • Tap to import").arg(model.count)
                                    : TranslationService.tr("%1 songs").arg(model.count)
                                font.pixelSize: Appearance.font.pixelSize.smaller
                                color: root.colTextSecondary
                            }
                        }
                        MaterialSymbol {
                            text: model.isCloud ? "download" : "chevron_right"
                            iconSize: 20
                            color: root.colTextSecondary
                        }
                    }
                }
            }

            PagePlaceholder {
                anchors.fill: parent
                shown: YTMusic.playlists.length === 0 && YTMusic.likedSongs.length === 0
                icon: "playlist_add"
                title: TranslationService.tr("No playlists yet")
                description: TranslationService.tr("Create a playlist or sync your library")
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: expandedPlaylist >= 0
            clip: true
            reuseItems: true
            cacheBuffer: 200
            spacing: 4
            model: expandedPlaylist >= 0 ? (YTMusic.playlists[expandedPlaylist]?.items ?? []) : []
            delegate: YTMusicTrackItem {
                required property var modelData
                required property int index
                width: ListView.view?.width ?? 200
                track: modelData
                trackIndex: index
                showIndex: true
                showRemoveButton: true
                showAddToQueue: false
                onPlayRequested: YTMusic.playFromPlaylist(YTMusic.playlists[expandedPlaylist]?.items ?? [], index, "playlist:" + (YTMusic.playlists[expandedPlaylist]?.name ?? ""))
                onRemoveRequested: YTMusic.removeFromPlaylist(expandedPlaylist, index)
            }
            PagePlaceholder {
                anchors.fill: parent
                shown: expandedPlaylist >= 0 && (YTMusic.playlists[expandedPlaylist]?.items?.length ?? 0) === 0
                icon: "music_off"
                title: TranslationService.tr("Playlist is empty")
                description: TranslationService.tr("Add songs from search")
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: showLiked
            clip: true
            reuseItems: true
            cacheBuffer: 200
            spacing: 4
            model: YTMusic.likedSongs
            delegate: YTMusicTrackItem {
                required property var modelData
                required property int index
                width: ListView.view?.width ?? 200
                track: modelData
                showAddToPlaylist: true
                onPlayRequested: YTMusic.playFromLiked(index)
                onAddToPlaylistRequested: root.openAddToPlaylist(modelData)
            }
            PagePlaceholder {
                anchors.fill: parent
                shown: YTMusic.likedSongs.length === 0
                icon: "favorite"
                title: YTMusic.googleConnected ? TranslationService.tr("No liked songs") : TranslationService.tr("Sign in to see liked songs")
                description: YTMusic.googleConnected ? TranslationService.tr("Like songs on YouTube Music to see them here") : TranslationService.tr("Connect your account to sync your library")
            }
            RippleButton {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: parent.height * 0.25
                visible: YTMusic.googleConnected && YTMusic.likedSongs.length === 0
                implicitWidth: 120
                implicitHeight: 36
                buttonRadius: 18
                colBackground: root.colPrimary
                onClicked: YTMusic.fetchLikedSongs()
                contentItem: StyledText { anchors.centerIn: parent; text: TranslationService.tr("Sync Now"); color: Appearance.colors.colOnPrimary }
            }
        }

        RippleButton {
            Layout.fillWidth: true
            visible: expandedPlaylist >= 0
            implicitHeight: 36
            buttonRadius: root.radiusSmall
            colBackground: "transparent"
            colBackgroundHover: ColorUtils.transparentize(Appearance.colors.colError, 0.85)
            onClicked: { YTMusic.deletePlaylist(expandedPlaylist); expandedPlaylist = -1 }
            contentItem: RowLayout { 
                anchors.centerIn: parent
                spacing: 8
                MaterialSymbol { text: "delete"; iconSize: 18; color: Appearance.colors.colError }
                StyledText { text: TranslationService.tr("Delete playlist"); color: Appearance.colors.colError } 
            }
        }
    }


    component QueueView: ColumnLayout {
        spacing: 8

        // Helper function to format duration
        function formatDuration(totalSecs) {
            const hours = Math.floor(totalSecs / 3600)
            const mins = Math.floor((totalSecs % 3600) / 60)
            const secs = Math.floor(totalSecs % 60)
            if (hours > 0) {
                return `${hours}:${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
            }
            return `${mins}:${secs.toString().padStart(2, '0')}`
        }

        // Calculate total duration
        readonly property int totalDuration: {
            let total = 0
            for (let i = 0; i < YTMusic.queue.length; i++) {
                total += YTMusic.queue[i]?.duration || 0
            }
            return total
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            StyledText {
                text: TranslationService.tr("Queue")
                font.pixelSize: Appearance.font.pixelSize.normal
                font.weight: Font.Medium
                color: root.colText
            }
            StyledText {
                visible: root.hasQueue
                text: totalDuration > 0
                    ? `${YTMusic.queue.length} • ${formatDuration(totalDuration)}`
                    : `(${YTMusic.queue.length})`
                font.pixelSize: Appearance.font.pixelSize.small
                color: root.colTextSecondary
            }
            Item { Layout.fillWidth: true }

            // Save as playlist button
            RippleButton {
                visible: YTMusic.queue.length > 0
                implicitWidth: 28
                implicitHeight: 28
                buttonRadius: 14
                colBackground: "transparent"
                colBackgroundHover: root.colLayer2Hover
                onClicked: saveQueuePopup.open()
                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: "playlist_add"
                    iconSize: 18
                    color: root.colTextSecondary
                }
                StyledToolTip { text: TranslationService.tr("Save as playlist") }
            }

            RippleButton { 
                implicitWidth: 28
                implicitHeight: 28
                buttonRadius: 14
                colBackground: YTMusic.shuffleMode ? root.colPrimary : "transparent"
                colBackgroundHover: YTMusic.shuffleMode ? root.colPrimary : root.colLayer2Hover
                onClicked: YTMusic.toggleShuffle()
                contentItem: MaterialSymbol { 
                    anchors.centerIn: parent
                    text: "shuffle"
                    iconSize: 18
                    color: YTMusic.shuffleMode ? Appearance.colors.colOnPrimary : root.colTextSecondary 
                }
                StyledToolTip { text: YTMusic.shuffleMode ? TranslationService.tr("Shuffle On") : TranslationService.tr("Shuffle Off") }
            }
            
            RippleButton { 
                implicitWidth: 28
                implicitHeight: 28
                buttonRadius: 14
                colBackground: YTMusic.repeatMode > 0 ? root.colPrimary : "transparent"
                colBackgroundHover: YTMusic.repeatMode > 0 ? root.colPrimary : root.colLayer2Hover
                onClicked: YTMusic.cycleRepeatMode()
                contentItem: MaterialSymbol { 
                    anchors.centerIn: parent
                    text: YTMusic.repeatMode === 1 ? "repeat_one" : "repeat"
                    iconSize: 18
                    color: YTMusic.repeatMode > 0 ? Appearance.colors.colOnPrimary : root.colTextSecondary 
                }
                StyledToolTip { 
                    text: YTMusic.repeatMode === 0 ? TranslationService.tr("Repeat Off") 
                        : YTMusic.repeatMode === 1 ? TranslationService.tr("Repeat One") 
                        : TranslationService.tr("Repeat All") 
                }
            }
            
            RippleButton { 
                visible: root.hasQueue
                implicitWidth: 80
                implicitHeight: 28
                buttonRadius: root.radiusSmall
                colBackground: root.colPrimary
                onClicked: YTMusic.playQueue()
                contentItem: StyledText { 
                    anchors.centerIn: parent
                    text: TranslationService.tr("Play")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colOnPrimary 
                }
            }
            
            RippleButton { 
                visible: root.hasQueue
                implicitWidth: 28
                implicitHeight: 28
                buttonRadius: 14
                colBackground: "transparent"
                colBackgroundHover: root.colLayer2Hover
                onClicked: YTMusic.clearQueue()
                contentItem: MaterialSymbol { 
                    anchors.centerIn: parent
                    text: "delete_sweep"
                    iconSize: 18
                    color: root.colTextSecondary 
                }
                StyledToolTip { text: TranslationService.tr("Clear") }
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            reuseItems: true
            cacheBuffer: 200
            model: YTMusic.queue
            spacing: 4
            delegate: YTMusicTrackItem {
                required property var modelData
                required property int index
                width: ListView.view?.width ?? 200
                track: modelData
                trackIndex: index
                showIndex: true
                showRemoveButton: true
                showAddToQueue: false
                onPlayRequested: { 
                    YTMusic.queue = YTMusic.queue.slice(index)
                    YTMusic.playQueue() 
                }
                onRemoveRequested: YTMusic.removeFromQueue(index)
            }
            PagePlaceholder {
                anchors.fill: parent
                shown: !root.hasQueue
                icon: "queue_music"
                title: TranslationService.tr("Queue is empty")
                description: TranslationService.tr("Add songs from search or playlists")
            }
        }
    }

    // Connection Banner - compact inline banner for account sync
    component ConnectionBanner: Rectangle {
        id: banner

        property bool extraHidden: false
        readonly property bool dismissed: Config.options?.sidebar?.ytmusic?.hideSyncBanner ?? false
        readonly property bool shouldShow: !YTMusic.googleConnected && !dismissed && !extraHidden
        readonly property bool hasError: YTMusic.googleError !== "" && !YTMusic.googleChecking

        visible: (shouldShow || YTMusic.googleChecking) && !extraHidden
        implicitHeight: visible ? (hasError ? errorContent.implicitHeight + 24 : 52) : 0
        radius: root.radiusSmall
        color: hasError ? ColorUtils.transparentize(Appearance.colors.colError, 0.9)
             : YTMusic.googleChecking ? ColorUtils.transparentize(root.colPrimary, 0.9)
             : ColorUtils.transparentize(root.colPrimary, 0.92)
        border.width: root.borderWidth
        border.color: hasError ? ColorUtils.transparentize(Appearance.colors.colError, 0.7)
                    : ColorUtils.transparentize(root.colPrimary, 0.7)

        Behavior on implicitHeight {
            enabled: Appearance.animationsEnabled
            NumberAnimation { duration: 150 }
        }

        // Normal state - not connected, not checking
        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10
            visible: !banner.hasError && !YTMusic.googleChecking

            MaterialSymbol {
                text: "link"
                iconSize: 20
                color: root.colPrimary
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                StyledText {
                    text: TranslationService.tr("Sync your YouTube library")
                    font.pixelSize: Appearance.font.pixelSize.small
                    font.weight: Font.Medium
                    color: root.colText
                }
                StyledText {
                    text: TranslationService.tr("Access liked songs & playlists")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: root.colTextSecondary
                }
            }

            RippleButton {
                implicitWidth: 80
                implicitHeight: 28
                buttonRadius: 14
                colBackground: root.colPrimary
                onClicked: YTMusic.quickConnect()
                contentItem: StyledText {
                    anchors.centerIn: parent
                    text: TranslationService.tr("Connect")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    font.weight: Font.Medium
                    color: Appearance.colors.colOnPrimary
                }
            }

            RippleButton {
                implicitWidth: 24
                implicitHeight: 24
                buttonRadius: 12
                colBackground: "transparent"
                colBackgroundHover: ColorUtils.transparentize(root.colPrimary, 0.8)
                onClicked: Config.setNestedValue('sidebar.ytmusic.hideSyncBanner', true)
                contentItem: MaterialSymbol {
                    anchors.centerIn: parent
                    text: "close"
                    iconSize: 16
                    color: root.colTextSecondary
                }
                StyledToolTip { text: TranslationService.tr("Don't show again") }
            }
        }

        // Checking state
        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10
            visible: YTMusic.googleChecking

            MaterialLoadingIndicator {
                implicitSize: 20
                loading: visible
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                StyledText {
                    text: TranslationService.tr("Connecting...")
                    font.pixelSize: Appearance.font.pixelSize.small
                    font.weight: Font.Medium
                    color: root.colText
                }
                StyledText {
                    visible: YTMusic.googleBrowser
                    text: TranslationService.tr("Trying %1...").arg(YTMusic.getBrowserDisplayName(YTMusic.googleBrowser))
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: root.colPrimary
                }
            }

            RippleButton {
                implicitWidth: 70
                implicitHeight: 28
                buttonRadius: 14
                colBackground: root.colLayer2
                onClicked: { YTMusic.googleChecking = false; YTMusic.googleError = "" }
                contentItem: StyledText {
                    anchors.centerIn: parent
                    text: TranslationService.tr("Cancel")
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: root.colText
                }
            }
        }

        // Error state
        ColumnLayout {
            id: errorContent
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8
            visible: banner.hasError

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                MaterialSymbol { text: "error"; iconSize: 18; color: Appearance.colors.colError }
                StyledText {
                    Layout.fillWidth: true
                    text: YTMusic.googleError
                    font.pixelSize: Appearance.font.pixelSize.smaller
                    color: Appearance.colors.colOnErrorContainer
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 8

                RippleButton {
                    implicitWidth: 70
                    implicitHeight: 28
                    buttonRadius: 14
                    colBackground: Appearance.colors.colError
                    onClicked: YTMusic.quickConnect()
                    contentItem: StyledText {
                        anchors.centerIn: parent
                        text: TranslationService.tr("Retry")
                        font.pixelSize: Appearance.font.pixelSize.smaller
                        font.weight: Font.Medium
                        color: Appearance.colors.colOnError
                    }
                }

                RippleButton {
                    implicitWidth: 90
                    implicitHeight: 28
                    buttonRadius: 14
                    colBackground: ColorUtils.transparentize(Appearance.colors.colError, 0.8)
                    onClicked: YTMusic.openYtMusicInBrowser()
                    contentItem: RowLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        MaterialSymbol { text: "open_in_new"; iconSize: 14; color: Appearance.colors.colOnErrorContainer }
                        StyledText {
                            text: TranslationService.tr("Sign In")
                            font.pixelSize: Appearance.font.pixelSize.smaller
                            font.weight: Font.Medium
                            color: Appearance.colors.colOnErrorContainer
                        }
                    }
                }

                RippleButton {
                    implicitWidth: 28
                    implicitHeight: 28
                    buttonRadius: 14
                    colBackground: "transparent"
                    colBackgroundHover: ColorUtils.transparentize(Appearance.colors.colError, 0.7)
                    onClicked: advancedOptionsPopup.open()
                    contentItem: MaterialSymbol {
                        anchors.centerIn: parent
                        text: "settings"
                        iconSize: 16
                        color: Appearance.colors.colOnErrorContainer
                    }
                    StyledToolTip { text: TranslationService.tr("Advanced options") }
                }

                RippleButton {
                    implicitWidth: 28
                    implicitHeight: 28
                    buttonRadius: 14
                    colBackground: "transparent"
                    colBackgroundHover: ColorUtils.transparentize(Appearance.colors.colError, 0.7)
                    onClicked: { YTMusic.googleError = "" }
                    contentItem: MaterialSymbol {
                        anchors.centerIn: parent
                        text: "close"
                        iconSize: 16
                        color: Appearance.colors.colOnErrorContainer
                    }
                }
            }
        }
    }

    // Advanced Options Popup
}