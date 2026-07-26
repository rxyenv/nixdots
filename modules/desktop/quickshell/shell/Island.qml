import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

PanelWindow {
    id: bar
    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 500
    exclusiveZone: Config.pillHeight
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
        width: parent.width * 0.75
        height: ShellState.mode === "clock"
                  ? (!ShellState.osdVisible && ShellState.hasNotifs
                      ? Math.min(toasts.implicitHeight + Config.pillHeight + 8, 480)
                      : Config.pillHeight)
              : ShellState.mode === "menu"
                  ? Math.min(Config.pillHeight + 74 + ShellState.results.length * 46, 480)
              : ShellState.mode === "control" ? 460 + Config.pillHeight
              : 480 + Config.pillHeight
        radius: 18
        color: Theme.c("panel", "#1e1e2e")
        clip: true

        Behavior on height {
            NumberAnimation {
                duration: Config.animDuration
                easing.type: Easing.OutQuint
            }
        }

        MouseArea {
            id: pillMouse
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: Config.pillHeight
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

        Workspaces {}

        Pill {
            id: pill
            expanded: pillMouse.containsMouse
        }

        Osd {}

        Rectangle {
            anchors.top: parent.top
            anchors.topMargin: Config.pillHeight
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: Theme.c("border", "#313244")
            opacity: ShellState.open ? 0.5 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }

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
