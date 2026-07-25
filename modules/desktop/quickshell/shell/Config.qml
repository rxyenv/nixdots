pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // Appearance
    property string font: "JetBrainsMono Nerd Font Propo"
    property string islandColor: "#000000"
    property int clockFontSize: 16
    property int launcherFontSize: 15
    property int launcherItemFontSize: 14
    property int launcherSubtextSize: 11

    // Layout
    property int topMargin: 20
    property int pillHeight: 42
    property int osdWidth: 280
    property int notifWidth: 420
    property int launcherWidth: 600
    property int menuWidth: 380

    // Animation
    property int animDuration: 400

    // Clock
    property bool use24h: false
    property bool showDate: true

    // OSD
    property int osdDisplayMs: 1500

    function save() {
        const data = {
            appearance: {
                font: root.font,
                islandColor: root.islandColor,
                clockFontSize: root.clockFontSize,
                launcherFontSize: root.launcherFontSize,
                launcherItemFontSize: root.launcherItemFontSize,
                launcherSubtextSize: root.launcherSubtextSize
            },
            layout: {
                topMargin: root.topMargin,
                pillHeight: root.pillHeight,
                osdWidth: root.osdWidth,
                notifWidth: root.notifWidth,
                launcherWidth: root.launcherWidth,
                menuWidth: root.menuWidth
            },
            animation: {
                duration: root.animDuration
            },
            clock: {
                use24h: root.use24h,
                showDate: root.showDate
            },
            osd: {
                displayMs: root.osdDisplayMs
            }
        };
        const b64 = btoa(JSON.stringify(data, null, 2));
        Quickshell.execDetached(["sh", "-c",
            "printf '%s' '" + b64 + "' | base64 -d > \"$HOME/.config/quickshell/settings.json\""]);
    }

    FileView {
        path: Quickshell.env("HOME") + "/.config/quickshell/settings.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                const d = JSON.parse(text());
                const a = d.appearance || {};
                const l = d.layout || {};
                const n = d.animation || {};
                const c = d.clock || {};
                const o = d.osd || {};
                if (a.font !== undefined) root.font = a.font;
                if (a.islandColor !== undefined) root.islandColor = a.islandColor;
                if (a.clockFontSize !== undefined) root.clockFontSize = a.clockFontSize;
                if (a.launcherFontSize !== undefined) root.launcherFontSize = a.launcherFontSize;
                if (a.launcherItemFontSize !== undefined) root.launcherItemFontSize = a.launcherItemFontSize;
                if (a.launcherSubtextSize !== undefined) root.launcherSubtextSize = a.launcherSubtextSize;
                if (l.topMargin !== undefined) root.topMargin = l.topMargin;
                if (l.pillHeight !== undefined) root.pillHeight = l.pillHeight;
                if (l.osdWidth !== undefined) root.osdWidth = l.osdWidth;
                if (l.notifWidth !== undefined) root.notifWidth = l.notifWidth;
                if (l.launcherWidth !== undefined) root.launcherWidth = l.launcherWidth;
                if (l.menuWidth !== undefined) root.menuWidth = l.menuWidth;
                if (n.duration !== undefined) root.animDuration = n.duration;
                if (c.use24h !== undefined) root.use24h = c.use24h;
                if (c.showDate !== undefined) root.showDate = c.showDate;
                if (o.displayMs !== undefined) root.osdDisplayMs = o.displayMs;
            } catch (e) {}
        }
    }
}
