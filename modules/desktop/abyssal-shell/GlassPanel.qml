import QtQuick

Item {
    id: root

    default property alias content: contentItem.data
    property Theme palette: Theme {}
    property real radius: palette.radius
    property bool strong: false
    property bool elevated: false
    property bool bordered: true

    Rectangle {
        id: surface
        anchors.fill: parent
        radius: root.radius
        border.width: root.bordered ? 1 : 0
        border.color: root.palette.border
        color: root.strong ? root.palette.panelStrong : root.palette.panel
    }

    Item {
        id: contentItem
        anchors.fill: parent
    }
}
