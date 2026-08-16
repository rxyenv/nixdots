import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: root

    required property var modelData
    required property var shell

    readonly property Theme palette: Theme {}
    readonly property var status: shell.systemStatus
    readonly property SystemClock clock: SystemClock { precision: SystemClock.Minutes }
    readonly property int statusIconSize: 14
    readonly property int trayIconSize: 16
    readonly property int trayToggleIconSize: 20
    readonly property int contentPadding: 8
    readonly property int itemSpacing: 4
    readonly property int barItemSize: 28
    property bool trayExpanded: false
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
    // Reserve the full panel height; Hyprland's outer gap then leaves a small
    // amount of breathing room between the bar and tiled windows.
    exclusiveZone: implicitHeight
    anchors { top: true; left: true; right: true }
    margins { top: 0; left: 0; right: 0 }
    WlrLayershell.namespace: "abyssal-bar"

    Rectangle {
        anchors.fill: parent
        opacity: 0.97
        radius: 0
        color: Qt.rgba(0.118, 0.118, 0.180, 0.97)
        border.width: 0

        Row {
            id: workspaces
            anchors.left: parent.left
            anchors.leftMargin: root.contentPadding
            anchors.verticalCenter: parent.verticalCenter
            spacing: root.itemSpacing

            Repeater {
                model: Hyprland.workspaces.values.filter(workspace => workspace.id > 0 && workspace.id <= 10)

                delegate: Rectangle {
                    id: workspace
                    required property var modelData

                    width: root.barItemSize
                    height: root.barItemSize
                    radius: root.palette.radius
                    color: modelData.focused ? root.palette.accent
                        : modelData.urgent ? root.palette.danger
                        : modelData.active ? root.palette.accentSoft
                        : workspaceMouse.containsMouse ? root.palette.hover
                        : "transparent"

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

        Row {
            id: statusRow
            anchors.right: parent.right
            anchors.rightMargin: root.contentPadding
            anchors.verticalCenter: parent.verticalCenter
            height: root.barItemSize
            spacing: root.itemSpacing

                    Item {
                        id: tray
                        readonly property var activeItems: SystemTray.items.values.filter(
                            item => item.status !== Status.Passive)

                        width: trayToggle.width + (root.trayExpanded ? trayIcons.implicitWidth : 0)
                        height: root.barItemSize
                        visible: activeItems.length > 0
                        clip: true

                        Behavior on width {
                            NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
                        }

                        HoverHandler {
                            onHoveredChanged: root.trayExpanded = hovered
                        }

                        Row {
                            x: 0
                            anchors.verticalCenter: parent.verticalCenter

                            Item {
                                id: trayToggle
                                width: root.barItemSize
                                height: root.barItemSize

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰅂"
                                    rotation: root.trayExpanded ? 0 : 180
                                    color: root.palette.foreground
                                    font.family: root.palette.fontFamily
                                    font.pixelSize: root.trayToggleIconSize

                                    Behavior on rotation {
                                        NumberAnimation { duration: 600; easing.type: Easing.OutCubic }
                                    }
                                }
                            }

                            Row {
                                id: trayIcons
                                height: root.barItemSize
                                spacing: 0

                                Repeater {
                                    model: tray.activeItems
                                    delegate: Item {
                                        required property var modelData
                                        width: root.barItemSize
                                        height: root.barItemSize

                                        IconImage {
                                            anchors.centerIn: parent
                                            width: root.trayIconSize
                                            height: root.trayIconSize
                                            source: modelData.icon
                                            mipmap: true
                                        }

                                        MouseArea {
                                            id: trayMouse
                                            anchors.fill: parent
                                            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onEntered: {
                                                const title = modelData.tooltipTitle || modelData.title || modelData.id
                                                const detail = modelData.tooltipDescription
                                                root.showTooltip(trayMouse, title + (detail ? " · " + detail : ""))
                                            }
                                            onExited: root.hideTooltip(trayMouse)
                                            onClicked: mouse => {
                                                if (mouse.button === Qt.MiddleButton)
                                                    modelData.secondaryActivate()
                                                else if (mouse.button === Qt.RightButton)
                                                    modelData.secondaryActivate()
                                                else
                                                    modelData.activate()
                                            }
                                            onWheel: wheel => {
                                                modelData.scroll(wheel.angleDelta.y, false)
                                                wheel.accepted = true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Item {
                        width: root.barItemSize
                        height: root.barItemSize
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
                        width: root.barItemSize
                        height: root.barItemSize
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
                        width: root.barItemSize
                        height: root.barItemSize
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

                    Item {
                        readonly property int percentage: parseInt(root.status.battery) || 0

                        visible: root.status.battery !== ""
                        width: root.barItemSize
                        height: root.barItemSize

                        Text {
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: parent.percentage >= 90 ? "󰁹"
                                : parent.percentage >= 70 ? "󰂀"
                                : parent.percentage >= 50 ? "󰁾"
                                : parent.percentage >= 30 ? "󰁼"
                                : parent.percentage >= 10 ? "󰁺" : "󰂎"
                            color: parent.percentage <= 15 ? root.palette.danger : root.palette.foreground
                            font.family: root.palette.fontFamily
                            font.pixelSize: root.statusIconSize
                        }

                        MouseArea {
                            id: batteryMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.showTooltip(batteryMouse, "Battery · " + root.status.battery)
                            onExited: root.hideTooltip(batteryMouse)
                        }
                    }

                    Item {
                        width: root.barItemSize
                        height: root.barItemSize

                        Text {
                            anchors.fill: parent
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            text: root.shell.preferences.doNotDisturb ? "󰂛" : "󰂚"
                            color: root.shell.preferences.doNotDisturb
                                ? root.palette.muted : root.palette.foreground
                            font.family: root.palette.fontFamily
                            font.pixelSize: root.statusIconSize
                        }

                        MouseArea {
                            id: notificationMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.showTooltip(notificationMouse,
                                root.shell.preferences.doNotDisturb
                                    ? "Notifications · Do not disturb"
                                    : "Notifications")
                            onExited: root.hideTooltip(notificationMouse)
                            onClicked: root.shell.toggleSurface("control", root.modelData)
                        }
                    }
        }

        Item {
            id: clock
            anchors.centerIn: parent
            width: clockText.implicitWidth + 20
            height: root.barItemSize

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
                onClicked: root.shell.toggleSurface("control", root.modelData)
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
            opacity: 0.97
            radius: root.palette.radius
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
