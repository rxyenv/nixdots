import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: cc
    anchors.fill: parent

    opacity: ShellState.mode === "control" ? 1 : 0
    visible: opacity > 0
    enabled: ShellState.mode === "control"

    Behavior on opacity {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    property bool wifiEnabled:      true
    property bool bluetoothEnabled: false
    property bool airplaneEnabled:  false
    property int  volume:           50
    property bool volumeMuted:      false
    property int  brightness:       50

    focus: ShellState.mode === "control"

    Keys.onEscapePressed: ShellState.closeIsland()

    onVisibleChanged: {
        if (visible) {
            forceActiveFocus()
            refreshAll()
        }
    }

    function refreshAll() {
        wifiProc.running   = true
        btProc.running     = true
        volProc.running    = true
        brightProc.running = true
    }

    Process {
        id: wifiProc
        command: ["nmcli", "radio", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: cc.wifiEnabled = text.trim() === "enabled"
        }
    }

    Process {
        id: btProc
        command: ["sh", "-c", "rfkill list bluetooth 2>/dev/null | grep -c 'Soft blocked: no' || echo 0"]
        stdout: StdioCollector {
            onStreamFinished: cc.bluetoothEnabled = parseInt(text.trim()) > 0
        }
    }

    Process {
        id: volProc
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@"]
        stdout: StdioCollector {
            onStreamFinished: {
                var line = text.trim()
                cc.volumeMuted = line.indexOf("[MUTED]") !== -1
                var m = line.match(/Volume:\s*([\d.]+)/)
                if (m) cc.volume = Math.round(parseFloat(m[1]) * 100)
            }
        }
    }

    Process {
        id: brightProc
        command: ["sh", "-c", "brightnessctl -m 2>/dev/null | awk -F, '{gsub(/%/,\"\",$4); print $4}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                var v = parseInt(text.trim())
                if (!isNaN(v)) cc.brightness = v
            }
        }
    }

    // ── Root layout ──────────────────────────────────────────────────────────

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        // Header
        RowLayout {
            Layout.fillWidth: true

            Text {
                font.family: Theme.font; font.pixelSize: 15; font.weight: Font.SemiBold
                color: Theme.c("fg", "#cdd6f4")
                text: "Control Center"
            }
            Item { Layout.fillWidth: true }
            Rectangle {
                width: 24; height: 24; radius: 12
                color: xHov.containsMouse
                    ? Qt.alpha(Theme.c("muted", "#6c7086"), 0.2) : "transparent"
                Text {
                    anchors.centerIn: parent
                    font.family: Theme.font; font.pixelSize: 11
                    color: Theme.c("muted", "#6c7086")
                    text: "✕"
                }
                MouseArea { id: xHov; anchors.fill: parent; hoverEnabled: true
                    onClicked: ShellState.closeIsland() }
            }
        }

        // 2×2 toggle grid
        Row {
            Layout.fillWidth: true
            spacing: 8

            property real tileW: (parent.width - 8) / 2

            // WiFi
            Rectangle {
                width: parent.tileW; height: 82; radius: 18
                color: cc.wifiEnabled
                    ? Qt.alpha(Theme.c("accent", "#89b4fa"), 0.22)
                    : Qt.alpha(Theme.c("panel_alt", "#1e1e2e"), 0.85)
                Behavior on color { ColorAnimation { duration: 180 } }

                Column { anchors { fill: parent; margins: 14 } spacing: 8
                    Rectangle {
                        width: 36; height: 36; radius: 18
                        color: cc.wifiEnabled
                            ? Theme.c("accent", "#89b4fa")
                            : Qt.alpha(Theme.c("border", "#313244"), 0.9)
                        Behavior on color { ColorAnimation { duration: 180 } }
                        Text { anchors.centerIn: parent; font.family: Theme.font
                            font.pixelSize: 17
                            color: cc.wifiEnabled ? "#0a0a0f" : Theme.c("fg", "#cdd6f4")
                            text: cc.wifiEnabled ? "󰤨" : "󰤭" }
                    }
                    Text { font.family: Theme.font; font.pixelSize: 11; font.weight: Font.Medium
                        color: cc.wifiEnabled ? Theme.c("accent", "#89b4fa") : Theme.c("muted", "#6c7086")
                        text: "Wi-Fi"
                        Behavior on color { ColorAnimation { duration: 180 } } }
                }
                MouseArea { anchors.fill: parent; onClicked: {
                    Quickshell.execDetached(["nmcli", "radio", "wifi", cc.wifiEnabled ? "off" : "on"])
                    cc.wifiEnabled = !cc.wifiEnabled
                }}
            }

            // Bluetooth
            Rectangle {
                width: parent.tileW; height: 82; radius: 18
                color: cc.bluetoothEnabled
                    ? Qt.alpha(Theme.c("accent", "#89b4fa"), 0.22)
                    : Qt.alpha(Theme.c("panel_alt", "#1e1e2e"), 0.85)
                Behavior on color { ColorAnimation { duration: 180 } }

                Column { anchors { fill: parent; margins: 14 } spacing: 8
                    Rectangle {
                        width: 36; height: 36; radius: 18
                        color: cc.bluetoothEnabled
                            ? Theme.c("accent", "#89b4fa")
                            : Qt.alpha(Theme.c("border", "#313244"), 0.9)
                        Behavior on color { ColorAnimation { duration: 180 } }
                        Text { anchors.centerIn: parent; font.family: Theme.font
                            font.pixelSize: 17
                            color: cc.bluetoothEnabled ? "#0a0a0f" : Theme.c("fg", "#cdd6f4")
                            text: cc.bluetoothEnabled ? "󰂯" : "󰂲" }
                    }
                    Text { font.family: Theme.font; font.pixelSize: 11; font.weight: Font.Medium
                        color: cc.bluetoothEnabled ? Theme.c("accent", "#89b4fa") : Theme.c("muted", "#6c7086")
                        text: "Bluetooth"
                        Behavior on color { ColorAnimation { duration: 180 } } }
                }
                MouseArea { anchors.fill: parent; onClicked: {
                    Quickshell.execDetached(["sh", "-c",
                        cc.bluetoothEnabled ? "rfkill block bluetooth" : "rfkill unblock bluetooth"])
                    cc.bluetoothEnabled = !cc.bluetoothEnabled
                }}
            }
        }

        Row {
            Layout.fillWidth: true
            spacing: 8

            property real tileW: (parent.width - 8) / 2

            // DND
            Rectangle {
                width: parent.tileW; height: 82; radius: 18
                color: ShellState.dndEnabled
                    ? Qt.alpha(Theme.c("accent", "#89b4fa"), 0.22)
                    : Qt.alpha(Theme.c("panel_alt", "#1e1e2e"), 0.85)
                Behavior on color { ColorAnimation { duration: 180 } }

                Column { anchors { fill: parent; margins: 14 } spacing: 8
                    Rectangle {
                        width: 36; height: 36; radius: 18
                        color: ShellState.dndEnabled
                            ? Theme.c("accent", "#89b4fa")
                            : Qt.alpha(Theme.c("border", "#313244"), 0.9)
                        Behavior on color { ColorAnimation { duration: 180 } }
                        Text { anchors.centerIn: parent; font.family: Theme.font
                            font.pixelSize: 17
                            color: ShellState.dndEnabled ? "#0a0a0f" : Theme.c("fg", "#cdd6f4")
                            text: ShellState.dndEnabled ? "󰂛" : "󰂚" }
                    }
                    Text { font.family: Theme.font; font.pixelSize: 11; font.weight: Font.Medium
                        color: ShellState.dndEnabled ? Theme.c("accent", "#89b4fa") : Theme.c("muted", "#6c7086")
                        text: "Do Not Disturb"
                        Behavior on color { ColorAnimation { duration: 180 } } }
                }
                MouseArea { anchors.fill: parent
                    onClicked: ShellState.dndEnabled = !ShellState.dndEnabled }
            }

            // Airplane
            Rectangle {
                width: parent.tileW; height: 82; radius: 18
                color: cc.airplaneEnabled
                    ? Qt.alpha(Theme.c("accent", "#89b4fa"), 0.22)
                    : Qt.alpha(Theme.c("panel_alt", "#1e1e2e"), 0.85)
                Behavior on color { ColorAnimation { duration: 180 } }

                Column { anchors { fill: parent; margins: 14 } spacing: 8
                    Rectangle {
                        width: 36; height: 36; radius: 18
                        color: cc.airplaneEnabled
                            ? Theme.c("accent", "#89b4fa")
                            : Qt.alpha(Theme.c("border", "#313244"), 0.9)
                        Behavior on color { ColorAnimation { duration: 180 } }
                        Text { anchors.centerIn: parent; font.family: Theme.font
                            font.pixelSize: 17
                            color: cc.airplaneEnabled ? "#0a0a0f" : Theme.c("fg", "#cdd6f4")
                            text: "󱡅" }
                    }
                    Text { font.family: Theme.font; font.pixelSize: 11; font.weight: Font.Medium
                        color: cc.airplaneEnabled ? Theme.c("accent", "#89b4fa") : Theme.c("muted", "#6c7086")
                        text: "Airplane Mode"
                        Behavior on color { ColorAnimation { duration: 180 } } }
                }
                MouseArea { anchors.fill: parent; onClicked: {
                    if (cc.airplaneEnabled) {
                        Quickshell.execDetached(["sh", "-c", "rfkill unblock all"])
                        cc.airplaneEnabled = false
                        wifiProc.running = true
                        btProc.running   = true
                    } else {
                        Quickshell.execDetached(["sh", "-c", "rfkill block all"])
                        cc.airplaneEnabled  = true
                        cc.wifiEnabled      = false
                        cc.bluetoothEnabled = false
                    }
                }}
            }
        }

        // Volume slider
        Rectangle {
            Layout.fillWidth: true
            height: 72; radius: 18
            color: Qt.alpha(Theme.c("panel_alt", "#1e1e2e"), 0.85)

            RowLayout {
                anchors { fill: parent; leftMargin: 14; rightMargin: 14 }
                spacing: 12

                Rectangle {
                    width: 36; height: 36; radius: 18
                    color: cc.volumeMuted
                        ? Qt.alpha(Theme.c("border", "#313244"), 0.7)
                        : Qt.alpha(Theme.c("accent", "#89b4fa"), 0.22)
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Text { anchors.centerIn: parent; font.family: Theme.font; font.pixelSize: 17
                        color: cc.volumeMuted ? Theme.c("muted", "#6c7086") : Theme.c("accent", "#89b4fa")
                        text: cc.volumeMuted ? "󰝟" : (cc.volume > 60 ? "󰕾" : cc.volume > 0 ? "󰖀" : "󰕿") }
                    MouseArea { anchors.fill: parent; onClicked: {
                        Quickshell.execDetached(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"])
                        cc.volumeMuted = !cc.volumeMuted
                    }}
                }

                ColumnLayout {
                    Layout.fillWidth: true; spacing: 6
                    RowLayout {
                        Layout.fillWidth: true
                        Text { font.family: Theme.font; font.pixelSize: 12; font.weight: Font.Medium
                            color: Theme.c("fg", "#cdd6f4"); text: "Volume" }
                        Item { Layout.fillWidth: true }
                        Text { font.family: Theme.font; font.pixelSize: 11
                            color: Theme.c("muted", "#6c7086")
                            text: cc.volumeMuted ? "Muted" : cc.volume + "%" }
                    }
                    Rectangle {
                        id: volTrack
                        Layout.fillWidth: true; height: 6; radius: 3
                        color: Qt.alpha(Theme.c("border", "#313244"), 0.9)
                        Rectangle {
                            width: volTrack.width * (cc.volumeMuted ? 0 : cc.volume) / 100
                            height: parent.height; radius: parent.radius
                            color: Theme.c("accent", "#89b4fa")
                            Behavior on width { NumberAnimation { duration: 80 } }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var v = Math.max(0, Math.min(100, Math.round(mouseX / volTrack.width * 100)))
                                cc.volume = v; cc.volumeMuted = false
                                Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", v + "%"])
                            }
                            onPositionChanged: {
                                if (pressed) {
                                    var v = Math.max(0, Math.min(100, Math.round(mouseX / volTrack.width * 100)))
                                    cc.volume = v; cc.volumeMuted = false
                                    Quickshell.execDetached(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", v + "%"])
                                }
                            }
                        }
                    }
                }
            }
        }

        // Brightness slider
        Rectangle {
            Layout.fillWidth: true
            height: 72; radius: 18
            color: Qt.alpha(Theme.c("panel_alt", "#1e1e2e"), 0.85)

            RowLayout {
                anchors { fill: parent; leftMargin: 14; rightMargin: 14 }
                spacing: 12

                Rectangle {
                    width: 36; height: 36; radius: 18
                    color: Qt.alpha(Theme.c("accent", "#89b4fa"), 0.22)
                    Text { anchors.centerIn: parent; font.family: Theme.font; font.pixelSize: 17
                        color: Theme.c("accent", "#89b4fa")
                        text: cc.brightness > 60 ? "󰃠" : cc.brightness > 30 ? "󰃟" : "󰃞" }
                }

                ColumnLayout {
                    Layout.fillWidth: true; spacing: 6
                    RowLayout {
                        Layout.fillWidth: true
                        Text { font.family: Theme.font; font.pixelSize: 12; font.weight: Font.Medium
                            color: Theme.c("fg", "#cdd6f4"); text: "Brightness" }
                        Item { Layout.fillWidth: true }
                        Text { font.family: Theme.font; font.pixelSize: 11
                            color: Theme.c("muted", "#6c7086"); text: cc.brightness + "%" }
                    }
                    Rectangle {
                        id: brightTrack
                        Layout.fillWidth: true; height: 6; radius: 3
                        color: Qt.alpha(Theme.c("border", "#313244"), 0.9)
                        Rectangle {
                            width: brightTrack.width * cc.brightness / 100
                            height: parent.height; radius: parent.radius
                            color: Theme.c("accent", "#89b4fa")
                            Behavior on width { NumberAnimation { duration: 80 } }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                var v = Math.max(0, Math.min(100, Math.round(mouseX / brightTrack.width * 100)))
                                cc.brightness = v
                                Quickshell.execDetached(["brightnessctl", "set", v + "%"])
                            }
                            onPositionChanged: {
                                if (pressed) {
                                    var v = Math.max(0, Math.min(100, Math.round(mouseX / brightTrack.width * 100)))
                                    cc.brightness = v
                                    Quickshell.execDetached(["brightnessctl", "set", v + "%"])
                                }
                            }
                        }
                    }
                }
            }
        }

        Item { Layout.fillHeight: true }
    }
}
