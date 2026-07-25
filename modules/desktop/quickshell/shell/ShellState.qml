pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

// All shell state and IPC; views bind to this and stay dumb
Singleton {
    id: root

    // "clock" (pill), "apps" (launcher), "menu" (dmenu picker), "settings"
    property string mode: "clock"
    readonly property bool open: mode !== "clock"
    property string query: ""
    property var menuItems: []
    property bool resultSent: false

    readonly property var notifs: notifServer.trackedNotifications
    readonly property bool hasNotifs: notifs.values.length > 0
    readonly property bool hasCritical: notifs.values
        .some(n => n.urgency === NotificationUrgency.Critical)

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

    function openApps() {
        root.query = "";
        root.mode = "apps";
    }

    function openSettings() {
        root.mode = "settings";
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

    Timer {
        id: osdTimer
        interval: Config.osdDisplayMs
    }

    NotificationServer {
        id: notifServer
        actionsSupported: true
        bodySupported: true
        imageSupported: true
        onNotification: notif => notif.tracked = true
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

    IpcHandler {
        target: "settings"

        function open(): void {
            root.openSettings();
        }
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
}
