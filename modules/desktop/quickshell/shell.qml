import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    // "clock" (pill), "apps" (launcher), "menu" (dmenu picker for scripts)
    property string mode: "clock"
    readonly property bool open: mode !== "clock"
    property string query: ""
    property var menuItems: []
    property bool resultSent: false

    // Theme colors rendered by zen0x-generate-theme; reloads live on switch
    property var theme: ({})

    function c(name: string, fallback: string): string {
        return root.theme && root.theme[name] ? root.theme[name] : fallback;
    }

    function openApps() {
        root.query = "";
        root.mode = "apps";
    }

    function closeIsland() {
        if (root.mode === "menu" && !root.resultSent)
            sendResult(-1);
        root.mode = "clock";
        root.query = "";
    }

    // zen0x-qsmenu blocks on this fifo; every menu close must answer
    function sendResult(idx: int) {
        root.resultSent = true;
        Quickshell.execDetached(["sh", "-c",
            "printf '%s\\n' " + idx + " > \"$XDG_RUNTIME_DIR/zen0x-menu/result\""]);
    }

    readonly property var results: {
        const q = root.query.toLowerCase().trim();

        if (root.mode === "menu") {
            let items = root.menuItems.map((text, idx) => ({ text, idx }));
            if (q !== "")
                items = items.filter(m => m.text.toLowerCase().includes(q));
            return items;
        }

        let list = DesktopEntries.applications.values.filter(a => !a.noDisplay);
        if (q !== "") {
            list = list.filter(a =>
                a.name.toLowerCase().includes(q)
                || (a.genericName || "").toLowerCase().includes(q));
            list.sort((a, b) => {
                const ap = a.name.toLowerCase().startsWith(q);
                const bp = b.name.toLowerCase().startsWith(q);
                if (ap !== bp)
                    return ap ? -1 : 1;
                return a.name.localeCompare(b.name);
            });
        } else {
            list.sort((a, b) => a.name.localeCompare(b.name));
        }
        return list;
    }

    function activate(item) {
        if (!item)
            return;
        if (root.mode === "menu")
            sendResult(item.idx);
        else
            item.execute();
        closeIsland();
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void {
            root.open ? root.closeIsland() : root.openApps();
        }
    }

    IpcHandler {
        target: "menu"

        function open(): void {
            menuProc.running = true;
        }
    }

    Process {
        id: menuProc
        command: ["cat", Quickshell.env("XDG_RUNTIME_DIR") + "/zen0x-menu/options"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.menuItems = text.split("\n").filter(l => l !== "");
                root.resultSent = false;
                root.query = "";
                root.mode = "menu";
            }
        }
    }

    FileView {
        id: themeFile
        path: Quickshell.env("HOME") + "/.config/quickshell/colors.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                root.theme = JSON.parse(text());
            } catch (e) {
                root.theme = {};
            }
        }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    PanelWindow {
        id: bar
        anchors.top: true
        // Match hyprland gaps_out so the gap above the pill equals the gap
        // to the tiled windows below it
        margins.top: 20
        // Surface never resizes (resizing mid-animation smears frames);
        // the island morphs inside it and the mask keeps clicks passing
        // through everywhere else
        implicitWidth: 640
        implicitHeight: 500
        exclusiveZone: 42
        color: "transparent"

        WlrLayershell.keyboardFocus: root.open
            ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        mask: Region {
            item: island
        }

        Rectangle {
            id: island
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.mode === "clock" ? pillLabel.implicitWidth + 48
                 : root.mode === "menu" ? 380
                 : 600
            height: root.mode === "clock" ? 42
                  : root.mode === "menu"
                      ? Math.min(74 + root.results.length * 46, 480)
                      : 480
            radius: root.open ? 24 : height / 2
            color: Qt.alpha(root.c("panel_alt", "#1e1e2e"), 0.65)
            border.width: 1
            border.color: root.c("accent", "#89b4fa")
            clip: true

            Behavior on width {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutQuint
                }
            }
            Behavior on height {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutQuint
                }
            }
            Behavior on radius {
                NumberAnimation {
                    duration: 400
                    easing.type: Easing.OutQuint
                }
            }

            // ── Pill (clock) ───────────────────────────────────────

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                visible: !root.open
                onClicked: root.openApps()
            }

            Text {
                id: pillLabel
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: (42 - height) / 2
                font.family: "JetBrainsMono Nerd Font Propo"
                font.pixelSize: 16
                font.weight: Font.DemiBold
                color: root.c("fg", "#cdd6f4")
                opacity: root.open ? 0 : 1
                visible: opacity > 0
                text: Qt.formatDateTime(clock.date,
                    mouse.containsMouse ? "hh:mm AP  ·  ddd, MMM d" : "hh:mm AP")

                Behavior on opacity {
                    NumberAnimation {
                        duration: 150
                    }
                }

                // Fade through the text swap so the long string doesn't pop
                // in before the pill has grown around it
                Behavior on text {
                    SequentialAnimation {
                        NumberAnimation { target: pillLabel; property: "opacity"; to: 0; duration: 90 }
                        PropertyAction {}
                        NumberAnimation { target: pillLabel; property: "opacity"; to: 1; duration: 220; easing.type: Easing.OutCubic }
                    }
                }
            }

            // ── Search + results (apps and menu modes) ─────────────

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 10
                opacity: root.open ? 1 : 0
                visible: opacity > 0
                enabled: root.open

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
                        font.family: "JetBrainsMono Nerd Font Propo"
                        font.pixelSize: 16
                        color: root.c("muted", "#6c7086")
                        text: "󰍉"
                    }

                    TextInput {
                        id: search
                        Layout.fillWidth: true
                        font.family: "JetBrainsMono Nerd Font Propo"
                        font.pixelSize: 15
                        font.weight: Font.Medium
                        color: root.c("fg", "#cdd6f4")
                        selectionColor: Qt.alpha(root.c("accent", "#89b4fa"), 0.4)
                        selectedTextColor: root.c("fg", "#cdd6f4")
                        clip: true
                        text: root.query
                        onTextEdited: {
                            root.query = text;
                            list.currentIndex = 0;
                        }

                        Text {
                            anchors.fill: parent
                            visible: search.text === ""
                            font: search.font
                            color: root.c("muted", "#6c7086")
                            text: root.mode === "menu" ? "Filter…" : "Search apps…"
                        }

                        Keys.onEscapePressed: root.closeIsland()
                        Keys.onUpPressed: list.currentIndex = Math.max(0, list.currentIndex - 1)
                        Keys.onDownPressed: list.currentIndex =
                            Math.min(list.count - 1, list.currentIndex + 1)
                        onAccepted: root.activate(root.results[list.currentIndex])
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: Qt.alpha(root.c("border", "#313244"), 0.8)
                }

                ListView {
                    id: list
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: root.results
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

                        readonly property bool isMenu: root.mode === "menu"

                        width: list.width
                        height: 44
                        radius: 12
                        color: index === list.currentIndex
                            ? Qt.alpha(root.c("accent", "#89b4fa"), 0.18)
                            : entryMouse.containsMouse
                                ? Qt.alpha(root.c("panel_alt", "#1e1e2e"), 0.6)
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
                                font.family: "JetBrainsMono Nerd Font Propo"
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                color: root.c("fg", "#cdd6f4")
                                text: isMenu ? modelData.text : modelData.name
                                elide: Text.ElideRight
                            }

                            Text {
                                visible: !isMenu
                                font.family: "JetBrainsMono Nerd Font Propo"
                                font.pixelSize: 11
                                color: root.c("muted", "#6c7086")
                                text: isMenu ? "" : (modelData.genericName || "")
                                elide: Text.ElideRight
                                Layout.maximumWidth: 180
                            }
                        }

                        MouseArea {
                            id: entryMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.activate(modelData)
                        }
                    }
                }
            }
        }

        Connections {
            target: root
            function onModeChanged() {
                if (root.open)
                    search.forceActiveFocus();
            }
        }
    }
}
