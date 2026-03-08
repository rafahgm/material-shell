//@ pragma UseQApplication
//@ pragma Env QS_NO_RELOAD_POPUP=1
//@ pragma Env QT_LOGGING_RULES=quickshell.dbus.properties=false
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
//@ pragma Env QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000
//@ pragma Env QT_SCALE_FACTOR=1

import QtQuick
import Quickshell
import Quickshell.Io

import qs.Services
import qs.Modules
import qs.Modules.Common
// import qs.Modules.AltSwitcher
import qs.Modules.CloseConfirm
// import qs.Modules.Settings

ShellRoot {
    id: root

    function _log(msg: string): void {
        if (Quickshell.env("QS_DEBUG") === "1")
            console.log(msg);
    }

    // Force singleton instantiation
    // property var _idleService: Idle
    // property var _windowPreviewService: WindowPreviewService
    property var _weatherService: WeatherService
    // property var _powerProfilePersistence: PowerProfilePersistence
    // property var _voiceSearchService: VoiceSearch
    // property var _fontSyncService: FontSyncService

    Component.onCompleted: {
        root._log("[Shell] Initializing singletons");
        // Hyprsunset.load();
        // FirstRunExperience.load();
        // ConflictKiller.load();
    }

    Connections {
        target: Config
        function onReadyChanged() {
            if (Config.ready) {
                root._log("[Shell] Config ready, applying theme");
                // Qt.callLater(() => ThemeService.applyCurrentTheme());
                // Qt.callLater(() => IconThemeService.ensureInitialized());
                // // Only reset enabledPanels if it's empty or undefined (first run / corrupted config)
                // if (!Config.options?.enabledPanels || Config.options.enabledPanels.length === 0) {
                //     const family = Config.options?.panelFamily ?? "ii"
                //     if (root.families.includes(family)) {
                //         Config.options.enabledPanels = root.panelFamilies[family]
                //     }
                // }
            }
        }
    }

    // IPC for settings - overlay mode or separate window based on config
    // Note: waffle family ALWAYS uses its own window (waffleSettings.qml), never the Material overlay
    // IpcHandler {
    //     target: "settings"
    //     function open(): void {
    //         const isWaffle = Config.options?.panelFamily === "waffle"
    //             && Config.options?.waffles?.settings?.useMaterialStyle !== true

    //         if (isWaffle) {
    //             // Waffle always opens its own Win11-style settings window
    //             Quickshell.execDetached(["/usr/bin/qs", "-n", "-p",
    //                 Quickshell.shellPath("waffleSettings.qml")])
    //         } else if (Config.options?.settingsUi?.overlayMode ?? false) {
    //             // ii overlay mode — toggle inline panel
    //             GlobalStates.settingsOverlayOpen = !GlobalStates.settingsOverlayOpen
    //         } else {
    //             // ii window mode (default) — launch separate process
    //             Quickshell.execDetached(["/usr/bin/qs", "-n", "-p",
    //                 Quickshell.shellPath("settings.qml")])
    //         }
    //     }
    //     function toggle(): void {
    //         open()
    //     }
    // }

    // Settings overlay panel (loaded only when overlay mode is enabled)
    // LazyLoader {
    //     active: Config.ready && (Config.options?.settingsUi?.overlayMode ?? false)
    //     component: SettingsOverlay {}
    // }

    // === Panel Loaders ===
    // AltSwitcher IPC router (material/waffle)
    // LazyLoader { active: Config.ready; component: AltSwitcher {} }

    // Load ONLY the active family panels to reduce startup time.
    LazyLoader {
        active: Config.ready && (Config.options?.panelFamily ?? "linux") !== "windows"
        component: LinuxPanels {}
    }

    // LazyLoader {
    //     active: Config.ready && (Config.options?.panelFamily ?? "linux") === "windows"
    //     component: WindowsPanels {}
    // }

    // Close confirmation dialog (always loaded, handles IPC)
    LazyLoader {
        active: Config.ready
        component: CloseConfirm {}
    }

    // Shared (always loaded via ToastManager)
    ToastManager {}

    // === Panel Families ===
    // Note: iiAltSwitcher is always loaded (not in families) as it acts as IPC router
    // for the unified "altSwitcher" target, redirecting to wAltSwitcher when waffle is active
    property list<string> families: ["linux", "windows"]
    property var panelFamilies: ({
            "linux": ["linuxBar","linuxBackground", "linuxNotificationPopup", "linuxWallpaperSelector"],
            "windows": ["windowsBar"]
        })

    // === Panel Family Transition ===
    property string _pendingFamily: ""
    property bool _transitionInProgress: false

    function _ensureFamilyPanels(family: string): void {
        const basePanels = root.panelFamilies[family] ?? [];
        const currentPanels = Config.options?.enabledPanels ?? [];

        if (basePanels.length === 0)
            return;
        if (currentPanels.length === 0) {
            Config.options.enabledPanels = [...basePanels];
            return;
        }

        const merged = [...currentPanels];
        for (const panel of basePanels) {
            if (!merged.includes(panel))
                merged.push(panel);
        }
        Config.options.enabledPanels = merged;
    }

    function cyclePanelFamily() {
        const currentFamily = Config.options?.panelFamily ?? "ii";
        const currentIndex = families.indexOf(currentFamily);
        const nextIndex = (currentIndex + 1) % families.length;
        const nextFamily = families[nextIndex];

        // Determine direction: ii -> waffle = left, waffle -> ii = right
        const direction = nextIndex > currentIndex ? "left" : "right";
        root.startFamilyTransition(nextFamily, direction);
    }

    function setPanelFamily(family: string) {
        const currentFamily = Config.options?.panelFamily ?? "ii";
        if (families.includes(family) && family !== currentFamily) {
            const currentIndex = families.indexOf(currentFamily);
            const nextIndex = families.indexOf(family);
            const direction = nextIndex > currentIndex ? "left" : "right";
            root.startFamilyTransition(family, direction);
        }
    }

    function startFamilyTransition(targetFamily: string, direction: string) {
        if (_transitionInProgress)
            return;

        // If animation is disabled, switch instantly
        if (!(Config.options?.familyTransitionAnimation ?? true)) {
            Config.options.panelFamily = targetFamily;
            root._ensureFamilyPanels(targetFamily);
            return;
        }

        _transitionInProgress = true;
        _pendingFamily = targetFamily;
        GlobalStates.familyTransitionDirection = direction;
        GlobalStates.familyTransitionActive = true;
    }

    function applyPendingFamily() {
        if (_pendingFamily && families.includes(_pendingFamily)) {
            Config.options.panelFamily = _pendingFamily;
            root._ensureFamilyPanels(_pendingFamily);
        }
        _pendingFamily = "";
    }

    function finishFamilyTransition() {
        _transitionInProgress = false;
        GlobalStates.familyTransitionActive = false;
    }

    // Family transition overlay
    // FamilyTransitionOverlay {
    //     onExitComplete: root.applyPendingFamily()
    //     onEnterComplete: root.finishFamilyTransition()
    // }

    IpcHandler {
        target: "panelFamily"
        function cycle(): void {
            root.cyclePanelFamily();
        }
        function set(family: string): void {
            root.setPanelFamily(family);
        }
    }
}
