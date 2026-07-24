import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Wayland

ShellRoot {
    id: root

    // "clock" (pill), "apps" (launcher), "menu" (dmenu picker for scripts)
    property string mode: "clock"
    readonly property bool open: mode !== "clock"
    property string query: ""
    readonly property bool hasNotifs: notifServer.trackedNotifications.values.length > 0

    // Transient OSD (volume / mic / brightness / caps lock) shown in the pill
    property string osdKind: ""
    property int osdValue: 0
    property bool osdFlag: false
    readonly property bool osdVisible: osdTimer.running

    function showOsd(kind: string, value: int, flag: bool) {
        osdKind = kind;
        osdValue = value;
        osdFlag = flag;
        osdTimer.restart();
    }

    Timer {
        id: osdTimer
        interval: 1500
    }

    IpcHandler {
        target: "osd"

        function volume(pct: int, muted: bool): void {
            root.showOsd("volume", pct, muted);
        }
        function mic(pct: int, muted: bool): void {
            root.showOsd("mic", pct, muted);
        }
        function brightness(pct: int): void {
            root.showOsd("brightness", pct, false);
        }
        function caps(on: bool): void {
            root.showOsd("caps", 0, on);
        }
    }
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
            width: root.mode === "clock"
                     ? (root.osdVisible ? 280
                        : root.hasNotifs ? 420
                        : pillLabel.implicitWidth + 48)
                 : root.mode === "menu" ? 380
                 : 600
            height: root.mode === "clock"
                      ? (!root.osdVisible && root.hasNotifs
                          ? Math.min(toastColumn.implicitHeight + 24, 480)
                          : 42)
                  : root.mode === "menu"
                      ? Math.min(74 + root.results.length * 46, 480)
                      : 480
            radius: root.open || (root.hasNotifs && !root.osdVisible)
                ? 24 : height / 2
            color: Qt.alpha(root.c("panel_alt", "#1e1e2e"), 0.65)
            border.width: 1
            border.color: notifServer.trackedNotifications.values
                    .some(n => n.urgency === NotificationUrgency.Critical)
                ? root.c("danger", "#f38ba8")
                : root.c("accent", "#89b4fa")
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
                visible: !root.open && !root.hasNotifs
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
                opacity: root.open || root.hasNotifs || root.osdVisible ? 0 : 1
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

            // ── OSD (volume / mic / brightness / caps) ─────────────

            RowLayout {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                height: 42
                spacing: 12
                opacity: root.osdVisible && !root.open ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }

                Text {
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 16
                    color: root.osdFlag
                        ? root.c("danger", "#f38ba8")
                        : root.c("fg", "#cdd6f4")
                    text: root.osdKind === "volume" ? (root.osdFlag ? "󰝟" : "󰕾")
                        : root.osdKind === "mic" ? (root.osdFlag ? "󰍭" : "󰍬")
                        : root.osdKind === "brightness" ? "󰃠"
                        : "󰪛"
                }

                Rectangle {
                    visible: root.osdKind !== "caps"
                    Layout.preferredWidth: 150
                    Layout.alignment: Qt.AlignVCenter
                    height: 6
                    radius: 3
                    color: Qt.alpha(root.c("border", "#313244"), 0.8)

                    Rectangle {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width * Math.min(root.osdValue, 100) / 100
                        height: parent.height
                        radius: parent.radius
                        color: root.osdFlag
                            ? root.c("muted", "#6c7086")
                            : root.c("accent", "#89b4fa")

                        Behavior on width {
                            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                        }
                    }
                }

                Text {
                    font.family: "JetBrainsMono Nerd Font Propo"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    color: root.c("fg", "#cdd6f4")
                    text: root.osdKind === "caps"
                        ? ("Caps Lock " + (root.osdFlag ? "on" : "off"))
                        : root.osdValue + "%"
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

        ColumnLayout {
            id: toastColumn
            anchors.top: parent.top
            anchors.topMargin: 12
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 24
            spacing: 10
            opacity: root.hasNotifs && !root.open && !root.osdVisible ? 1 : 0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            Repeater {
                model: notifServer.trackedNotifications

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
                        color: Qt.alpha(root.c("border", "#313244"), 0.8)
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
                                    font.family: "JetBrainsMono Nerd Font Propo"
                                    font.pixelSize: 14
                                    font.weight: Font.DemiBold
                                    color: root.c("fg", "#cdd6f4")
                                    text: toast.modelData.summary
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    visible: text !== ""
                                    font.family: "JetBrainsMono Nerd Font Propo"
                                    font.pixelSize: 12
                                    color: root.c("muted", "#6c7086")
                                    text: toast.modelData.body
                                    wrapMode: Text.Wrap
                                    maximumLineCount: 3
                                    elide: Text.ElideRight
                                    textFormat: Text.StyledText
                                }
                            }

                            Text {
                                Layout.alignment: Qt.AlignTop
                                font.family: "JetBrainsMono Nerd Font Propo"
                                font.pixelSize: 12
                                color: closeMouse.containsMouse
                                    ? root.c("danger", "#f38ba8")
                                    : root.c("muted", "#6c7086")
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
                                        ? Qt.alpha(root.c("accent", "#89b4fa"), 0.25)
                                        : Qt.alpha(root.c("panel_alt", "#1e1e2e"), 0.8)
                                    border.width: 1
                                    border.color: Qt.alpha(root.c("border", "#313244"), 0.8)

                                    Text {
                                        id: actionLabel
                                        anchors.centerIn: parent
                                        font.family: "JetBrainsMono Nerd Font Propo"
                                        font.pixelSize: 11
                                        color: root.c("fg", "#cdd6f4")
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
        }

        Connections {
            target: root
            function onModeChanged() {
                if (root.open)
                    search.forceActiveFocus();
            }
        }
    }

    // ── Notifications ──────────────────────────────────────────────

    NotificationServer {
        id: notifServer
        actionsSupported: true
        bodySupported: true
        imageSupported: true
        onNotification: notif => notif.tracked = true
    }
}
