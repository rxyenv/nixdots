import QtQuick
import QtQuick.Layouts

GlassPanel {
    id: root

    signal clicked

    property string icon: ""
    property string label: ""
    property string detail: ""
    property bool checked: false
    property bool accent: false
    property bool compact: false

    palette: Theme {}
    radius: compact ? 12 : 15
    elevated: false

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: root.checked || root.accent ? root.palette.accentSoft : mouse.containsMouse ? Qt.rgba(1, 1, 1, 0.07) : "transparent"

        Behavior on color { ColorAnimation { duration: root.palette.durationFast } }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: root.compact ? 10 : 14
        anchors.rightMargin: root.compact ? 10 : 14
        spacing: 11

        Text {
            text: root.icon
            color: root.checked || root.accent ? root.palette.accent : root.palette.foreground
            font.family: root.palette.fontFamily
            font.pixelSize: root.compact ? 14 : 19
        }

        ColumnLayout {
            visible: root.label.length > 0
            Layout.fillWidth: true
            spacing: 1

            Text {
                Layout.fillWidth: true
                text: root.label
                color: root.palette.foreground
                elide: Text.ElideRight
                font.family: root.palette.fontFamily
                font.pixelSize: root.compact ? 11 : 13
                font.weight: Font.DemiBold
            }

            Text {
                visible: root.detail.length > 0
                Layout.fillWidth: true
                text: root.detail
                color: root.palette.muted
                elide: Text.ElideRight
                font.family: root.palette.fontFamily
                font.pixelSize: 10
            }
        }
    }

    scale: mouse.pressed ? 0.96 : mouse.containsMouse ? 1.015 : 1
    Behavior on scale { NumberAnimation { duration: root.palette.durationFast; easing.type: Easing.OutCubic } }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
