/*
 * ╔══════════════════════════════════════════════════════════════╗
 * ║                      Aurora Player                          ║
 * ╚══════════════════════════════════════════════════════════════╝
 *
 * File        : AuroraEqualizerSwitcher.qml
 * Module      : Components
 * Component   : Equalizer Preset Switcher
 * Version     : 0.1.0-dev
 *
 * Description:
 * Minimal UI for AuroraEqualizerProvider's Level A EasyEffects
 * integration. Presets are discovered by the provider and this
 * component only emits AuroraState.setPreset(). It deliberately does
 * not expose or modify the global EasyEffects graph directly.
 */

import QtQuick
import "../Core"

Item {
    id: root

    property bool hovered: false

    visible: AuroraState.equalizerAvailable && AuroraState.equalizerPresets.length > 0
    implicitHeight: visible ? AuroraConfig.switcherChipHeight : 0

    HoverHandler {
        id: switcherHover
        onHoveredChanged: root.hovered = switcherHover.hovered
    }

    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: AuroraConfig.switcherChipSpacing

        Repeater {
            model: AuroraState.equalizerPresets

            Rectangle {
                id: chip

                readonly property bool selected: modelData === AuroraState.currentPreset

                implicitWidth: label.implicitWidth + AuroraConfig.switcherChipPadding * 2
                implicitHeight: AuroraConfig.switcherChipHeight
                radius: height / 2
                color: chip.selected ? AuroraTheme.colorPrimary : AuroraTheme.colorContainer

                Behavior on color {
                    ColorAnimation { duration: AuroraConfig.fastAnimation }
                }

                TapHandler {
                    onTapped: AuroraState.setPreset(modelData)
                }

                Text {
                    id: label
                    anchors.centerIn: parent
                    text: modelData
                    font.pixelSize: AuroraTheme.fontSizeSmall
                    font.family: AuroraTheme.fontFamily
                    color: chip.selected ? AuroraTheme.colorOnPrimary : AuroraTheme.colorOnBackground
                }
            }
        }
    }
}
