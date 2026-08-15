import QtQuick

Item {
    id: root

    default property alias content: contentItem.data
    property Theme palette: Theme {}
    property real radius: palette.radius
    property bool strong: false
    property bool elevated: true
    property bool bordered: true

    Rectangle {
        anchors.fill: surface
        anchors.topMargin: 7
        anchors.leftMargin: 3
        anchors.rightMargin: -3
        radius: root.radius
        color: Qt.rgba(0, 0, 0, root.elevated ? 0.32 : 0)
    }

    Rectangle {
        id: surface
        anchors.fill: parent
        radius: root.radius
        border.width: root.bordered ? 1 : 0
        border.color: root.palette.border
        gradient: Gradient {
            GradientStop { position: 0; color: root.strong ? root.palette.panelStrong : Qt.lighter(root.palette.panel, 1.08) }
            GradientStop { position: 0.52; color: root.strong ? root.palette.panelStrong : root.palette.panel }
            GradientStop { position: 1; color: root.strong ? Qt.darker(root.palette.panelStrong, 1.08) : Qt.darker(root.palette.panel, 1.08) }
        }

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 1
            height: 1
            radius: root.radius
            color: root.palette.borderBright
            opacity: root.bordered ? 0.7 : 0
        }
    }

    Item {
        id: contentItem
        anchors.fill: parent
    }
}
