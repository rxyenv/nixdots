import QtQuick
import QtQuick.Layouts

// Transient volume / mic / brightness / caps overlay in the pill
RowLayout {
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    height: Config.pillHeight
    spacing: 12
    opacity: ShellState.osdVisible && !ShellState.open ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
        NumberAnimation { duration: 150 }
    }

    Text {
        font.family: Theme.font
        font.pixelSize: 16
        color: ShellState.osdFlag
            ? Theme.c("danger", "#f38ba8")
            : "#ffffff"
        text: ShellState.osdKind === "volume" ? (ShellState.osdFlag ? "󰝟" : "󰕾")
            : ShellState.osdKind === "mic" ? (ShellState.osdFlag ? "󰍭" : "󰍬")
            : ShellState.osdKind === "brightness" ? "󰃠"
            : "󰪛"
    }

    Rectangle {
        visible: ShellState.osdKind !== "caps"
        Layout.preferredWidth: 150
        Layout.alignment: Qt.AlignVCenter
        height: 6
        radius: 3
        color: Qt.alpha("#ffffff", 0.15)

        Rectangle {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width * Math.min(ShellState.osdValue, 100) / 100
            height: parent.height
            radius: parent.radius
            color: ShellState.osdFlag
                ? Theme.c("muted", "#6c7086")
                : Theme.c("accent", "#89b4fa")

            Behavior on width {
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }
        }
    }

    Text {
        font.family: Theme.font
        font.pixelSize: 13
        font.weight: Font.DemiBold
        color: "#ffffff"
        text: ShellState.osdKind === "caps"
            ? ("Caps Lock " + (ShellState.osdFlag ? "on" : "off"))
            : ShellState.osdValue + "%"
    }
}
