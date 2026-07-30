import QtQuick
import Quickshell

// Clock label shown while the island is idle
Text {
    id: pillLabel

    property bool expanded: false

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    font.family: Theme.font
    font.pixelSize: Config.clockFontSize
    font.weight: Font.DemiBold
    color: "#ffffff"
    // Separate fade factor so the text-swap animation below never
    // stomps the show/hide binding
    property real textFade: 1
    opacity: (ShellState.open || ShellState.hasNotifs || ShellState.osdVisible ? 0 : 1)
        * textFade
    visible: opacity > 0

    readonly property string timeFormat: Config.use24h ? "HH:mm" : "hh:mm AP"
    text: Qt.formatDateTime(clock.date,
        expanded && Config.showDate
            ? timeFormat + "  ·  ddd, MMM d"
            : timeFormat)

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 150
        }
    }

    // Fade through the text swap so the long string doesn't pop
    // in before the pill has grown around it
    Behavior on text {
        SequentialAnimation {
            NumberAnimation { target: pillLabel; property: "textFade"; to: 0; duration: 90 }
            PropertyAction {}
            NumberAnimation { target: pillLabel; property: "textFade"; to: 1; duration: 220; easing.type: Easing.OutCubic }
        }
    }
}
