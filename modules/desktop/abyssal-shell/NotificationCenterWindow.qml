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

    screen: modelData
    visible: shell.surfaceVisible("notifications", modelData)
    color: palette.scrim
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    WlrLayershell.namespace: "abyssal-notification-center"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    Shortcut {
        sequence: "Escape"
        onActivated: root.shell.closeSurfaces()
    }
    onVisibleChanged: if (visible) entrance.restart()

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
        width: Math.min(410, parent.width - 32)
        height: Math.min(680, parent.height - root.palette.barHeight - 28)
        radius: root.palette.radiusLarge
        strong: true

        MouseArea { anchors.fill: parent; acceptedButtons: Qt.NoButton }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: "Notifications"
                    color: root.palette.foreground
                    font.family: root.palette.fontFamily
                    font.pixelSize: 17
                    font.weight: Font.DemiBold
                }
                GlassButton {
                    Layout.preferredWidth: 42
                    Layout.preferredHeight: 38
                    icon: root.shell.preferences.doNotDisturb ? "󰂛" : "󰂚"
                    compact: true
                    checked: root.shell.preferences.doNotDisturb
                    onClicked: root.shell.preferences.doNotDisturb = !root.shell.preferences.doNotDisturb
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: root.palette.border }

            ListView {
                id: history
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 9
                model: root.notificationServer.trackedNotifications

                delegate: GlassPanel {
                    id: notification
                    required property var modelData

                    width: ListView.view.width
                    height: Math.max(92, content.implicitHeight + 28)
                    elevated: false

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 13
                        spacing: 11

                        Image {
                            Layout.preferredWidth: 30
                            Layout.preferredHeight: 30
                            Layout.alignment: Qt.AlignTop
                            source: notification.modelData.image || Quickshell.iconPath(notification.modelData.appIcon, "dialog-information")
                            sourceSize.width: 30
                            sourceSize.height: 30
                            fillMode: Image.PreserveAspectFit
                        }

                        ColumnLayout {
                            id: content
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
        }
    }

    SequentialAnimation {
        id: entrance
        PropertyAction { target: card; property: "opacity"; value: 0 }
        PropertyAction { target: card; property: "scale"; value: 0.96 }
        ParallelAnimation {
            NumberAnimation { target: card; property: "opacity"; to: 1; duration: root.shell.preferences.animationsEnabled ? 180 : 0 }
            NumberAnimation { target: card; property: "scale"; to: 1; duration: root.shell.preferences.animationsEnabled ? 280 : 0; easing.type: Easing.OutBack; easing.overshoot: 1.06 }
        }
    }
}
