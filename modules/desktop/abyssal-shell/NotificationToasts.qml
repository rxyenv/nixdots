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
    implicitWidth: 350
    implicitHeight: Math.min(500, toastColumn.implicitHeight + 12)
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; right: true }
    margins { top: palette.barHeight + 4; right: 4 }
    WlrLayershell.namespace: "abyssal-notification-toasts"
    WlrLayershell.layer: WlrLayer.Overlay

    Column {
        id: toastColumn
        opacity: 0.97
        anchors.top: parent.top
        anchors.right: parent.right
        width: 346
        spacing: 4

        Repeater {
            model: root.shell.toastNotifications.slice(0, 4)

            delegate: Rectangle {
                id: toast
                required property var modelData

                width: toastColumn.width
                height: Math.max(72, bodyColumn.implicitHeight + 20)
                radius: root.palette.radius
                color: Qt.rgba(0.118, 0.118, 0.180, 0.97)
                border.width: 1
                border.color: root.palette.border

                function dismissToast() {
                    toast.modelData.dismiss()
                    root.shell.hideToast(toast.modelData)
                }

                TapHandler {
                    acceptedButtons: Qt.RightButton
                    onTapped: toast.dismissToast()
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    Image {
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        Layout.alignment: Qt.AlignTop
                        source: toast.modelData.image || Quickshell.iconPath(toast.modelData.appIcon, "dialog-information")
                        sourceSize.width: 24
                        sourceSize.height: 24
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
                                    onClicked: toast.dismissToast()
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
                    interval: 1000
                    running: true
                    onTriggered: root.shell.hideToast(toast.modelData)
                }

            }
        }
    }
}
