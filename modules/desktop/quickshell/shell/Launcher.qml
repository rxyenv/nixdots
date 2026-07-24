import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

// Search + results (apps and menu modes)
ColumnLayout {
    function focusSearch() {
        search.forceActiveFocus();
    }

    anchors.fill: parent
    anchors.margins: 16
    spacing: 10
    opacity: ShellState.open ? 1 : 0
    visible: opacity > 0
    enabled: ShellState.open

    Behavior on opacity {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 6
        Layout.leftMargin: 10
        Layout.rightMargin: 10
        spacing: 10

        Text {
            font.family: Theme.font
            font.pixelSize: 16
            color: Theme.c("muted", "#6c7086")
            text: "󰍉"
        }

        TextInput {
            id: search
            Layout.fillWidth: true
            font.family: Theme.font
            font.pixelSize: 15
            font.weight: Font.Medium
            color: Theme.c("fg", "#cdd6f4")
            selectionColor: Qt.alpha(Theme.c("accent", "#89b4fa"), 0.4)
            selectedTextColor: Theme.c("fg", "#cdd6f4")
            clip: true
            text: ShellState.query
            onTextEdited: {
                ShellState.query = text;
                list.currentIndex = 0;
            }

            Text {
                anchors.fill: parent
                visible: search.text === ""
                font: search.font
                color: Theme.c("muted", "#6c7086")
                text: ShellState.mode === "menu" ? "Filter…" : "Search apps…"
            }

            Keys.onEscapePressed: ShellState.closeIsland()
            Keys.onUpPressed: list.currentIndex = Math.max(0, list.currentIndex - 1)
            Keys.onDownPressed: list.currentIndex =
                Math.min(list.count - 1, list.currentIndex + 1)
            onAccepted: ShellState.activate(ShellState.results[list.currentIndex])
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        color: Qt.alpha(Theme.c("border", "#313244"), 0.8)
    }

    ListView {
        id: list
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: ShellState.results
        currentIndex: 0
        clip: true
        spacing: 2
        boundsBehavior: Flickable.StopAtBounds
        highlightMoveDuration: 120
        highlightResizeDuration: 0

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }

        delegate: Rectangle {
            required property var modelData
            required property int index

            readonly property bool isMenu: ShellState.mode === "menu"

            width: list.width
            height: 44
            radius: 12
            color: index === list.currentIndex
                ? Qt.alpha(Theme.c("accent", "#89b4fa"), 0.18)
                : entryMouse.containsMouse
                    ? Qt.alpha(Theme.c("panel_alt", "#1e1e2e"), 0.6)
                    : "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 12

                Image {
                    visible: !isMenu
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    sourceSize.width: 24
                    sourceSize.height: 24
                    asynchronous: true
                    source: !isMenu && modelData.icon
                        ? Quickshell.iconPath(modelData.icon, true) : ""
                }

                Text {
                    Layout.fillWidth: true
                    font.family: Theme.font
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: Theme.c("fg", "#cdd6f4")
                    text: isMenu ? modelData.text : modelData.name
                    elide: Text.ElideRight
                }

                Text {
                    visible: !isMenu
                    font.family: Theme.font
                    font.pixelSize: 11
                    color: Theme.c("muted", "#6c7086")
                    text: isMenu ? "" : (modelData.genericName || "")
                    elide: Text.ElideRight
                    Layout.maximumWidth: 180
                }
            }

            MouseArea {
                id: entryMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: ShellState.activate(modelData)
            }
        }
    }
}
