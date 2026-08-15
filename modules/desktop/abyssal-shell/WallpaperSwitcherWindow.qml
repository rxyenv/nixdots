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
            "awww", "img", "--transition-type", "random",
            "--transition-duration", "1", path
        ])
        shell.closeSurfaces()
    }

    screen: modelData
    visible: shell.surfaceVisible("wallpaper", modelData)
    color: "transparent"
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

    Item {
        id: card
        anchors.centerIn: parent
        width: Math.min(780, parent.width - 24)
        height: Math.min(400, parent.height - 40)

        ListView {
                id: deck
                anchors.fill: parent
                orientation: ListView.Horizontal
                clip: true
                focus: root.visible
                snapMode: ListView.SnapToItem
                spacing: -125
                highlightRangeMode: ListView.StrictlyEnforceRange
                preferredHighlightBegin: width / 2 - 120
                preferredHighlightEnd: width / 2 + 120
                model: root.wallpapers

                Keys.onReturnPressed: if (currentItem) root.apply(currentItem.modelData)
                Keys.onEnterPressed: if (currentItem) root.apply(currentItem.modelData)

                delegate: Item {
                    required property string modelData
                    required property int index
                    width: 240
                    height: 380
                    z: 100 - Math.abs(index - deck.currentIndex)

                    Rectangle {
                        id: card
                        anchors.centerIn: parent
                        width: 220
                        height: 340
                        radius: 18
                        clip: true
                        scale: index === deck.currentIndex ? 1.0 : 0.78
                        rotation: index === deck.currentIndex ? 0 : (index < deck.currentIndex ? -12 : 12)
                        color: hover.containsMouse || index === deck.currentIndex
                            ? root.palette.accentSoft : Qt.rgba(1, 1, 1, 0.04)
                        border.width: 1
                        border.color: index === deck.currentIndex ? root.palette.accent : root.palette.border

                        Behavior on scale { NumberAnimation { duration: root.palette.duration; easing.type: Easing.OutBack } }
                        Behavior on rotation { NumberAnimation { duration: root.palette.duration; easing.type: Easing.OutCubic } }

                        Accessible.name: modelData.substring(modelData.lastIndexOf("/") + 1)
                        Accessible.role: Accessible.Button

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 3
                            radius: 15
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: "file://" + modelData
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: true
                                smooth: true
                            }
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.margins: 3
                            height: 42
                            radius: 14
                            color: Qt.rgba(0, 0, 0, 0.68)

                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 10
                                verticalAlignment: Text.AlignVCenter
                                text: modelData.substring(modelData.lastIndexOf("/") + 1)
                                color: root.palette.foreground
                                elide: Text.ElideMiddle
                                font.family: root.palette.fontFamily
                                font.pixelSize: 10
                            }
                        }

                        MouseArea {
                            id: hover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.apply(modelData)
                        }
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
