import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    required property var modelData
    required property var shell
    required property var notificationServer

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
        width: Math.min(380, parent.width - 16)
        height: Math.min(700, parent.height - root.palette.barHeight - 12)
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

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: "Notifications"
                    color: root.palette.foreground
                    font.family: root.palette.fontFamily
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                }

                GlassButton {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 30
                    icon: root.shell.preferences.doNotDisturb ? "󰂛" : "󰂚"
                    compact: true
                    checked: root.shell.preferences.doNotDisturb
                    onClicked: root.shell.preferences.doNotDisturb = !root.shell.preferences.doNotDisturb
                }
            }

            ListView {
                id: history
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 6
                model: root.notificationServer.trackedNotifications

                delegate: GlassPanel {
                    id: notification
                    required property var modelData

                    width: ListView.view.width
                    height: Math.max(72, notificationContent.implicitHeight + 20)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8

                        Image {
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            Layout.alignment: Qt.AlignTop
                            source: notification.modelData.image
                                || Quickshell.iconPath(notification.modelData.appIcon, "dialog-information")
                            sourceSize.width: 24
                            sourceSize.height: 24
                            fillMode: Image.PreserveAspectFit
                        }

                        ColumnLayout {
                            id: notificationContent
                            Layout.fillWidth: true
                            spacing: 3

                            Text {
                                Layout.fillWidth: true
                                text: notification.modelData.appName || "Notification"
                                color: root.palette.accent
                                elide: Text.ElideRight
                                font.family: root.palette.fontFamily
                                font.pixelSize: 9
                            }
                            Text {
                                Layout.fillWidth: true
                                text: notification.modelData.summary
                                color: root.palette.foreground
                                wrapMode: Text.Wrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                                font.family: root.palette.fontFamily
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                            }
                            Text {
                                visible: text.length > 0
                                Layout.fillWidth: true
                                text: notification.modelData.body.replace(/<[^>]*>/g, "")
                                color: root.palette.muted
                                wrapMode: Text.Wrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                                font.family: root.palette.fontFamily
                                font.pixelSize: 10
                            }
                        }

                        Text {
                            text: ""
                            color: dismiss.containsMouse ? root.palette.foreground : root.palette.muted
                            font.family: root.palette.fontFamily
                            font.pixelSize: 10
                            MouseArea {
                                id: dismiss
                                anchors.fill: parent
                                anchors.margins: -7
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: notification.modelData.dismiss()
                            }
                        }
                    }
                }

                Text {
                    visible: history.count === 0
                    anchors.centerIn: parent
                    text: "All quiet in the abyss"
                    color: root.palette.muted
                    font.family: root.palette.fontFamily
                    font.pixelSize: 12
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: root.palette.border }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                GlassButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 38
                    compact: true
                    icon: ""
                    label: "Session"
                    onClicked: shell.toggleSurface("session", root.modelData)
                }
            }
        }
    }

}
