/*
 * ╔══════════════════════════════════════════════════════════════╗
 * ║                      Aurora Player                          ║
 * ╚══════════════════════════════════════════════════════════════╝
 *
 * File        : AuroraInfo.qml
 * Module      : Components
 * Component   : Track Info
 * Version     : 0.1.0-dev
 *
 * Description:
 * Title, artist, a click/drag-to-seek progress bar and elapsed
 * time. Depends only on AuroraState (reads track/progress data,
 * and AuroraState.seek() is how this asks for a seek - never
 * touches a Provider directly).
 */

import QtQuick
import QtQuick.Layouts
import "../Core"

Item {
    id: root

    implicitHeight: column.implicitHeight

    function formatTime(seconds) {
        if (!seconds || seconds <= 0 || isNaN(seconds))
            return "0:00"
        const total = Math.floor(seconds)
        const m = Math.floor(total / 60)
        const s = total % 60
        return m + ":" + (s < 10 ? "0" : "") + s
    }

    ColumnLayout {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2

        Text {
            Layout.fillWidth: true
            font.pixelSize: AuroraTheme.fontSizeLarge
            font.family: AuroraTheme.fontFamily
            color: AuroraTheme.colorOnBackground
            elide: Text.ElideRight
            text: AuroraState.connected ? (AuroraState.title || "Untitled") : "Not playing"
        }

        Text {
            Layout.fillWidth: true
            font.pixelSize: AuroraTheme.fontSizeSmall
            font.family: AuroraTheme.fontFamily
            color: AuroraTheme.colorMuted
            elide: Text.ElideRight
            visible: AuroraState.connected && AuroraState.artist !== ""
            text: AuroraState.artist
        }

        Item {
            id: progressRow
            Layout.fillWidth: true
            Layout.topMargin: 2
            implicitHeight: 6
            visible: AuroraState.connected

            Rectangle {
                id: track
                anchors.fill: parent
                radius: height / 2
                color: AuroraTheme.colorContainer

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    radius: parent.radius
                    color: AuroraTheme.colorPrimary
                    width: parent.width * Math.max(0, Math.min(1, AuroraState.progress))

                    Behavior on width {
                        NumberAnimation { duration: AuroraConfig.normalAnimation }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                enabled: AuroraState.canSeek
                cursorShape: AuroraState.canSeek ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: mouse => AuroraState.seek(Math.max(0, Math.min(1, mouse.x / width)))
                onPositionChanged: mouse => {
                    if (pressed)
                        AuroraState.seek(Math.max(0, Math.min(1, mouse.x / width)))
                }
            }
        }

        Text {
            Layout.topMargin: 1
            font.pixelSize: AuroraTheme.fontSizeSmall
            font.family: AuroraTheme.fontFamily
            color: AuroraTheme.colorMuted
            visible: AuroraState.connected
            text: root.formatTime(AuroraState.position) + " / " + root.formatTime(AuroraState.duration)
        }
    }
}
