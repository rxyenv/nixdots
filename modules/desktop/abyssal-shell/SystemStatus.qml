import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property string wifi: "Checking…"
    property bool wifiEnabled: false
    property int wifiSignal: 0
    property bool networkConnected: false
    property string bluetooth: "Checking…"
    property bool bluetoothEnabled: false
    property bool bluetoothConnected: false
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
        command: ["sh", "-c", "state=$(nmcli radio wifi 2>/dev/null); ssid=$(nmcli -t -f active,ssid dev wifi 2>/dev/null | awk -F: '$1 == \"yes\" {print $2; exit}'); signal=$(nmcli -t -f IN-USE,SIGNAL dev wifi 2>/dev/null | awk -F: '$1 == \"*\" {print $2; exit}'); network=$(nmcli -t -f STATE general 2>/dev/null | awk '{print $1}'); printf '%s|%s|%s|%s' \"$state\" \"$ssid\" \"$network\" \"$signal\""]
        stdout: StdioCollector { id: wifiOut }
        onExited: {
            const parts = wifiOut.text.trim().split("|")
            root.wifiEnabled = parts[0] === "enabled"
            root.wifi = !root.wifiEnabled ? "Off" : (parts[1] || "Available")
            root.networkConnected = parts[2] === "connected"
            root.wifiSignal = parseInt(parts[3] || "0")
        }
    }

    property Process bluetoothProcess: Process {
        id: bluetoothProcess
        command: ["sh", "-c", "powered=$(bluetoothctl show 2>/dev/null | awk -F': ' '/Powered:/{print $2; exit}'); connected=$(bluetoothctl devices Connected 2>/dev/null | awk '/^Device /{print \"yes\"; exit}'); printf '%s|%s' \"$powered\" \"$connected\""]
        stdout: StdioCollector { id: bluetoothOut }
        onExited: {
            const parts = bluetoothOut.text.trim().split("|")
            root.bluetoothEnabled = parts[0] === "yes"
            root.bluetoothConnected = parts[1] === "yes"
            root.bluetooth = root.bluetoothConnected ? "Connected" : (root.bluetoothEnabled ? "On" : "Off")
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
