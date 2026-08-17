import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    required property var modelData
    required property var shell

    readonly property Theme palette: Theme {}
    readonly property var actions: [
        { label: "Lock", icon: "󰌾", command: "hyprlock", tone: "normal" },
        { label: "Logout", icon: "󰍃", command: "hyprctl dispatch exit", tone: "normal" },
        { label: "Suspend", icon: "󰤄", command: "systemctl suspend", tone: "normal" },
        { label: "Shutdown", icon: "", command: "systemctl poweroff", tone: "danger" },
        { label: "Reboot", icon: "󰜉", command: "systemctl reboot", tone: "warning" }
    ]
    property int selectedIndex: 0
    property bool surfaceRequested: shell.surfaceVisible("session", modelData)

    function run(action) {
        shell.closeSurfaces()
        Quickshell.execDetached(["sh", "-lc", action.command])
    }

    screen: modelData
    visible: surfaceRequested
    color: palette.scrim
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    WlrLayershell.namespace: "abyssal-session-menu"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    onSurfaceRequestedChanged: {
        if (surfaceRequested) {
            selectedIndex = 0
            focusTimer.restart()
        }
    }

    Shortcut {
        sequence: "Escape"
        onActivated: root.shell.closeSurfaces()
    }

    FocusScope {
        id: keyboardScope
        anchors.fill: parent
        focus: true

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Down) {
                root.selectedIndex = Math.min(root.selectedIndex + 1, root.actions.length - 1)
                event.accepted = true
            } else if (event.key === Qt.Key_Up) {
                root.selectedIndex = Math.max(root.selectedIndex - 1, 0)
                event.accepted = true
            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                root.run(root.actions[root.selectedIndex])
                event.accepted = true
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.shell.closeSurfaces()
        }
    }

    GlassPanel {
        id: card
        opacity: 0.97
        anchors.centerIn: parent
        width: Math.min(360, parent.width - 16)
        height: 244
        radius: palette.radiusLarge
        strong: true

        MouseArea { anchors.fill: parent; acceptedButtons: Qt.NoButton }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 4

                Repeater {
                    model: root.actions

                    delegate: Rectangle {
                        required property var modelData
                        required property int index

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: root.palette.radius
                        color: index === root.selectedIndex || buttonMouse.containsMouse
                            ? modelData.tone === "danger" ? root.palette.dangerSoft
                            : modelData.tone === "warning" ? root.palette.warningSoft
                            : root.palette.accentSoft
                            : "transparent"
                        border.width: 0
                        border.color: modelData.tone === "danger" ? root.palette.danger
                            : modelData.tone === "warning" ? root.palette.warning
                            : root.palette.borderBright

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 8

                            Text {
                                Layout.preferredWidth: 24
                                text: modelData.icon
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: modelData.tone === "danger" ? root.palette.danger
                                    : modelData.tone === "warning" ? root.palette.warning
                                    : root.palette.foreground
                                font.family: root.palette.fontFamily
                                font.pixelSize: 16
                            }

                            Text {
                                Layout.fillWidth: true
                                text: modelData.label
                                horizontalAlignment: Text.AlignLeft
                                color: root.palette.foreground
                                font.family: root.palette.fontFamily
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                            }
                        }

                        MouseArea {
                            id: buttonMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.selectedIndex = index
                            onClicked: root.run(modelData)
                        }
                    }
                }
            }
        }
    }

    Timer {
        id: focusTimer
        interval: 25
        onTriggered: keyboardScope.forceActiveFocus()
    }

}
