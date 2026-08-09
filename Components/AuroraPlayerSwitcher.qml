/*
 * ╔══════════════════════════════════════════════════════════════╗
 * ║                      Aurora Player                          ║
 * ╚══════════════════════════════════════════════════════════════╝
 *
 * File        : AuroraPlayerSwitcher.qml
 * Module      : Components
 * Component   : Player Switcher
 * Version     : 0.1.0-dev
 *
 * Description:
 * A row of small chips, one per distinct MPRIS source Aurora
 * currently sees - AuroraState.players, already deduplicated by
 * AuroraPlayerProvider. Tapping a chip calls AuroraState.selectPlayer().
 * `hovered` is exposed to AuroraPlayer so a chip click never doubles as
 * an Expanded → Hover mode change.
 */

import QtQuick
import "../Core"

Item {
    id: root

    property bool hovered: false

    visible: AuroraState.players.length > 1
    implicitHeight: visible ? AuroraConfig.switcherChipHeight : 0

    HoverHandler {
        id: switcherHover
        onHoveredChanged: root.hovered = switcherHover.hovered
    }

    function statusColor(status) {
        if (status === "Playing")
            return AuroraTheme.colorPrimary
        if (status === "Paused")
            return AuroraTheme.colorMuted
        return "transparent"
    }

    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: AuroraConfig.switcherChipSpacing

        Repeater {
            model: AuroraState.players

            Rectangle {
                id: chip

                readonly property bool offline: modelData.status === "Offline"

                implicitWidth: content.implicitWidth + AuroraConfig.switcherChipPadding * 2
                implicitHeight: AuroraConfig.switcherChipHeight
                radius: height / 2
                opacity: offline ? AuroraConfig.switcherOfflineOpacity : 1
                color: modelData.selected ? AuroraTheme.colorPrimary : AuroraTheme.colorContainer

                Behavior on color {
                    ColorAnimation { duration: AuroraConfig.fastAnimation }
                }

                TapHandler {
                    enabled: !chip.offline
                    onTapped: AuroraState.selectPlayer(modelData.identity)
                }

                Row {
                    id: content
                    anchors.centerIn: parent
                    spacing: AuroraConfig.switcherChipSpacing / 2

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: AuroraConfig.switcherStatusDotSize
                        height: AuroraConfig.switcherStatusDotSize
                        radius: width / 2
                        color: root.statusColor(modelData.status)
                        border.width: chip.offline ? AuroraConfig.switcherOfflineBorderWidth : 0
                        border.color: AuroraTheme.colorMuted
                    }

                    Text {
                        id: label
                        text: modelData.identity || "?"
                        font.pixelSize: AuroraTheme.fontSizeSmall
                        font.family: AuroraTheme.fontFamily
                        color: modelData.selected ? AuroraTheme.colorOnPrimary : AuroraTheme.colorOnBackground
                    }
                }
            }
        }
    }
}
