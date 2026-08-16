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

    function run(action) {
        shell.closeSurfaces()
        Quickshell.execDetached(["sh", "-lc", action.command])
    }

    screen: modelData
    visible: shell.surfaceVisible("session", modelData)
    color: palette.scrim
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    WlrLayershell.namespace: "abyssal-session-menu"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    Shortcut {
        sequence: "Escape"
        onActivated: root.shell.closeSurfaces()
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.shell.closeSurfaces()
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

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: "Session"
                    color: root.palette.foreground
                    font.family: root.palette.fontFamily
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                }

                Text {
                    text: "ESC to close"
                    color: root.palette.subtle
                    font.family: root.palette.fontFamily
                    font.pixelSize: 9
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 4

                Repeater {
                    model: root.actions

                    delegate: Rectangle {
                        required property var modelData

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: root.palette.radius
                        color: buttonMouse.containsMouse
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
                            onClicked: root.run(modelData)
                        }
                    }
                }
            }
        }
    }

}
