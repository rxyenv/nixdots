import QtQuick
import QtQuick.Shapes
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

    readonly property int islandWidth: {
        if (ShellState.mode === "apps" || ShellState.mode === "menu")
            return Math.min(bar.width * 0.55, 680)
        if (ShellState.mode === "control" || ShellState.mode === "settings")
            return 420
        if (ShellState.osdVisible)
            return Config.osdWidth
        if (ShellState.hasNotifs)
            return Config.notifWidth
        return 200
    }

    Item {
        id: island
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: bar.islandWidth
        height: ShellState.mode === "clock"
                  ? (!ShellState.osdVisible && ShellState.hasNotifs
                      ? Math.min(toasts.implicitHeight + Config.pillHeight + 8, 480)
                      : Config.pillHeight)
              : ShellState.mode === "menu"
                  ? Math.min(Config.pillHeight + 74 + ShellState.results.length * 46, 480)
              : ShellState.mode === "control" ? 460 + Config.pillHeight
              : 480 + Config.pillHeight
        clip: true

        Behavior on width {
            NumberAnimation {
                duration: Config.animDuration
                easing.type: Easing.OutExpo
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: Config.animDuration
                easing.type: Easing.OutQuint
            }
        }

        Shape {
            anchors.fill: parent
            layer.enabled: true
            layer.samples: 8

            ShapePath {
                id: sp
                fillColor: Config.islandColor
                strokeColor: "transparent"
                strokeWidth: 0

                readonly property real cr: 16  // concave notch radius at top corners
                readonly property real br: 22  // convex rounding radius at bottom corners

                startX: sp.cr; startY: 0

                PathLine { x: island.width - sp.cr; y: 0 }

                // top-right: concave notch (CCW = center at corner vertex, scoops inward)
                PathArc  { x: island.width; y: sp.cr
                           radiusX: sp.cr; radiusY: sp.cr
                           direction: PathArc.Counterclockwise }

                PathLine { x: island.width; y: island.height - sp.br }

                // bottom-right: convex rounding
                PathArc  { x: island.width - sp.br; y: island.height
                           radiusX: sp.br; radiusY: sp.br
                           direction: PathArc.Clockwise }

                PathLine { x: sp.br; y: island.height }

                // bottom-left: convex rounding
                PathArc  { x: 0; y: island.height - sp.br
                           radiusX: sp.br; radiusY: sp.br
                           direction: PathArc.Clockwise }

                PathLine { x: 0; y: sp.cr }

                // top-left: concave notch (CCW = center at corner vertex, scoops inward)
                PathArc  { x: sp.cr; y: 0
                           radiusX: sp.cr; radiusY: sp.cr
                           direction: PathArc.Counterclockwise }
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
            color: Qt.alpha("#ffffff", 0.08)
            opacity: ShellState.open ? 1 : 0
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
