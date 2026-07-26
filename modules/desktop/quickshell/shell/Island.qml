import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: bar
    anchors.top: true
    margins.top: Config.topMargin
    // Surface never resizes (resizing mid-animation smears frames);
    // the island morphs inside it and the mask keeps clicks passing
    // through everywhere else
    implicitWidth: 640
    implicitHeight: 500
    exclusiveZone: Config.topMargin + 20
    color: "transparent"

    WlrLayershell.keyboardFocus: ShellState.open
        ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    mask: Region {
        item: island
    }

    Rectangle {
        id: island
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: ShellState.mode === "clock"
                 ? (ShellState.osdVisible ? Config.osdWidth
                    : ShellState.hasNotifs ? Config.notifWidth
                    : pill.implicitWidth + 48)
             : ShellState.mode === "menu"    ? Config.menuWidth
             : ShellState.mode === "control" ? Config.controlWidth
             : Config.launcherWidth
        height: ShellState.mode === "clock"
                  ? (!ShellState.osdVisible && ShellState.hasNotifs
                      ? Math.min(toasts.implicitHeight + 24, 480)
                      : Config.pillHeight)
              : ShellState.mode === "menu"
                  ? Math.min(74 + ShellState.results.length * 46, 480)
              : ShellState.mode === "control" ? 460
              : 480
        radius: ShellState.open || (ShellState.hasNotifs && !ShellState.osdVisible)
            ? 24 : Config.pillHeight / 2
        color: Config.islandColor
        clip: true

        Behavior on width {
            NumberAnimation {
                duration: Config.animDuration
                easing.type: Easing.OutQuint
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: Config.animDuration
                easing.type: Easing.OutQuint
            }
        }
        Behavior on radius {
            NumberAnimation {
                duration: Config.animDuration
                easing.type: Easing.OutQuint
            }
        }

        MouseArea {
            id: pillMouse
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            visible: !ShellState.open && !ShellState.hasNotifs
            onClicked: {
                if (mouse.button === Qt.RightButton)
                    ShellState.openControl()
                else
                    ShellState.openApps()
            }
        }

        Pill {
            id: pill
            expanded: pillMouse.containsMouse
        }

        Osd {}

        Launcher {
            id: launcher
        }

        NotificationStack {
            id: toasts
        }

        Settings {}

        ControlCenter {}
    }

    Keys.onEscapePressed: if (ShellState.open) ShellState.closeIsland()

    Connections {
        target: ShellState
        function onModeChanged() {
            if (ShellState.mode === "apps" || ShellState.mode === "menu")
                launcher.focusSearch();
        }
    }
}
