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
    radius: root.palette.radius
    elevated: false

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: root.checked || root.accent ? root.palette.accentSoft
            : mouse.containsMouse ? root.palette.hover : "transparent"

    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 8

        Text {
            text: root.icon
            color: root.checked || root.accent ? root.palette.accent : root.palette.foreground
            font.family: root.palette.fontFamily
            font.pixelSize: root.compact ? 13 : 16
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

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
