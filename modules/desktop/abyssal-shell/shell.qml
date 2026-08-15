//@ pragma StateDir $BASE/abyssal-shell
//@ pragma CacheDir $BASE/abyssal-shell

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Notifications
import QtQuick

ShellRoot {
    id: root

    property string activeSurface: ""
    property var activeScreen: null
    property var toastNotifications: []

    readonly property alias preferences: preferencesObject
    readonly property alias systemStatus: systemStatusObject
    readonly property alias notificationServer: notificationServerObject

    function isPrimaryScreen(screen) {
        return Quickshell.screens.length === 0 || screen === Quickshell.screens[0]
    }

    function isFocusedScreen(screen) {
        const monitor = Hyprland.monitorFor(screen)
        return !Hyprland.focusedMonitor || !monitor || monitor.name === Hyprland.focusedMonitor.name
    }

    function surfaceVisible(name, screen) {
        if (activeSurface !== name) return false
        return activeScreen ? activeScreen === screen : isFocusedScreen(screen)
    }

    function toggleSurface(name, screen) {
        if (activeSurface === name && (!screen || activeScreen === screen)) {
            closeSurfaces()
            return
        }
        activeScreen = screen || null
        activeSurface = name
    }

    function closeSurfaces() {
        activeSurface = ""
        activeScreen = null
    }

    function hideToast(notification) {
        toastNotifications = toastNotifications.filter(item => item !== notification)
    }

    PersistentProperties {
        id: preferencesObject
        property bool doNotDisturb: false
        property bool animationsEnabled: true
    }

    SystemStatus { id: systemStatusObject }
    OsdWindow { shell: root }

    NotificationServer {
        id: notificationServerObject
        keepOnReload: true
        persistenceSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: notification => {
            notification.tracked = true
            root.toastNotifications = [notification].concat(root.toastNotifications.filter(item => item !== notification)).slice(0, 6)
        }
    }

    IpcHandler {
        target: "shell"

        function toggleLauncher() { root.toggleSurface("launcher", null) }
        function toggleControlCenter() { root.toggleSurface("control", null) }
        function toggleWallpaper() { root.toggleSurface("wallpaper", null) }
        function toggleNotifications() { root.toggleSurface("notifications", null) }
        function close() { root.closeSurfaces() }
    }

    Variants {
        model: Quickshell.screens
        delegate: Bar { shell: root }
    }

    Variants {
        model: Quickshell.screens
        delegate: LauncherWindow { shell: root }
    }

    Variants {
        model: Quickshell.screens
        delegate: ControlCenterWindow { shell: root }
    }

    Variants {
        model: Quickshell.screens
        delegate: WallpaperSwitcherWindow { shell: root }
    }

    Variants {
        model: Quickshell.screens
        delegate: NotificationCenterWindow {
            shell: root
            notificationServer: notificationServerObject
        }
    }

    Variants {
        model: Quickshell.screens
        delegate: NotificationToasts { shell: root }
    }
}
