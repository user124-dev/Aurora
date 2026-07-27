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
 * one chip, not two). Tapping a chip calls AuroraState.selectPlayer()
 * to show that source instead of whatever MPRIS calls "active" -
 * AuroraState is still the only thing this component reads or calls,
 * same as every other visual component. Renders at zero height with
 * zero or one player, since there's nothing to switch between.
 */

import QtQuick
import "../Core"

Item {
    id: root

    visible: AuroraState.players.length > 1
    implicitHeight: visible ? AuroraConfig.switcherChipHeight : 0

    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: AuroraConfig.switcherChipSpacing

        Repeater {
            model: AuroraState.players

            Rectangle {
                implicitWidth: label.implicitWidth + AuroraConfig.switcherChipPadding * 2
                implicitHeight: AuroraConfig.switcherChipHeight
                radius: height / 2
                color: modelData.selected ? AuroraTheme.colorPrimary : AuroraTheme.colorContainer

                Behavior on color {
                    ColorAnimation { duration: AuroraConfig.fastAnimation }
                }

                TapHandler {
                    onTapped: AuroraState.selectPlayer(modelData.identity)
                }

                Text {
                    id: label
                    anchors.centerIn: parent
                    text: modelData.identity || "?"
                    font.pixelSize: AuroraTheme.fontSizeSmall
                    font.family: AuroraTheme.fontFamily
                    color: modelData.selected ? AuroraTheme.colorOnPrimary : AuroraTheme.colorOnBackground
                }
            }
        }
    }
}
