import Quickshell
import Quickshell.Hyprland
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

    GlassPanel {
        anchors.fill: parent
        anchors.margins: 5
        radius: 14
        elevated: true

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 8

            GlassButton {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 30
                icon: "󰣇"
                compact: true
                accent: true
                bordered: false
                onClicked: root.shell.toggleSurface("launcher", root.modelData)
            }

            Row {
                id: workspaces
                spacing: 4

                Repeater {
                    model: Hyprland.workspaces.values.filter(workspace => workspace.id > 0 && workspace.id <= 10)

                    delegate: Rectangle {
                        id: workspace
                        required property var modelData

                        width: modelData.focused ? 28 : 23
                        height: 24
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
                            font.pixelSize: 10
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
                Layout.preferredHeight: 30

                Rectangle {
                    anchors.centerIn: parent
                    width: Math.min(title.implicitWidth + 28, parent.width - 10)
                    height: 26
                    radius: 10
                    color: Qt.rgba(1, 1, 1, titleMouse.containsMouse ? 0.065 : 0.035)
                    Text {
                        id: title
                        anchors.centerIn: parent
                        width: Math.min(implicitWidth, parent.width - 20)
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                        text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : "Abyssal"
                        color: root.palette.muted
                        font.family: root.palette.fontFamily
                        font.pixelSize: 10
                    }

                    MouseArea {
                        id: titleMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.shell.toggleSurface("launcher", root.modelData)
                    }
                }
            }

            Rectangle {
                visible: root.status.battery.length > 0
                Layout.preferredWidth: batteryText.implicitWidth + 16
                Layout.preferredHeight: 28
                radius: 10
                color: Qt.rgba(1, 1, 1, 0.04)
                Text {
                    id: batteryText
                    anchors.centerIn: parent
                    text: "󰁹 " + root.status.battery
                    color: root.palette.foreground
                    font.family: root.palette.fontFamily
                    font.pixelSize: 10
                }
            }

            GlassButton {
                Layout.preferredWidth: statusText.implicitWidth + 24
                Layout.preferredHeight: 30
                compact: true
                bordered: false
                onClicked: root.shell.toggleSurface("control", root.modelData)

                Text {
                    id: statusText
                    anchors.centerIn: parent
                    text: (root.status.wifiEnabled ? "󰖩" : "󰖪") + "  "
                        + (root.status.bluetoothEnabled ? "󰂯" : "󰂲") + "  "
                        + (root.status.muted ? "󰝟" : "") + " " + root.status.volume
                    color: root.palette.foreground
                    font.family: root.palette.fontFamily
                    font.pixelSize: 11
                }
            }

            GlassButton {
                Layout.preferredWidth: 35
                Layout.preferredHeight: 30
                icon: root.shell.notificationServer.trackedNotifications.values.length > 0 ? "󰂚" : "󰂜"
                compact: true
                bordered: false
                checked: root.shell.activeSurface === "notifications"
                onClicked: root.shell.toggleSurface("notifications", root.modelData)
            }

            Rectangle {
                Layout.preferredWidth: clockText.implicitWidth + 20
                Layout.preferredHeight: 30
                radius: 10
                color: clockMouse.containsMouse ? root.palette.accentSoft : Qt.rgba(1, 1, 1, 0.04)
                Text {
                    id: clockText
                    anchors.centerIn: parent
                    text: Qt.formatDateTime(root.clock.date, "ddd  d MMM  HH:mm")
                    color: root.palette.foreground
                    font.family: root.palette.fontFamily
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
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
}
