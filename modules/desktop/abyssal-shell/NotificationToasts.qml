import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    required property var modelData
    required property var shell

    readonly property Theme palette: Theme {}

    screen: modelData
    visible: shell.toastNotifications.length > 0
        && !shell.preferences.doNotDisturb
        && shell.isPrimaryScreen(modelData)
    color: "transparent"
    implicitWidth: 390
    implicitHeight: Math.min(500, toastColumn.implicitHeight + 24)
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; right: true }
    margins { top: palette.barHeight + 10; right: 12 }
    WlrLayershell.namespace: "abyssal-notification-toasts"
    WlrLayershell.layer: WlrLayer.Overlay

    Column {
        id: toastColumn
        anchors.top: parent.top
        anchors.right: parent.right
        width: 378
        spacing: 9

        Repeater {
            model: root.shell.toastNotifications.slice(0, 4)

            delegate: GlassPanel {
                id: toast
                required property var modelData

                width: toastColumn.width
                height: Math.max(92, bodyColumn.implicitHeight + 30)
                radius: root.palette.radius
                strong: true

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 12

                    Image {
                        Layout.preferredWidth: 34
                        Layout.preferredHeight: 34
                        Layout.alignment: Qt.AlignTop
                        source: toast.modelData.image || Quickshell.iconPath(toast.modelData.appIcon, "dialog-information")
                        sourceSize.width: 34
                        sourceSize.height: 34
                        fillMode: Image.PreserveAspectFit
                    }

                    ColumnLayout {
                        id: bodyColumn
                        Layout.fillWidth: true
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                Layout.fillWidth: true
                                text: toast.modelData.appName || "Notification"
                                color: root.palette.accent
                                elide: Text.ElideRight
                                font.family: root.palette.fontFamily
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                            }
                            Text {
                                text: ""
                                color: closeArea.containsMouse ? root.palette.foreground : root.palette.muted
                                font.family: root.palette.fontFamily
                                font.pixelSize: 11
                                MouseArea {
                                    id: closeArea
                                    anchors.fill: parent
                                    anchors.margins: -7
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        toast.modelData.dismiss()
                                        root.shell.hideToast(toast.modelData)
                                    }
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: toast.modelData.summary
                            color: root.palette.foreground
                            wrapMode: Text.Wrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                            font.family: root.palette.fontFamily
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                        }

                        Text {
                            visible: text.length > 0
                            Layout.fillWidth: true
                            text: toast.modelData.body.replace(/<[^>]*>/g, "")
                            color: root.palette.muted
                            wrapMode: Text.Wrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                            font.family: root.palette.fontFamily
                            font.pixelSize: 11
                        }
                    }
                }

                Timer {
                    interval: toast.modelData.expireTimeout > 0 ? Math.max(2500, toast.modelData.expireTimeout) : 6500
                    running: true
                    onTriggered: root.shell.hideToast(toast.modelData)
                }

                Component.onCompleted: entrance.restart()
                SequentialAnimation {
                    id: entrance
                    PropertyAction { target: toast; property: "opacity"; value: 0 }
                    PropertyAction { target: toast; property: "scale"; value: 0.94 }
                    ParallelAnimation {
                        NumberAnimation { target: toast; property: "opacity"; to: 1; duration: root.shell.preferences.animationsEnabled ? 160 : 0 }
                        NumberAnimation { target: toast; property: "scale"; to: 1; duration: root.shell.preferences.animationsEnabled ? 280 : 0; easing.type: Easing.OutBack; easing.overshoot: 1.08 }
                    }
                }
            }
        }
    }
}
