import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    required property var shell

    readonly property Theme palette: Theme {}
    property bool shown: false
    property string kind: "volume"
    property int value: 0
    property bool muted: false

    function reveal(newKind, newValue, newMuted) {
        kind = newKind
        value = Math.max(0, Math.min(100, Number(newValue)))
        muted = newMuted === true
        shown = true
        hideTimer.restart()
    }

    screen: Quickshell.screens.find(candidate => shell.isFocusedScreen(candidate)) || Quickshell.screens[0]
    visible: shown
    color: "transparent"
    implicitWidth: 300
    implicitHeight: 52
    exclusionMode: ExclusionMode.Ignore
    anchors { bottom: true }
    margins.bottom: 24
    WlrLayershell.namespace: "abyssal-osd"
    WlrLayershell.layer: WlrLayer.Overlay

    Rectangle {
        id: card
        opacity: 0.97
        anchors.fill: parent
        radius: root.palette.radiusLarge
        color: Qt.rgba(0.118, 0.118, 0.180, 0.97)
        border.width: 1
        border.color: root.palette.border

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            Item {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 32

                Text {
                    anchors.centerIn: parent
                    text: root.kind === "brightness" ? "󰃠" : root.muted ? "" : ""
                    color: root.muted ? root.palette.muted : root.palette.accent
                    font.family: root.palette.fontFamily
                    font.pixelSize: 16
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 8
                radius: root.palette.radius
                color: Qt.rgba(0.804, 0.839, 0.957, 0.97)
                border.width: 1
                border.color: root.palette.border

                Rectangle {
                    anchors.left: parent.left
                    anchors.leftMargin: 1
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.max(0, (parent.width - 2) * root.value / 100)
                    height: parent.height - 2
                    radius: root.palette.radius
                    color: root.muted ? root.palette.subtle : root.palette.accent

                }
            }

            Text {
                text: root.value + "%"
                color: root.palette.foreground
                font.family: root.palette.fontFamily
                font.pixelSize: 12
                font.weight: Font.Bold
            }
        }
    }

    Process {
        id: volumeProcess
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null"]
        stdout: StdioCollector { id: volumeOutput }
        onExited: {
            const output = volumeOutput.text.trim()
            const match = output.match(/([0-9.]+)/)
            root.reveal("volume", match ? Math.round(parseFloat(match[1]) * 100) : 0,
                output.indexOf("MUTED") >= 0)
        }
    }

    IpcHandler {
        target: "osd"

        function volume() {
            if (!volumeProcess.running) volumeProcess.running = true
        }

        function brightness(value: string) {
            root.reveal("brightness", value, false)
        }
    }

    Timer {
        id: hideTimer
        interval: 1600
        onTriggered: root.shown = false
    }

}
