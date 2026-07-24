pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Theme colors rendered by zen0x-generate-theme; reloads live on switch
Singleton {
    id: root

    property var theme: ({})

    function c(name: string, fallback: string): string {
        return root.theme && root.theme[name] ? root.theme[name] : fallback;
    }

    readonly property string font: "JetBrainsMono Nerd Font Propo"

    FileView {
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
}
