import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property string wifi: "Checking…"
    property bool wifiEnabled: false
    property string bluetooth: "Checking…"
    property bool bluetoothEnabled: false
    property string volume: "—"
    property bool muted: false
    property string battery: ""

    function refresh() {
        if (!wifiProcess.running) wifiProcess.running = true
        if (!bluetoothProcess.running) bluetoothProcess.running = true
        if (!volumeProcess.running) volumeProcess.running = true
        if (!batteryProcess.running) batteryProcess.running = true
    }

    property Process wifiProcess: Process {
        id: wifiProcess
        command: ["sh", "-c", "state=$(nmcli radio wifi 2>/dev/null); ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | awk -F: '$1 == \"yes\" {print $2; exit}'); printf '%s|%s' \"$state\" \"$ssid\""]
        stdout: StdioCollector { id: wifiOut }
        onExited: {
            const parts = wifiOut.text.trim().split("|")
            root.wifiEnabled = parts[0] === "enabled"
            root.wifi = !root.wifiEnabled ? "Off" : (parts[1] || "Available")
        }
    }

    property Process bluetoothProcess: Process {
        id: bluetoothProcess
        command: ["sh", "-c", "bluetoothctl show 2>/dev/null | awk -F': ' '/Powered:/{print $2; exit}'"]
        stdout: StdioCollector { id: bluetoothOut }
        onExited: {
            root.bluetoothEnabled = bluetoothOut.text.trim() === "yes"
            root.bluetooth = root.bluetoothEnabled ? "On" : "Off"
        }
    }

    property Process volumeProcess: Process {
        id: volumeProcess
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null"]
        stdout: StdioCollector { id: volumeOut }
        onExited: {
            const output = volumeOut.text.trim()
            const match = output.match(/([0-9.]+)/)
            root.muted = output.indexOf("MUTED") >= 0
            root.volume = match ? Math.round(parseFloat(match[1]) * 100) + "%" : "—"
        }
    }

    property Process batteryProcess: Process {
        id: batteryProcess
        command: ["sh", "-c", "for f in /sys/class/power_supply/BAT*/capacity; do test -r \"$f\" && { printf '%s%%' \"$(head -n1 \"$f\")\"; break; }; done"]
        stdout: StdioCollector { id: batteryOut }
        onExited: root.battery = batteryOut.text.trim()
    }

    property Timer pollTimer: Timer {
        interval: 8000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
