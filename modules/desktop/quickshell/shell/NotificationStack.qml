import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

Item {
    id: toastRoot

    readonly property var notif: ShellState.notifs.values.length > 0
        ? ShellState.notifs.values[ShellState.notifs.values.length - 1]
        : null

    implicitHeight: notif !== null ? (toastContent.implicitHeight + 24) : 0

    anchors.top: parent.top
    anchors.topMargin: 12
    anchors.horizontalCenter: parent.horizontalCenter
    width: parent.width - 24

    opacity: ShellState.hasNotifs && !ShellState.open && !ShellState.osdVisible ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    Timer {
        interval: toastRoot.notif && toastRoot.notif.expireTimeout > 0
            ? toastRoot.notif.expireTimeout : 6000
        running: toastRoot.notif !== null
            && toastRoot.notif.urgency !== NotificationUrgency.Critical
        onTriggered: if (toastRoot.notif) toastRoot.notif.expire()
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (!toastRoot.notif) return;
            const def = toastRoot.notif.actions.find(a => a.identifier === "default");
            if (def) def.invoke();
            else toastRoot.notif.dismiss();
        }
    }

    ColumnLayout {
        id: toastContent
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            Image {
                readonly property string src: toastRoot.notif
                    ? (toastRoot.notif.image !== ""
                        ? toastRoot.notif.image
                        : toastRoot.notif.appIcon !== ""
                            ? Quickshell.iconPath(toastRoot.notif.appIcon, true)
                            : "")
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
                    text: toastRoot.notif ? toastRoot.notif.summary : ""
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    visible: text !== ""
                    font.family: Theme.font
                    font.pixelSize: 12
                    color: Theme.c("muted", "#6c7086")
                    text: toastRoot.notif ? toastRoot.notif.body : ""
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
                    onClicked: if (toastRoot.notif) toastRoot.notif.dismiss()
                }
            }
        }

        RowLayout {
            visible: actionRepeater.count > 0
            Layout.fillWidth: true
            spacing: 8

            Repeater {
                id: actionRepeater
                model: toastRoot.notif
                    ? toastRoot.notif.actions.filter(a => a.identifier !== "default")
                    : []

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
