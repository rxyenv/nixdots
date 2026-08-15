import QtQuick

QtObject {
    readonly property color transparent: "transparent"
    readonly property color scrim: Qt.rgba(0.01, 0.025, 0.03, 0.48)
    readonly property color background: "#061115"
    readonly property color surface: Qt.rgba(0.035, 0.075, 0.085, 0.72)
    readonly property color panel: Qt.rgba(0.045, 0.09, 0.10, 0.76)
    readonly property color panelStrong: Qt.rgba(0.045, 0.085, 0.095, 0.9)
    readonly property color panelAlt: Qt.rgba(0.12, 0.16, 0.17, 0.72)
    readonly property color elevated: Qt.rgba(0.18, 0.23, 0.24, 0.78)
    readonly property color border: Qt.rgba(0.78, 0.88, 0.92, 0.2)
    readonly property color borderBright: Qt.rgba(0.85, 0.94, 0.98, 0.34)
    readonly property color foreground: "#E7EDF2"
    readonly property color muted: "#9BA8AF"
    readonly property color subtle: "#65747B"
    readonly property color accent: "#72B7D3"
    readonly property color accentSoft: Qt.rgba(0.45, 0.72, 0.83, 0.2)
    readonly property color danger: "#F38BA8"
    readonly property color success: "#8BD5CA"
    readonly property color warning: "#FFD16D"

    readonly property int barHeight: 48
    readonly property int radius: 16
    readonly property int radiusLarge: 24
    readonly property int spacing: 10
    readonly property int durationFast: 140
    readonly property int duration: 240
    readonly property string fontFamily: "Maple Mono NF"
}
