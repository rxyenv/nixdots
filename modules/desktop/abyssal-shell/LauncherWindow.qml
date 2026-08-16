import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    required property var modelData
    required property var shell

    readonly property Theme palette: Theme {}
    property string query: ""
    property int selectedIndex: 0
    property bool surfaceRequested: shell.surfaceVisible("launcher", modelData)

    function filteredApps() {
        const needle = query.trim().toLowerCase()
        const apps = DesktopEntries.applications.values.filter(app => !app.noDisplay)
        const filtered = needle.length === 0 ? apps : apps.filter(app => {
            const haystack = (app.name + " " + app.genericName + " " + app.id).toLowerCase()
            return haystack.indexOf(needle) >= 0
        })

        filtered.sort((a, b) => {
            const an = a.name.toLowerCase()
            const bn = b.name.toLowerCase()
            const aStarts = needle.length > 0 && an.indexOf(needle) === 0
            const bStarts = needle.length > 0 && bn.indexOf(needle) === 0
            if (aStarts !== bStarts) return aStarts ? -1 : 1
            return an.localeCompare(bn)
        })
        return filtered.slice(0, 10)
    }

    function launchSelected() {
        const app = appsModel.values[selectedIndex]
        if (!app) return
        app.execute()
        shell.closeSurfaces()
    }

    screen: modelData
    visible: surfaceRequested
    implicitWidth: Math.min(520, modelData.width - 32)
    implicitHeight: Math.min(520, Math.max(40, results.contentHeight) + 68)
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.namespace: "abyssal-launcher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    onSurfaceRequestedChanged: {
        if (surfaceRequested) {
            query = ""
            selectedIndex = 0
            focusTimer.restart()
        }
    }

    Rectangle {
        id: card
        opacity: 0.97
        anchors.fill: parent
        radius: root.palette.radiusLarge
        color: Qt.rgba(0.118, 0.118, 0.180, 0.97)
        border.width: 1
        border.color: root.palette.border

        MouseArea { anchors.fill: parent; acceptedButtons: Qt.NoButton }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 34

                TextInput {
                    id: search
                    Layout.fillWidth: true
                    text: root.query
                    color: root.palette.foreground
                    selectionColor: root.palette.accent
                    selectedTextColor: root.palette.background
                    font.family: root.palette.fontFamily
                    font.pixelSize: 14
                    clip: true

                    onTextChanged: {
                        root.query = text
                        root.selectedIndex = 0
                    }

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) {
                            root.shell.closeSurfaces()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Down) {
                            root.selectedIndex = Math.min(root.selectedIndex + 1, appsModel.values.length - 1)
                            event.accepted = true
                        } else if (event.key === Qt.Key_Up) {
                            root.selectedIndex = Math.max(root.selectedIndex - 1, 0)
                            event.accepted = true
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.launchSelected()
                            event.accepted = true
                        }
                    }

                    Text {
                        visible: search.text.length === 0
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Search applications"
                        color: root.palette.subtle
                        font: search.font
                    }
                }

            }

            ListView {
                id: results
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 2
                model: ScriptModel {
                    id: appsModel
                    values: root.filteredApps()
                }
                currentIndex: root.selectedIndex

                delegate: Rectangle {
                    id: result
                    required property var modelData
                    required property int index

                    width: ListView.view.width
                    height: 40
                    radius: root.palette.radius
                    color: index === root.selectedIndex ? root.palette.accentSoft
                        : hover.containsMouse ? root.palette.hover : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        Image {
                            Layout.preferredWidth: 22
                            Layout.preferredHeight: 22
                            source: Quickshell.iconPath(result.modelData.icon, "application-x-executable")
                            sourceSize.width: 22
                            sourceSize.height: 22
                            smooth: true
                        }

                        Text {
                            Layout.fillWidth: true
                            text: result.modelData.name
                            color: root.palette.foreground
                            elide: Text.ElideRight
                            font.family: root.palette.fontFamily
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                        }

                    }

                    MouseArea {
                        id: hover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: root.selectedIndex = result.index
                        onClicked: {
                            result.modelData.execute()
                            root.shell.closeSurfaces()
                        }
                    }
                }

                Text {
                    visible: appsModel.values.length === 0
                    anchors.centerIn: parent
                    text: "No applications found"
                    color: root.palette.muted
                    font.family: root.palette.fontFamily
                    font.pixelSize: 13
                }
            }

        }
    }

    Timer {
        id: focusTimer
        interval: 25
        onTriggered: search.forceActiveFocus()
    }

}
