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
 * AuroraPlayerProvider (a browser tab mirroring Spotify shows up as
 * one chip, not two, unless AuroraConfig.mergeDuplicatePlayers is
 * off). Tapping a chip calls AuroraState.selectPlayer() to show that
 * source instead of whatever MPRIS calls "active" - AuroraState is
 * still the only thing this component reads or calls, same as every
 * other visual component. Renders at zero height with zero or one
 * player, since there's nothing to switch between.
 *
 * Each chip also carries a small status dot - Playing/Paused read
 * straight from MPRIS, Offline is synthetic (a source listed in
 * AuroraConfig.sourcePriority that Aurora doesn't currently see on
 * the bus - see AuroraPlayerProvider.syncPlayerList()). Offline
 * chips are dimmed and don't respond to taps: there's no real player
 * behind them to switch to yet.
 */

import QtQuick
import "../Core"

Item {
    id: root

    visible: AuroraState.players.length > 1
    implicitHeight: visible ? AuroraConfig.switcherChipHeight : 0

    function statusColor(status) {
        if (status === "Playing")
            return AuroraTheme.colorPrimary
        if (status === "Paused")
            return AuroraTheme.colorMuted
        return "transparent" // Offline - outline only, drawn below
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
                        border.width: chip.offline ? 1 : 0
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
