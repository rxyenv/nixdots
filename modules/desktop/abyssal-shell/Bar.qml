import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    required property var modelData
    required property var shell

    readonly property Theme palette: Theme {}
    readonly property var status: shell.systemStatus
    readonly property SystemClock clock: SystemClock { precision: SystemClock.Minutes }

    screen: modelData
    implicitHeight: palette.barHeight
    color: "transparent"
    exclusiveZone: implicitHeight
    anchors { top: true; left: true; right: true }
    WlrLayershell.namespace: "abyssal-bar"

    Rectangle {
        anchors.fill: parent
        anchors.margins: 7
        radius: 12
        color: Qt.rgba(0.063, 0.129, 0.153, 0.65)
        border.width: 1
        border.color: root.palette.border

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 8

            Row {
                id: workspaces
                spacing: 4

                Repeater {
                    model: Hyprland.workspaces.values.filter(workspace => workspace.id > 0 && workspace.id <= 10)

                    delegate: Rectangle {
                        id: workspace
                        required property var modelData

                        width: modelData.focused ? 32 : 27
                        height: 30
                        radius: 8
                        color: modelData.focused ? root.palette.accent
                            : modelData.urgent ? root.palette.danger
                            : modelData.active ? root.palette.accentSoft
                            : workspaceMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.07)
                            : "transparent"
                        Behavior on width { NumberAnimation { duration: root.palette.duration; easing.type: Easing.OutBack } }
                        Behavior on color { ColorAnimation { duration: root.palette.durationFast } }

                        Text {
                            anchors.centerIn: parent
                            text: workspace.modelData.id
                            color: workspace.modelData.focused ? root.palette.background : root.palette.foreground
                            font.family: root.palette.fontFamily
                            font.pixelSize: 12
                            font.bold: workspace.modelData.focused
                        }

                        MouseArea {
                            id: workspaceMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: workspace.modelData.activate()
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
            }

            Item {
                id: tray
                property bool expanded: false
                Layout.preferredWidth: expanded ? trayIcons.implicitWidth + 28 : 28
                Layout.preferredHeight: 36

                Row {
                    id: trayIcons
                    anchors.left: parent.left
                    anchors.leftMargin: 2
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8
                    visible: tray.expanded

                    Repeater {
                        model: SystemTray.items.values

                        delegate: Item {
                            required property var modelData
                            width: 20
                            height: 28

                            Image {
                                anchors.centerIn: parent
                                width: 16
                                height: 16
                                source: modelData.icon
                                sourceSize: Qt.size(16, 16)
                                smooth: true
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: modelData.activate()
                                onPressed: mouse => {
                                    if (mouse.button === Qt.RightButton) modelData.secondaryActivate()
                                }
                            }
                        }
                    }
                }

                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    text: tray.expanded ? "" : ""
                    color: root.palette.muted
                    font.family: root.palette.fontFamily
                    font.pixelSize: 13
                }

                MouseArea {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 28
                    onClicked: tray.expanded = !tray.expanded
                }
            }

            Item {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 36

                Text {
                    anchors.centerIn: parent
                    text: root.status.wifiEnabled ? "" : "󰖪"
                    color: root.palette.foreground
                    font.family: root.palette.fontFamily
                    font.pixelSize: 14
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.shell.toggleSurface("control", root.modelData)
                }
            }

            Item {
                Layout.preferredWidth: 28
                Layout.preferredHeight: 36

                Text {
                    id: volumeText
                    anchors.centerIn: parent
                    text: root.status.muted ? "" : ""
                    color: root.palette.foreground
                    font.family: root.palette.fontFamily
                    font.pixelSize: 14
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.shell.toggleSurface("control", root.modelData)
                    onWheel: wheel => {
                        const step = wheel.angleDelta.y > 0 ? "5%+" : "5%-"
                        Quickshell.execDetached([
                            "sh", "-c",
                            "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ " + step
                                + " && qs -p \"$HOME/.config/quickshell/abyssal\" ipc call osd volume"
                        ])
                        volumeRefresh.restart()
                        wheel.accepted = true
                    }
                }

                Timer {
                    id: volumeRefresh
                    interval: 180
                    onTriggered: root.status.refresh()
                }
            }

        }

        Item {
            id: clock
            anchors.centerIn: parent
            width: clockText.implicitWidth + 20
            height: 36

            Text {
                id: clockText
                anchors.centerIn: parent
                text: Qt.formatDateTime(root.clock.date, "hh:mm AP  ·  ddd, MMM d")
                color: root.palette.foreground
                font.family: root.palette.fontFamily
                font.pixelSize: 13
                font.weight: Font.Bold
            }

            MouseArea {
                id: clockMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.shell.toggleSurface("notifications", root.modelData)
            }
        }
    }
}
