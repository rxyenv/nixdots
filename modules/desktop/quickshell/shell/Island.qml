import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: bar
    anchors.top: true
    // Match hyprland gaps_out so the gap above the pill equals the gap
    // to the tiled windows below it
    margins.top: 20
    // Surface never resizes (resizing mid-animation smears frames);
    // the island morphs inside it and the mask keeps clicks passing
    // through everywhere else
    implicitWidth: 640
    implicitHeight: 500
    exclusiveZone: 42
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
                 ? (ShellState.osdVisible ? 280
                    : ShellState.hasNotifs ? 420
                    : pill.implicitWidth + 48)
             : ShellState.mode === "menu" ? 380
             : 600
        height: ShellState.mode === "clock"
                  ? (!ShellState.osdVisible && ShellState.hasNotifs
                      ? Math.min(toasts.implicitHeight + 24, 480)
                      : 42)
              : ShellState.mode === "menu"
                  ? Math.min(74 + ShellState.results.length * 46, 480)
                  : 480
        radius: ShellState.open || (ShellState.hasNotifs && !ShellState.osdVisible)
            ? 24 : height / 2
        color: "black"
        clip: true

        Behavior on width {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutQuint
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutQuint
            }
        }
        Behavior on radius {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutQuint
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            visible: !ShellState.open && !ShellState.hasNotifs
            onClicked: ShellState.openApps()
        }

        Pill {
            id: pill
            expanded: mouse.containsMouse
        }

        Osd {}

        Launcher {
            id: launcher
        }

        NotificationStack {
            id: toasts
        }
    }

    Connections {
        target: ShellState
        function onModeChanged() {
            if (ShellState.open)
                launcher.focusSearch();
        }
    }
}
