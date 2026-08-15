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

    onVisibleChanged: if (visible) {
        status.refresh()
        entrance.restart()
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.shell.closeSurfaces()
    }

    GlassPanel {
        id: card
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: root.palette.barHeight + 12
        anchors.rightMargin: 12
        width: Math.min(390, parent.width - 32)
        height: Math.min(540, parent.height - root.palette.barHeight - 28)
        radius: root.palette.radiusLarge
        strong: true

        MouseArea { anchors.fill: parent; acceptedButtons: Qt.NoButton }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 13

            RowLayout {
                Layout.fillWidth: true

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1
                    Text {
                        text: "Control center"
                        color: root.palette.foreground
                        font.family: root.palette.fontFamily
                        font.pixelSize: 17
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
                    Layout.preferredWidth: 42
                    Layout.preferredHeight: 38
                    icon: ""
                    compact: true
                    onClicked: root.shell.closeSurfaces()
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 9
                rowSpacing: 9

                GlassButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 70
                    icon: status.muted ? "󰝟" : ""
                    label: "Audio"
                    detail: status.muted ? "Muted" : status.volume
                    accent: !status.muted
                    onClicked: root.run("zen0x-launch-audio")
                }

                GlassButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 70
                    icon: status.wifiEnabled ? "󰖩" : "󰖪"
                    label: "Wi-Fi"
                    detail: status.wifi
                    checked: status.wifiEnabled
                    onClicked: root.run("zen0x-launch-wifi")
                }

                GlassButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 70
                    icon: status.bluetoothEnabled ? "󰂯" : "󰂲"
                    label: "Bluetooth"
                    detail: status.bluetooth
                    checked: status.bluetoothEnabled
                    onClicked: root.run("zen0x-launch-bluetooth")
                }

                GlassButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 70
                    icon: "󰖔"
                    label: "Night light"
                    detail: "Toggle warmth"
                    onClicked: root.run("zen0x-toggle-nightlight")
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
                Layout.preferredHeight: 54
                icon: shell.preferences.doNotDisturb ? "󰂛" : "󰂚"
                label: "Do not disturb"
                detail: shell.preferences.doNotDisturb ? "Notification popups hidden" : "Notification popups enabled"
                checked: shell.preferences.doNotDisturb
                onClicked: shell.preferences.doNotDisturb = !shell.preferences.doNotDisturb
            }

            GlassButton {
                Layout.fillWidth: true
                Layout.preferredHeight: 54
                icon: "󰆦"
                label: "Expressive motion"
                detail: shell.preferences.animationsEnabled ? "Springs and glass transitions" : "Reduced motion"
                checked: shell.preferences.animationsEnabled
                onClicked: shell.preferences.animationsEnabled = !shell.preferences.animationsEnabled
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: 9

                GlassButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    compact: true
                    icon: "󰍃"
                    label: "Notifications"
                    onClicked: shell.toggleSurface("notifications", root.modelData)
                }

                GlassButton {
                    Layout.preferredWidth: 52
                    Layout.preferredHeight: 48
                    compact: true
                    icon: ""
                    onClicked: root.run("zen0x-powermenu")
                }
            }
        }
    }

    SequentialAnimation {
        id: entrance
        PropertyAction { target: card; property: "opacity"; value: 0 }
        PropertyAction { target: card; property: "scale"; value: 0.96 }
        ParallelAnimation {
            NumberAnimation { target: card; property: "opacity"; to: 1; duration: root.shell.preferences.animationsEnabled ? 180 : 0 }
            NumberAnimation { target: card; property: "scale"; to: 1; duration: root.shell.preferences.animationsEnabled ? 320 : 0; easing.type: Easing.OutBack; easing.overshoot: 1.08 }
        }
    }
}
