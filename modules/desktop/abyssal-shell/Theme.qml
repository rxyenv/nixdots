import QtQuick

QtObject {
    readonly property color transparent: "transparent"
    readonly property color scrim: Qt.rgba(0.067, 0.067, 0.106, 0.97)
    readonly property color background: "#1E1E2E"
    readonly property color surface: Qt.rgba(0.094, 0.094, 0.145, 0.97)
    readonly property color panel: Qt.rgba(0.118, 0.118, 0.180, 0.97)
    readonly property color panelStrong: Qt.rgba(0.118, 0.118, 0.180, 0.97)
    readonly property color panelAlt: Qt.rgba(0.192, 0.196, 0.267, 0.97)
    readonly property color elevated: Qt.rgba(0.271, 0.278, 0.353, 0.97)
    readonly property color border: Qt.rgba(0.424, 0.439, 0.525, 0.97)
    readonly property color borderBright: Qt.rgba(0.576, 0.600, 0.698, 0.97)
    readonly property color foreground: "#CDD6F4"
    readonly property color muted: "#A6ADC8"
    readonly property color subtle: "#6C7086"
    readonly property color accent: "#89B4FA"
    readonly property color hover: "#313244"
    readonly property color accentSoft: "#3B4261"
    readonly property color danger: "#F38BA8"
    readonly property color dangerSoft: "#51313F"
    readonly property color success: "#A6E3A1"
    readonly property color warning: "#F9E2AF"
    readonly property color warningSoft: "#504832"

    readonly property int barHeight: 32
    readonly property int radius: 4
    readonly property int radiusLarge: 6
    readonly property int spacing: 6
    readonly property int durationFast: 0
    readonly property int duration: 0
    readonly property string fontFamily: "JetBrainsMono Nerd Font Propo"
}
