import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    required property var modelData
    required property var shell

    readonly property Theme palette: Theme {}
    property var wallpapers: []

    function refresh() {
        if (!wallpaperProcess.running) wallpaperProcess.running = true
    }

    function apply(path) {
        Quickshell.execDetached([
            "awww", "img", "--transition-type", "none", path
        ])
        shell.closeSurfaces()
    }

    screen: modelData
    visible: shell.surfaceVisible("wallpaper", modelData)
    color: palette.scrim
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; left: true; right: true }
    WlrLayershell.namespace: "abyssal-wallpaper-switcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    onVisibleChanged: if (visible) refresh()

    Process {
        id: wallpaperProcess
        command: ["sh", "-c", "find \"$HOME/Pictures/Wallpapers\" -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) -print 2>/dev/null | sort"]
        stdout: StdioCollector { id: wallpaperOutput }
        onExited: {
            root.wallpapers = wallpaperOutput.text.trim().length === 0
                ? [] : wallpaperOutput.text.trim().split("\n")
        }
    }

    Shortcut {
        sequence: "Escape"
        onActivated: root.shell.closeSurfaces()
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.shell.closeSurfaces()
    }

    GlassPanel {
        id: card
        opacity: 0.97
        anchors.centerIn: parent
        width: Math.min(760, parent.width - 16)
        height: Math.min(520, parent.height - 16)
        strong: true

        MouseArea { anchors.fill: parent; acceptedButtons: Qt.NoButton }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            Text {
                text: "Wallpapers"
                color: root.palette.foreground
                font.family: root.palette.fontFamily
                font.pixelSize: 14
                font.weight: Font.DemiBold
            }

            GridView {
                id: grid
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                focus: root.visible
                cellWidth: 184
                cellHeight: 124
                model: root.wallpapers

                Keys.onReturnPressed: if (currentItem) root.apply(currentItem.modelData)
                Keys.onEnterPressed: if (currentItem) root.apply(currentItem.modelData)

                delegate: Rectangle {
                    required property string modelData
                    required property int index
                    width: grid.cellWidth - 6
                    height: grid.cellHeight - 6
                    radius: root.palette.radius
                    clip: true
                    color: hover.containsMouse || GridView.isCurrentItem
                        ? root.palette.accentSoft : root.palette.panel
                    border.width: GridView.isCurrentItem ? 1 : 0
                    border.color: root.palette.accent

                    Accessible.name: modelData.substring(modelData.lastIndexOf("/") + 1)
                    Accessible.role: Accessible.Button

                    Image {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        height: parent.height - 26
                        source: "file://" + modelData
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                        smooth: true
                    }

                    Text {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6
                        height: 26
                        verticalAlignment: Text.AlignVCenter
                        text: modelData.substring(modelData.lastIndexOf("/") + 1)
                        color: root.palette.foreground
                        elide: Text.ElideMiddle
                        font.family: root.palette.fontFamily
                        font.pixelSize: 9
                    }

                    MouseArea {
                        id: hover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: grid.currentIndex = index
                        onClicked: root.apply(modelData)
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: root.wallpapers.length === 0
                    text: "No wallpapers found\nAdd images to ~/Pictures/Wallpapers"
                    horizontalAlignment: Text.AlignHCenter
                    color: root.palette.muted
                    font.family: root.palette.fontFamily
                    font.pixelSize: 12
                }
            }
        }
    }
}
