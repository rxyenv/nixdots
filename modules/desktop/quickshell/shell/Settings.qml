import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

// Settings panel — open via: qs ipc call settings open
ColumnLayout {
    id: settingsRoot

    property int currentTab: 0

    anchors.fill: parent
    anchors.margins: 16
    spacing: 10
    opacity: ShellState.mode === "settings" ? 1 : 0
    visible: opacity > 0
    enabled: ShellState.mode === "settings"

    Behavior on opacity {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    Timer {
        id: saveTimer
        interval: 800
        onTriggered: Config.save()
    }

    function scheduleSave() {
        saveTimer.restart();
    }

    // ── Inline components ──────────────────────────────────────────────────

    component StepRow: RowLayout {
        id: stepRow
        property string labelText: ""
        property int value: 0
        property int minVal: 1
        property int maxVal: 9999
        property int step: 1
        signal changed(int val)

        Layout.fillWidth: true
        Layout.preferredHeight: 40

        Text {
            Layout.preferredWidth: 150
            font.family: Theme.font; font.pixelSize: 13
            color: Theme.c("fg", "#cdd6f4")
            text: stepRow.labelText
            verticalAlignment: Text.AlignVCenter
        }
        Item { Layout.fillWidth: true }
        Rectangle {
            width: 26; height: 26; radius: 8
            color: minHov.containsMouse && stepRow.value > stepRow.minVal
                ? Qt.alpha(Theme.c("muted", "#6c7086"), 0.22)
                : Qt.alpha(Theme.c("panel_alt", "#1e1e2e"), 0.7)
            Text {
                anchors.centerIn: parent
                font.family: Theme.font; font.pixelSize: 18; font.weight: Font.Light
                color: stepRow.value > stepRow.minVal
                    ? Theme.c("fg", "#cdd6f4") : Theme.c("muted", "#6c7086")
                text: "−"
            }
            MouseArea {
                id: minHov; anchors.fill: parent; hoverEnabled: true
                onClicked: if (stepRow.value > stepRow.minVal)
                    stepRow.changed(stepRow.value - stepRow.step)
            }
        }
        Text {
            Layout.preferredWidth: 46
            horizontalAlignment: Text.AlignHCenter
            font.family: Theme.font; font.pixelSize: 13; font.weight: Font.Medium
            color: Theme.c("fg", "#cdd6f4")
            text: stepRow.value
        }
        Rectangle {
            width: 26; height: 26; radius: 8
            color: plusHov.containsMouse && stepRow.value < stepRow.maxVal
                ? Qt.alpha(Theme.c("muted", "#6c7086"), 0.22)
                : Qt.alpha(Theme.c("panel_alt", "#1e1e2e"), 0.7)
            Text {
                anchors.centerIn: parent
                font.family: Theme.font; font.pixelSize: 18; font.weight: Font.Light
                color: stepRow.value < stepRow.maxVal
                    ? Theme.c("fg", "#cdd6f4") : Theme.c("muted", "#6c7086")
                text: "+"
            }
            MouseArea {
                id: plusHov; anchors.fill: parent; hoverEnabled: true
                onClicked: if (stepRow.value < stepRow.maxVal)
                    stepRow.changed(stepRow.value + stepRow.step)
            }
        }
    }

    component ToggleRow: RowLayout {
        id: toggleRow
        property string labelText: ""
        property bool checked: false
        signal changed(bool val)

        Layout.fillWidth: true
        Layout.preferredHeight: 40

        Text {
            Layout.fillWidth: true
            font.family: Theme.font; font.pixelSize: 13
            color: Theme.c("fg", "#cdd6f4")
            text: toggleRow.labelText
        }
        Rectangle {
            width: 44; height: 24; radius: 12
            color: toggleRow.checked
                ? Theme.c("accent", "#89b4fa")
                : Qt.alpha(Theme.c("muted", "#6c7086"), 0.3)
            Behavior on color { ColorAnimation { duration: 150 } }
            Rectangle {
                x: toggleRow.checked ? 22 : 2; y: 2
                width: 20; height: 20; radius: 10; color: "white"
                Behavior on x { NumberAnimation { duration: 150 } }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: toggleRow.changed(!toggleRow.checked)
            }
        }
    }

    component StringRow: RowLayout {
        id: strRow
        property string labelText: ""
        property string value: ""
        signal changed(string val)

        Layout.fillWidth: true
        Layout.preferredHeight: 40

        Text {
            Layout.preferredWidth: 150
            font.family: Theme.font; font.pixelSize: 13
            color: Theme.c("fg", "#cdd6f4")
            text: strRow.labelText
        }
        Rectangle {
            Layout.fillWidth: true; height: 28; radius: 8
            color: Qt.alpha(Theme.c("panel_alt", "#1e1e2e"), 0.8)
            border.color: Qt.alpha(Theme.c("border", "#313244"), 0.6); border.width: 1
            TextInput {
                anchors { fill: parent; leftMargin: 10; rightMargin: 10; topMargin: 5; bottomMargin: 5 }
                font.family: Theme.font; font.pixelSize: 12
                color: Theme.c("fg", "#cdd6f4")
                clip: true
                text: strRow.value
                onTextEdited: strRow.changed(text)
                Keys.onEscapePressed: ShellState.closeIsland()
            }
        }
    }

    component ColorRow: RowLayout {
        id: colorRow
        property string labelText: ""
        property string value: "#000000"
        signal changed(string val)

        Layout.fillWidth: true
        Layout.preferredHeight: 40

        Text {
            Layout.preferredWidth: 150
            font.family: Theme.font; font.pixelSize: 13
            color: Theme.c("fg", "#cdd6f4")
            text: colorRow.labelText
        }
        Rectangle {
            width: 22; height: 22; radius: 5
            color: colorRow.value
            border.color: Qt.alpha(Theme.c("border", "#313244"), 0.8); border.width: 1
        }
        Rectangle {
            Layout.fillWidth: true; height: 28; radius: 8
            color: Qt.alpha(Theme.c("panel_alt", "#1e1e2e"), 0.8)
            border.color: Qt.alpha(Theme.c("border", "#313244"), 0.6); border.width: 1
            TextInput {
                anchors { fill: parent; leftMargin: 10; rightMargin: 10; topMargin: 5; bottomMargin: 5 }
                font.family: Theme.font; font.pixelSize: 12
                color: Theme.c("fg", "#cdd6f4")
                clip: true
                text: colorRow.value
                onTextEdited: colorRow.changed(text)
                Keys.onEscapePressed: ShellState.closeIsland()
            }
        }
    }

    component Divider: Rectangle {
        Layout.fillWidth: true
        Layout.topMargin: 6
        Layout.bottomMargin: 2
        height: 1
        color: Qt.alpha(Theme.c("border", "#313244"), 0.5)
    }

    component SectionHead: Text {
        Layout.fillWidth: true
        Layout.topMargin: 8
        font.family: Theme.font; font.pixelSize: 10; font.weight: Font.SemiBold
        color: Theme.c("accent", "#89b4fa")
        opacity: 0.8
    }

    // ── Header ─────────────────────────────────────────────────────────────

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Text {
            font.family: Theme.font; font.pixelSize: 14
            color: Theme.c("muted", "#6c7086")
            text: "󰒓"
        }
        Text {
            Layout.fillWidth: true
            font.family: Theme.font; font.pixelSize: 15; font.weight: Font.SemiBold
            color: Theme.c("fg", "#cdd6f4")
            text: "Settings"
        }
        Rectangle {
            width: 24; height: 24; radius: 12
            color: xMouse.containsMouse
                ? Qt.alpha(Theme.c("muted", "#6c7086"), 0.2) : "transparent"
            Text {
                anchors.centerIn: parent
                font.family: Theme.font; font.pixelSize: 11
                color: Theme.c("muted", "#6c7086")
                text: "✕"
            }
            MouseArea {
                id: xMouse; anchors.fill: parent; hoverEnabled: true
                onClicked: ShellState.closeIsland()
            }
        }
    }

    // ── Tab bar ────────────────────────────────────────────────────────────

    RowLayout {
        Layout.fillWidth: true
        spacing: 4

        Repeater {
            model: ["Appearance", "Layout", "Clock", "OSD"]
            Rectangle {
                required property string modelData
                required property int index
                Layout.fillWidth: true; height: 26; radius: 8
                color: settingsRoot.currentTab === index
                    ? Qt.alpha(Theme.c("accent", "#89b4fa"), 0.18)
                    : tabHov.containsMouse
                        ? Qt.alpha(Theme.c("panel_alt", "#1e1e2e"), 0.6)
                        : "transparent"
                Text {
                    anchors.centerIn: parent
                    font.family: Theme.font; font.pixelSize: 11
                    font.weight: settingsRoot.currentTab === index ? Font.SemiBold : Font.Normal
                    color: settingsRoot.currentTab === index
                        ? Theme.c("accent", "#89b4fa")
                        : Theme.c("muted", "#6c7086")
                    text: modelData
                }
                MouseArea {
                    id: tabHov; anchors.fill: parent; hoverEnabled: true
                    onClicked: settingsRoot.currentTab = index
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true; height: 1
        color: Qt.alpha(Theme.c("border", "#313244"), 0.8)
    }

    // ── Tab content ────────────────────────────────────────────────────────

    StackLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        currentIndex: settingsRoot.currentTab

        // ── Tab 0: Appearance ──
        ScrollView {
            clip: true
            contentWidth: availableWidth
            ColumnLayout {
                width: parent.width
                spacing: 2

                SectionHead { text: "FONT" }
                StringRow {
                    labelText: "Font family"
                    value: Config.font
                    onChanged: (val) => { Config.font = val; settingsRoot.scheduleSave(); }
                }
                StepRow {
                    labelText: "Clock size"
                    value: Config.clockFontSize
                    minVal: 8; maxVal: 32
                    onChanged: (val) => { Config.clockFontSize = val; settingsRoot.scheduleSave(); }
                }
                StepRow {
                    labelText: "Search size"
                    value: Config.launcherFontSize
                    minVal: 8; maxVal: 24
                    onChanged: (val) => { Config.launcherFontSize = val; settingsRoot.scheduleSave(); }
                }
                StepRow {
                    labelText: "Item size"
                    value: Config.launcherItemFontSize
                    minVal: 8; maxVal: 24
                    onChanged: (val) => { Config.launcherItemFontSize = val; settingsRoot.scheduleSave(); }
                }

                Divider {}
                SectionHead { text: "COLORS" }
                ColorRow {
                    labelText: "Island color"
                    value: Config.islandColor
                    onChanged: (val) => { Config.islandColor = val; settingsRoot.scheduleSave(); }
                }

                Item { Layout.preferredHeight: 8 }
            }
        }

        // ── Tab 1: Layout ──
        ScrollView {
            clip: true
            contentWidth: availableWidth
            ColumnLayout {
                width: parent.width
                spacing: 2

                SectionHead { text: "ISLAND" }
                StepRow {
                    labelText: "Top margin (px)"
                    value: Config.topMargin
                    minVal: 0; maxVal: 100
                    onChanged: (val) => { Config.topMargin = val; settingsRoot.scheduleSave(); }
                }
                StepRow {
                    labelText: "Pill height (px)"
                    value: Config.pillHeight
                    minVal: 28; maxVal: 80
                    onChanged: (val) => { Config.pillHeight = val; settingsRoot.scheduleSave(); }
                }

                Divider {}
                SectionHead { text: "WIDTHS" }
                StepRow {
                    labelText: "Launcher (px)"
                    value: Config.launcherWidth
                    minVal: 300; maxVal: 800; step: 10
                    onChanged: (val) => { Config.launcherWidth = val; settingsRoot.scheduleSave(); }
                }
                StepRow {
                    labelText: "Menu (px)"
                    value: Config.menuWidth
                    minVal: 200; maxVal: 600; step: 10
                    onChanged: (val) => { Config.menuWidth = val; settingsRoot.scheduleSave(); }
                }
                StepRow {
                    labelText: "OSD (px)"
                    value: Config.osdWidth
                    minVal: 150; maxVal: 500; step: 10
                    onChanged: (val) => { Config.osdWidth = val; settingsRoot.scheduleSave(); }
                }
                StepRow {
                    labelText: "Notification (px)"
                    value: Config.notifWidth
                    minVal: 200; maxVal: 600; step: 10
                    onChanged: (val) => { Config.notifWidth = val; settingsRoot.scheduleSave(); }
                }

                Item { Layout.preferredHeight: 8 }
            }
        }

        // ── Tab 2: Clock ──
        ScrollView {
            clip: true
            contentWidth: availableWidth
            ColumnLayout {
                width: parent.width
                spacing: 2

                SectionHead { text: "FORMAT" }
                ToggleRow {
                    labelText: "24-hour format"
                    checked: Config.use24h
                    onChanged: (val) => { Config.use24h = val; settingsRoot.scheduleSave(); }
                }
                ToggleRow {
                    labelText: "Show date on hover"
                    checked: Config.showDate
                    onChanged: (val) => { Config.showDate = val; settingsRoot.scheduleSave(); }
                }

                Item { Layout.preferredHeight: 8 }
            }
        }

        // ── Tab 3: OSD ──
        ScrollView {
            clip: true
            contentWidth: availableWidth
            ColumnLayout {
                width: parent.width
                spacing: 2

                SectionHead { text: "TIMINGS" }
                StepRow {
                    labelText: "OSD duration (ms)"
                    value: Config.osdDisplayMs
                    minVal: 500; maxVal: 5000; step: 100
                    onChanged: (val) => { Config.osdDisplayMs = val; settingsRoot.scheduleSave(); }
                }
                StepRow {
                    labelText: "Animation (ms)"
                    value: Config.animDuration
                    minVal: 0; maxVal: 1000; step: 50
                    onChanged: (val) => { Config.animDuration = val; settingsRoot.scheduleSave(); }
                }

                Item { Layout.preferredHeight: 8 }
            }
        }
    }
}
