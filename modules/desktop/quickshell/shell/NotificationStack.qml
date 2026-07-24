import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

// Notification toasts stacked inside the island
ColumnLayout {
    id: toastColumn

    anchors.top: parent.top
    anchors.topMargin: 12
    anchors.horizontalCenter: parent.horizontalCenter
    width: parent.width - 24
    spacing: 10
    opacity: ShellState.hasNotifs && !ShellState.open && !ShellState.osdVisible ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    Repeater {
        model: ShellState.notifs

        delegate: Rectangle {
            id: toast
            required property Notification modelData
            required property int index

            Layout.fillWidth: true
            implicitHeight: toastContent.implicitHeight + 16
            color: "transparent"

            // Divider between stacked notifications
            Rectangle {
                visible: toast.index > 0
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 6
                height: 1
                color: Qt.alpha(Theme.c("border", "#313244"), 0.8)
            }

            opacity: 0
            Component.onCompleted: opacity = 1
            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }

            Timer {
                interval: toast.modelData.expireTimeout > 0
                    ? toast.modelData.expireTimeout : 6000
                running: toast.modelData.urgency !== NotificationUrgency.Critical
                onTriggered: toast.modelData.expire()
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    const def = toast.modelData.actions
                        .find(a => a.identifier === "default");
                    if (def)
                        def.invoke();
                    else
                        toast.modelData.dismiss();
                }
            }

            ColumnLayout {
                id: toastContent
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 6
                anchors.topMargin: 10
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Image {
                        readonly property string src: toast.modelData.image !== ""
                            ? toast.modelData.image
                            : toast.modelData.appIcon !== ""
                                ? Quickshell.iconPath(toast.modelData.appIcon, true)
                                : ""
                        visible: src !== ""
                        source: src
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        sourceSize.width: 36
                        sourceSize.height: 36
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            Layout.fillWidth: true
                            font.family: Theme.font
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            color: Theme.c("fg", "#cdd6f4")
                            text: toast.modelData.summary
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: text !== ""
                            font.family: Theme.font
                            font.pixelSize: 12
                            color: Theme.c("muted", "#6c7086")
                            text: toast.modelData.body
                            wrapMode: Text.Wrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                            textFormat: Text.StyledText
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignTop
                        font.family: Theme.font
                        font.pixelSize: 12
                        color: closeMouse.containsMouse
                            ? Theme.c("danger", "#f38ba8")
                            : Theme.c("muted", "#6c7086")
                        text: "✕"

                        MouseArea {
                            id: closeMouse
                            anchors.fill: parent
                            anchors.margins: -6
                            hoverEnabled: true
                            onClicked: toast.modelData.dismiss()
                        }
                    }
                }

                RowLayout {
                    visible: actionRepeater.count > 0
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        id: actionRepeater
                        model: toast.modelData.actions
                            .filter(a => a.identifier !== "default")

                        delegate: Rectangle {
                            required property var modelData

                            implicitWidth: actionLabel.implicitWidth + 24
                            implicitHeight: 28
                            radius: 14
                            color: actionMouse.containsMouse
                                ? Qt.alpha(Theme.c("accent", "#89b4fa"), 0.25)
                                : Qt.alpha(Theme.c("panel_alt", "#1e1e2e"), 0.8)
                            border.width: 1
                            border.color: Qt.alpha(Theme.c("border", "#313244"), 0.8)

                            Text {
                                id: actionLabel
                                anchors.centerIn: parent
                                font.family: Theme.font
                                font.pixelSize: 11
                                color: Theme.c("fg", "#cdd6f4")
                                text: parent.modelData.text
                            }

                            MouseArea {
                                id: actionMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: parent.modelData.invoke()
                            }
                        }
                    }
                }
            }
        }
    }
}
