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
        entrance.restart()
        hideTimer.restart()
    }

    screen: Quickshell.screens.find(candidate => shell.isFocusedScreen(candidate)) || Quickshell.screens[0]
    visible: shown
    color: "transparent"
    implicitWidth: 360
    implicitHeight: 92
    exclusionMode: ExclusionMode.Ignore
    anchors { bottom: true }
    margins.bottom: 80
    WlrLayershell.namespace: "abyssal-osd"
    WlrLayershell.layer: WlrLayer.Overlay

    Rectangle {
        id: card
        anchors.fill: parent
        radius: 22
        color: Qt.rgba(0.045, 0.085, 0.095, 0.65)
        border.width: 1
        border.color: root.palette.border

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10

            Item {
                Layout.preferredWidth: 42
                Layout.preferredHeight: 54

                Text {
                    anchors.centerIn: parent
                    text: root.kind === "brightness" ? "󰃠" : root.muted ? "" : ""
                    color: root.muted ? root.palette.muted : root.palette.accent
                    font.family: root.palette.fontFamily
                    font.pixelSize: 23
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 12
                radius: 6
                color: Qt.rgba(1, 1, 1, 0.055)
                border.width: 1
                border.color: root.palette.border

                Rectangle {
                    anchors.left: parent.left
                    anchors.leftMargin: 1
                    anchors.verticalCenter: parent.verticalCenter
                    width: Math.max(0, (parent.width - 2) * root.value / 100)
                    height: parent.height - 2
                    radius: 5
                    color: root.muted ? root.palette.subtle : root.palette.accent

                    Behavior on width {
                        NumberAnimation {
                            duration: root.palette.durationFast
                            easing.type: Easing.OutCubic
                        }
                    }

                    Rectangle {
                        visible: parent.width > 10 && !root.muted
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 8
                        height: 8
                        radius: 4
                        color: root.palette.foreground
                    }
                }
            }

            Text {
                text: root.value + "%"
                color: root.palette.foreground
                font.family: root.palette.fontFamily
                font.pixelSize: 16
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

    SequentialAnimation {
        id: entrance
        PropertyAction { target: card; property: "opacity"; value: 0 }
        PropertyAction { target: card; property: "scale"; value: 0.92 }
        ParallelAnimation {
            NumberAnimation {
                target: card
                property: "opacity"
                to: 1
                duration: root.shell.preferences.animationsEnabled ? 140 : 0
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: card
                property: "scale"
                to: 1
                duration: root.shell.preferences.animationsEnabled ? 240 : 0
                easing.type: Easing.OutBack
                easing.overshoot: 1.04
            }
        }
    }
}
