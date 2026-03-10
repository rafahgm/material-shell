import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io

import qs.Services
import qs.Common
import qs.Common.Widgets
import qs.Common.Functions

MouseArea {
    id: root
    property int columns: 4
    property real previewCellAspectRatio: 4 / 3
    property bool useDarkMode: Appearance.m3colors.darkmode

    function updateThumbnails() {
        const totalImageMargin = (Appearance.sizes.wallpaperSelectorItemMargins + Appearance.sizes.wallpaperSelectorItemPadding) * 2
        const thumbnailSizeName = Images.thumbnailSizeNameForDimensions(grid.cellWidth - totalImageMargin, grid.cellHeight - totalImageMargin)
        WallpapersService.generateThumbnail(thumbnailSizeName)
    }

    Connections {
        target: WallpapersService
        function onDirectoryChanged() {
            root.updateThumbnails()
        }
    }

    function handleFilePasting(event) {
        const currentClipboardEntry = CliphistService.entries[0]
        if (/^\d+\tfile:\/\/\S+/.test(currentClipboardEntry)) {
            const url = StringUtils.cleanCliphistEntry(currentClipboardEntry);
            WallpapersService.setDirectory(FileUtils.trimFileProtocol(decodeURIComponent(url)));
            event.accepted = true;
        } else {
            event.accepted = false; // No image, let text pasting proceed
        }
    }

    function selectWallpaperPath(filePath) {
        if (filePath && filePath.length > 0) {
            WallpapersService.select(filePath, root.useDarkMode);
            filterField.text = "";
        }
    }

    acceptedButtons: Qt.BackButton | Qt.ForwardButton
    onPressed: event => {
        if (event.button === Qt.BackButton) {
            WallpapersService.navigateBack();
        } else if (event.button === Qt.ForwardButton) {
            WallpapersService.navigateForward();
        }
    }

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Escape) {
            GlobalStates.wallpaperSelectorOpen = false;
            event.accepted = true;
        } else if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_V) { // Intercept Ctrl+V to handle "paste to go to" in pickers
            root.handleFilePasting(event);
        } else if (event.modifiers & Qt.AltModifier && event.key === Qt.Key_Up) {
            WallpapersService.navigateUp();
            event.accepted = true;
        } else if (event.modifiers & Qt.AltModifier && event.key === Qt.Key_Left) {
            WallpapersService.navigateBack();
            event.accepted = true;
        } else if (event.modifiers & Qt.AltModifier && event.key === Qt.Key_Right) {
            WallpapersService.navigateForward();
            event.accepted = true;
        } else if (event.key === Qt.Key_Left) {
            grid.moveSelection(-1);
            event.accepted = true;
        } else if (event.key === Qt.Key_Right) {
            grid.moveSelection(1);
            event.accepted = true;
        } else if (event.key === Qt.Key_Up) {
            grid.moveSelection(-grid.columns);
            event.accepted = true;
        } else if (event.key === Qt.Key_Down) {
            grid.moveSelection(grid.columns);
            event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            grid.activateCurrent();
            event.accepted = true;
        } else if (event.key === Qt.Key_Backspace) {
            if (filterField.text.length > 0) {
                filterField.text = filterField.text.substring(0, filterField.text.length - 1);
            }
            filterField.forceActiveFocus();
            event.accepted = true;
        } else if (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_L) {
            addressBar.focusBreadcrumb();
            event.accepted = true;
        } else if (event.key === Qt.Key_Slash) {
            filterField.forceActiveFocus();
            event.accepted = true;
        } else {
            if (event.text.length > 0) {
                filterField.text += event.text;
                filterField.cursorPosition = filterField.text.length;
                filterField.forceActiveFocus();
            }
            event.accepted = true;
        }
    }

    implicitHeight: mainLayout.implicitHeight
    implicitWidth: mainLayout.implicitWidth

    StyledRectangularShadow {
        target: wallpaperGridBackground
    }
    Rectangle {
        id: wallpaperGridBackground
        anchors {
            fill: parent
            margins: Appearance.sizes.elevationMargin
        }
        focus: true
        border.width: 1
        border.color: Appearance.colors.colLayer0Border
        color: Appearance.colors.colLayer0
        radius: Appearance.rounding.screenRounding - Appearance.sizes.gapsOut + 1

        property int calculatedRows: Math.ceil(grid.count / grid.columns)

        implicitWidth: gridColumnLayout.implicitWidth
        implicitHeight: gridColumnLayout.implicitHeight

        RowLayout {
            id: mainLayout
            anchors.fill: parent
            spacing: -4

            Rectangle {
                Layout.fillHeight: true
                Layout.margins: 4
                implicitWidth: quickDirColumnLayout.implicitWidth
                implicitHeight: quickDirColumnLayout.implicitHeight
                color: Appearance.colors.colLayer1
                radius: wallpaperGridBackground.radius - Layout.margins

                ColumnLayout {
                    id: quickDirColumnLayout
                    anchors.fill: parent
                    spacing: 0

                    StyledText {
                        Layout.margins: 12
                        font {
                            pixelSize: Appearance.font.pixelSize.normal
                            weight: Font.Medium
                        }
                        text: TranslationService.tr("Pick a wallpaper")
                    }
                    ListView {
                        // Quick dirs
                        Layout.fillHeight: true
                        Layout.margins: 4
                        implicitWidth: 140
                        clip: true
                        model: [
                            { icon: "home", name: "Home", path: Directories.home }, 
                            { icon: "docs", name: "Documents", path: Directories.documents }, 
                            { icon: "download", name: "Downloads", path: Directories.downloads }, 
                            { icon: "image", name: "Pictures", path: Directories.pictures }, 
                            { icon: "movie", name: "Videos", path: Directories.videos }, 
                            { icon: "", name: "---", path: "INTENTIONALLY_INVALID_DIR" }, 
                            { icon: "wallpaper", name: "Wallpapers", path: `${Directories.pictures}/Wallpapers` }, 
                            ...(Config.options.policies.weeb === 1 ? [{ icon: "favorite", name: "Homework", path: `${Directories.pictures}/homework` }] : []),
                        ]
                        delegate: RippleButton {
                            id: quickDirButton
                            required property var modelData
                            anchors {
                                left: parent.left
                                right: parent.right
                            }
                            onClicked: WallpapersService.setDirectory(quickDirButton.modelData.path)
                            enabled: modelData.icon.length > 0
                            toggled: WallpapersService.directory === Qt.resolvedUrl(modelData.path)
                            colBackgroundToggled: Appearance.colors.colSecondaryContainer
                            colBackgroundToggledHover: Appearance.colors.colSecondaryContainerHover
                            colRippleToggled: Appearance.colors.colSecondaryContainerActive
                            buttonRadius: height / 2
                            implicitHeight: 38

                            contentItem: RowLayout {
                                MaterialSymbol {
                                    color: quickDirButton.toggled ? Appearance.colors.colOnSecondaryContainer : Appearance.colors.colOnLayer1
                                    iconSize: Appearance.font.pixelSize.larger
                                    text: quickDirButton.modelData.icon
                                    fill: quickDirButton.toggled ? 1 : 0
                                }
                                StyledText {
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignLeft
                                    color: quickDirButton.toggled ? Appearance.colors.colOnSecondaryContainer : Appearance.colors.colOnLayer1
                                    text: quickDirButton.modelData.name
                                }
                            }
                        }
                    }
                }
            }

            ColumnLayout {
                id: gridColumnLayout
                Layout.fillWidth: true
                Layout.fillHeight: true

                AddressBar {
                    id: addressBar
                    Layout.margins: 4
                    Layout.fillWidth: true
                    Layout.fillHeight: false
                    directory: WallpapersService.effectiveDirectory
                    onNavigateToDirectory: path => {
                        WallpapersService.setDirectory(path.length == 0 ? "/" : path);
                    }
                    radius: wallpaperGridBackground.radius - Layout.margins
                }

                Item {
                    id: gridDisplayRegion
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    StyledIndeterminateProgressBar {
                        id: indeterminateProgressBar
                        visible: WallpapersService.thumbnailGenerationRunning && value == 0
                        anchors {
                            bottom: parent.top
                            left: parent.left
                            right: parent.right
                            leftMargin: 4
                            rightMargin: 4
                        }
                    }

                    StyledProgressBar {
                        visible: WallpapersService.thumbnailGenerationRunning && value > 0
                        value: WallpapersService.thumbnailGenerationProgress
                        anchors.fill: indeterminateProgressBar
                    }

                    GridView {
                        id: grid
                        visible: WallpapersService.folderModel.count > 0

                        readonly property int columns: root.columns
                        readonly property int rows: Math.max(1, Math.ceil(count / columns))
                        property int currentIndex: 0

                        anchors.fill: parent
                        cellWidth: width / root.columns
                        cellHeight: cellWidth / root.previewCellAspectRatio
                        interactive: true
                        clip: true
                        keyNavigationWraps: true
                        boundsBehavior: Flickable.StopAtBounds
                        bottomMargin: extraOptions.implicitHeight
                        ScrollBar.vertical: StyledScrollBar {}

                        Component.onCompleted: {
                            root.updateThumbnails()
                        }

                        function moveSelection(delta) {
                            currentIndex = Math.max(0, Math.min(grid.model.count - 1, currentIndex + delta));
                            positionViewAtIndex(currentIndex, GridView.Contain);
                        }

                        function activateCurrent() {
                            const filePath = grid.model.get(currentIndex, "filePath")
                            root.selectWallpaperPath(filePath);
                        }

                        model: WallpapersService.folderModel
                        onModelChanged: currentIndex = 0
                        delegate: WallpaperDirectoryItem {
                            required property var modelData
                            required property int index
                            fileModelData: modelData
                            width: grid.cellWidth
                            height: grid.cellHeight
                            colBackground: (index === grid?.currentIndex || containsMouse) ? Appearance.colors.colPrimary : (fileModelData.filePath === Config.options.background.wallpaperPath) ? Appearance.colors.colSecondaryContainer : ColorUtils.transparentize(Appearance.colors.colPrimaryContainer)
                            colText: (index === grid.currentIndex || containsMouse) ? Appearance.colors.colOnPrimary : (fileModelData.filePath === Config.options.background.wallpaperPath) ? Appearance.colors.colOnSecondaryContainer : Appearance.colors.colOnLayer0

                            onEntered: {
                                grid.currentIndex = index;
                            }
                            
                            onActivated: {
                                root.selectWallpaperPath(fileModelData.filePath);
                            }
                        }

                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: gridDisplayRegion.width
                                height: gridDisplayRegion.height
                                radius: wallpaperGridBackground.radius
                            }
                        }
                    }

                    Toolbar {
                        id: extraOptions
                        anchors {
                            bottom: parent.bottom
                            horizontalCenter: parent.horizontalCenter
                            bottomMargin: 8
                        }

                        IconToolbarButton {
                            implicitWidth: height
                            onClicked: {
                                WallpapersService.openFallbackPicker(root.useDarkMode);
                                GlobalStates.wallpaperSelectorOpen = false;
                            }
                            altAction: () => {
                                WallpapersService.openFallbackPicker(root.useDarkMode);
                                GlobalStates.wallpaperSelectorOpen = false;
                                Config.options.wallpaperSelector.useSystemFileDialog = true
                            }
                            text: "open_in_new"
                            StyledToolTip {
                                text: TranslationService.tr("Use the system file picker instead\nRight-click to make this the default behavior")
                            }
                        }

                        IconToolbarButton {
                            implicitWidth: height
                            onClicked: {
                                WallpapersService.randomFromCurrentFolder();
                            }
                            text: "ifl"
                            StyledToolTip {
                                text: TranslationService.tr("Pick random from this folder")
                            }
                        }

                        IconToolbarButton {
                            implicitWidth: height
                            onClicked: root.useDarkMode = !root.useDarkMode
                            text: root.useDarkMode ? "dark_mode" : "light_mode"
                            StyledToolTip {
                                text: TranslationService.tr("Click to toggle light/dark mode\n(applied when wallpaper is chosen)")
                            }
                        }

                        ToolbarTextField {
                            id: filterField
                            placeholderText: focus ? TranslationService.tr("Search wallpapers") : TranslationService.tr("Hit \"/\" to search")

                            // Style
                            clip: true
                            font.pixelSize: Appearance.font.pixelSize.small

                            // Search
                            onTextChanged: {
                                WallpapersService.searchQuery = text;
                            }

                            Keys.onPressed: event => {
                                if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_V) { // Intercept Ctrl+V to handle "paste to go to" in pickers
                                    root.handleFilePasting(event);
                                    return;
                                }
                                else if (text.length !== 0) {
                                    // No filtering, just navigate grid
                                    if (event.key === Qt.Key_Down) {
                                        grid.moveSelection(grid.columns);
                                        event.accepted = true;
                                        return;
                                    }
                                    if (event.key === Qt.Key_Up) {
                                        grid.moveSelection(-grid.columns);
                                        event.accepted = true;
                                        return;
                                    }
                                }
                                event.accepted = false;
                            }
                        }

                        IconToolbarButton {
                            implicitWidth: height
                            onClicked: {
                                GlobalStates.wallpaperSelectorOpen = false;
                            }
                            text: "close"
                            StyledToolTip {
                                text: TranslationService.tr("Cancel wallpaper selection")
                            }
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: GlobalStates
        function onWallpaperSelectorOpenChanged() {
            if (GlobalStates.wallpaperSelectorOpen && monitorIsFocused) {
                filterField.forceActiveFocus();
            }
        }
    }

    Connections {
        target: WallpapersService
        function onChanged() {
            GlobalStates.wallpaperSelectorOpen = false;
        }
    }
}