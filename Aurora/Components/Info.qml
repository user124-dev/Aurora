import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import "../Providers"
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

        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.large
            color: Appearance.colors.colOnLayer1
            elide: Text.ElideRight
            text: AuroraState.connected ? (AuroraState.title || "Untitled") : "Not playing"
        }

        StyledText {
            Layout.fillWidth: true
            font.pixelSize: Appearance.font.pixelSize.smaller
            color: Appearance.colors.colSubtext
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
                color: Appearance.colors.colSecondaryContainer

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    radius: parent.radius
                    color: Appearance.colors.colPrimary
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
                onClicked: mouse => AuroraPlayerProvider.seek(Math.max(0, Math.min(1, mouse.x / width)))
                onPositionChanged: mouse => {
                    if (pressed)
                        AuroraPlayerProvider.seek(Math.max(0, Math.min(1, mouse.x / width)))
                }
            }
        }

        StyledText {
            Layout.topMargin: 1
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.colSubtext
            visible: AuroraState.connected
            text: root.formatTime(AuroraState.position) + " / " + root.formatTime(AuroraState.duration)
        }
    }
}
