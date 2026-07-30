import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Item {
    id: wsContainer
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.leftMargin: 16
    width: wsRow.implicitWidth
    height: Config.pillHeight
    opacity: !ShellState.open && !ShellState.hasNotifs && !ShellState.osdVisible ? 1 : 0
    visible: opacity > 0

    Behavior on opacity { NumberAnimation { duration: 150 } }

    readonly property var sorted: {
        const ws = Hyprland.workspaces.values.slice();
        ws.sort((a, b) => a.id - b.id);
        return ws;
    }

    RowLayout {
        id: wsRow
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: wsContainer.sorted

            delegate: Rectangle {
                required property var modelData

                readonly property bool active: modelData.id === (Hyprland.focusedMonitor?.activeWorkspace?.id ?? -1)
                readonly property bool occupied: modelData.windows > 0

                width: active ? 20 : (occupied ? 8 : 6)
                height: 6
                radius: 3
                color: active ? Theme.c("accent", "#89b4fa") : Theme.c("muted", "#6c7086")
                opacity: active ? 1 : (occupied ? 0.6 : 0.3)

                Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }
        }
    }
}
