pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Theme colors rendered by zen0x-generate-theme; reloads live on switch
Singleton {
    id: root

    property var theme: ({})

    function c(name: string, fallback: string): string {
        if (!Config.useThemeColors) {
            if (name === "bg")        return Config.colorBg;
            if (name === "panel")     return Config.colorPanel;
            if (name === "panel_alt") return Config.colorPanelAlt;
            if (name === "fg")        return Config.colorFg;
            if (name === "muted")     return Config.colorMuted;
            if (name === "accent")    return Config.colorAccent;
            if (name === "danger")    return Config.colorDanger;
            if (name === "border")    return Config.colorBorder;
            if (name === "success")   return Config.colorSuccess;
            if (name === "warning")   return Config.colorWarning;
            return fallback;
        }
        return root.theme && root.theme[name] ? root.theme[name] : fallback;
    }

    property string font: Config.font

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
