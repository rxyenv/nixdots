import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    required property var modelData
    required property var shell

    readonly property Theme palette: Theme {}
    readonly property var status: shell.systemStatus

    function run(command) {
        shell.closeSurfaces()
        Quickshell.execDetached(["sh", "-lc", command])
    }

    screen: modelData
    visible: shell.surfaceVisible("control", modelData)
    color: palette.scrim
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    WlrLayershell.namespace: "abyssal-control-center"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    Shortcut {
        sequence: "Escape"
        onActivated: root.shell.closeSurfaces()
    }

    onVisibleChanged: if (visible) status.refresh()

    MouseArea {
        anchors.fill: parent
        onClicked: root.shell.closeSurfaces()
    }

    GlassPanel {
        id: card
        opacity: 0.97
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: root.palette.barHeight + 4
        anchors.rightMargin: 4
        width: Math.min(340, parent.width - 16)
        height: Math.min(390, parent.height - root.palette.barHeight - 12)
        radius: root.palette.radiusLarge
        strong: true

        MouseArea { anchors.fill: parent; acceptedButtons: Qt.NoButton }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1
                    Text {
                        text: "Control center"
                        color: root.palette.foreground
                        font.family: root.palette.fontFamily
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                    }
                    Text {
                        text: Qt.formatDateTime(new Date(), "dddd, d MMMM")
                        color: root.palette.muted
                        font.family: root.palette.fontFamily
                        font.pixelSize: 10
                    }
                }

                GlassButton {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 30
                    icon: ""
                    compact: true
                    onClicked: root.shell.closeSurfaces()
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 6
                rowSpacing: 6

                GlassButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    icon: status.muted ? "󰝟" : ""
                    label: "Audio"
                    detail: status.muted ? "Muted" : status.volume
                    accent: !status.muted
                    onClicked: root.run("zen0x-launch-audio")
                }

                GlassButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    icon: status.wifiEnabled ? "󰖩" : "󰖪"
                    label: "Wi-Fi"
                    detail: status.wifi
                    checked: status.wifiEnabled
                    onClicked: root.run("zen0x-launch-wifi")
                }

                GlassButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    icon: status.bluetoothEnabled ? "󰂯" : "󰂲"
                    label: "Bluetooth"
                    detail: status.bluetooth
                    checked: status.bluetoothEnabled
                    onClicked: root.run("zen0x-launch-bluetooth")
                }

            }

            Rectangle { Layout.fillWidth: true; height: 1; color: root.palette.border }

            Text {
                text: "SHELL"
                color: root.palette.subtle
                font.family: root.palette.fontFamily
                font.pixelSize: 9
                font.letterSpacing: 1.6
            }

            GlassButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 42
                icon: shell.preferences.doNotDisturb ? "󰂛" : "󰂚"
                label: "Do not disturb"
                detail: shell.preferences.doNotDisturb ? "Notification popups hidden" : "Notification popups enabled"
                checked: shell.preferences.doNotDisturb
                onClicked: shell.preferences.doNotDisturb = !shell.preferences.doNotDisturb
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                GlassButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    compact: true
                    icon: "󰍃"
                    label: "Notifications"
                    onClicked: shell.toggleSurface("notifications", root.modelData)
                }

                GlassButton {
                    Layout.preferredWidth: 42
                    Layout.preferredHeight: 38
                    compact: true
                    icon: ""
                    onClicked: shell.toggleSurface("session", root.modelData)
                }
            }
        }
    }

}
