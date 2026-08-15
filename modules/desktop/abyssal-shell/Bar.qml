import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Widgets
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
    readonly property int statusIconSize: 14
    readonly property int statusItemSize: 26
    property Item tooltipTarget: null
    property string tooltipText: ""

    function showTooltip(target, text) {
        tooltipTarget = target
        tooltipText = text
        tooltipDelay.restart()
    }

    function hideTooltip(target) {
        if (tooltipTarget !== target) return
        tooltipDelay.stop()
        tooltipWindow.visible = false
        tooltipTarget = null
    }

    Timer {
        id: tooltipDelay
        interval: 420
        onTriggered: tooltipWindow.visible = root.tooltipTarget !== null
    }

    screen: modelData
    implicitHeight: palette.barHeight
    color: "transparent"
    // Let tiled windows sit closer to the panel while retaining Hyprland's
    // regular outer gap around the rest of the workspace.
    exclusiveZone: implicitHeight - 10
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
                            onEntered: root.showTooltip(workspaceMouse,
                                "Workspace " + workspace.modelData.id
                                    + (workspace.modelData.focused ? " · Active" : ""))
                            onExited: root.hideTooltip(workspaceMouse)
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
                id: statusArea
                Layout.preferredWidth: statusRow.implicitWidth
                Layout.preferredHeight: root.statusItemSize

                Row {
                    id: statusRow
                    anchors.centerIn: parent
                    height: root.statusItemSize
                    spacing: 4

                    Item {
                        id: tray
                        width: trayIcons.implicitWidth
                        height: root.statusItemSize
                        visible: SystemTray.items.values.length > 0

                        Row {
                            id: trayIcons
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4

                            Repeater {
                                model: SystemTray.items.values
                                delegate: Item {
                                    required property var modelData
                                    width: root.statusItemSize
                                    height: root.statusItemSize
                                    IconImage {
                                        id: trayIcon
                                        anchors.centerIn: parent
                                        width: 16
                                        height: 16
                                        source: modelData.icon
                                        mipmap: true
                                    }
                                    MouseArea {
                                        id: trayMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onEntered: {
                                            const title = modelData.tooltipTitle || modelData.title || modelData.id
                                            const detail = modelData.tooltipDescription
                                            root.showTooltip(trayMouse, title + (detail ? " · " + detail : ""))
                                        }
                                        onExited: root.hideTooltip(trayMouse)
                                        onClicked: modelData.activate()
                                        onPressed: mouse => {
                                            if (mouse.button === Qt.RightButton) modelData.secondaryActivate()
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        visible: tray.visible
                        anchors.verticalCenter: parent.verticalCenter
                        width: 1
                        height: 16
                        color: Qt.rgba(1, 1, 1, 0.12)
                    }

                    Item {
                        width: root.statusItemSize
                        height: root.statusItemSize
                        Text {
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: !root.status.networkConnected ? "󰤭"
                                : root.status.wifiSignal <= 0 ? "󰤨"
                                : root.status.wifiSignal >= 75 ? "󰤨"
                                : root.status.wifiSignal >= 50 ? "󰤥"
                                : root.status.wifiSignal >= 25 ? "󰤢" : "󰤟"
                            color: root.palette.foreground
                            font.family: root.palette.fontFamily
                            font.pixelSize: root.statusIconSize
                        }
                        MouseArea {
                            id: networkMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.showTooltip(networkMouse,
                                !root.status.networkConnected ? "Network disconnected"
                                    : root.status.wifiSignal > 0
                                        ? root.status.wifi + " · " + root.status.wifiSignal + "%"
                                        : "Network connected")
                            onExited: root.hideTooltip(networkMouse)
                            onClicked: root.shell.toggleSurface("control", root.modelData)
                        }
                    }

                    Item {
                        width: root.statusItemSize
                        height: root.statusItemSize
                        Text {
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: root.status.bluetoothConnected ? "󰂱"
                                : root.status.bluetoothEnabled ? "" : "󰂲"
                            color: root.status.bluetoothEnabled ? root.palette.foreground : root.palette.muted
                            font.family: root.palette.fontFamily
                            font.pixelSize: root.statusIconSize
                        }
                        MouseArea {
                            id: bluetoothMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.showTooltip(bluetoothMouse, "Bluetooth · " + root.status.bluetooth)
                            onExited: root.hideTooltip(bluetoothMouse)
                            onClicked: root.shell.toggleSurface("control", root.modelData)
                        }
                    }

                    Item {
                        width: root.statusItemSize
                        height: root.statusItemSize
                        Text {
                            id: volumeText
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: root.status.muted ? "" : ""
                            color: root.palette.foreground
                            font.family: root.palette.fontFamily
                            font.pixelSize: root.statusIconSize
                        }
                        MouseArea {
                            id: volumeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.showTooltip(volumeMouse,
                                root.status.muted ? "Sound muted" : "Volume · " + root.status.volume)
                            onExited: root.hideTooltip(volumeMouse)
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
                onEntered: root.showTooltip(clockMouse,
                    Qt.formatDateTime(root.clock.date, "dddd, MMMM d, yyyy"))
                onExited: root.hideTooltip(clockMouse)
                onClicked: root.shell.toggleSurface("notifications", root.modelData)
            }
        }
    }

    PanelWindow {
        id: tooltipWindow

        screen: root.modelData
        visible: false
        color: "transparent"
        implicitWidth: tooltipLabel.width + 10
        implicitHeight: tooltipLabel.contentHeight + 8
        exclusiveZone: 0
        exclusionMode: ExclusionMode.Ignore
        anchors { top: true; left: true }
        margins {
            top: 4
            left: {
                if (!root.tooltipTarget) return 8
                const point = root.tooltipTarget.mapToItem(
                    root.contentItem, root.tooltipTarget.width / 2, 0)
                return Math.max(8, Math.min(root.width - tooltipWindow.implicitWidth - 8,
                    point.x - tooltipWindow.implicitWidth / 2))
            }
        }
        WlrLayershell.namespace: "abyssal-tooltip"
        WlrLayershell.layer: WlrLayer.Overlay

        Rectangle {
            id: tooltipCard
            anchors.fill: parent
            anchors.margins: 1
            radius: 7
            border.width: 1
            border.color: root.palette.border
            color: root.palette.panelStrong

            Item {
                anchors.centerIn: parent
                width: tooltipLabel.width
                height: tooltipLabel.height

                Text {
                    id: tooltipLabel
                    width: Math.min(Math.ceil(implicitWidth) + 1, root.width - 24)
                    text: root.tooltipText
                    color: root.palette.foreground
                    font.family: root.palette.fontFamily
                    font.pixelSize: 11
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }
            }
        }
    }
}
