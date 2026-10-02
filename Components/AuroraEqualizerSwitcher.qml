/*
 * AuroraEqualizerSwitcher.qml — EasyEffects status and preset controls.
 * Aurora never assumes EasyEffects is present or active.
 */
import QtQuick
import "../Core"

Item {
    id: root

    property bool hovered: false

    // Same open/close treatment as AuroraPlayerSwitcher.
    readonly property bool shown: AuroraState.equalizerAvailable
    opacity: root.shown ? 1 : 0
    visible: opacity > 0
    clip: true
    implicitHeight: root.shown ? AuroraConfig.switcherChipHeight : 0

    Behavior on opacity {
        NumberAnimation {
            duration: AuroraConfig.smoothAnimation
            easing.type: AuroraAnimations.standard
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: AuroraConfig.smoothAnimation
            easing.type: AuroraAnimations.standard
        }
    }

    HoverHandler {
        id: switcherHover
        onHoveredChanged: root.hovered = switcherHover.hovered
    }

    Row {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: AuroraConfig.switcherChipSpacing

        Rectangle {
            implicitWidth: statusLabel.implicitWidth + AuroraConfig.switcherChipPadding * 2
            implicitHeight: AuroraConfig.switcherChipHeight
            radius: height / 2
            color: AuroraState.effectsManaged ? AuroraTheme.colorPrimary : AuroraTheme.colorContainer

            Text {
                id: statusLabel
                anchors.centerIn: parent
                text: AuroraState.effectsManaged
                    ? "EasyEffects: " + AuroraState.currentPreset
                    : "EasyEffects"
                font.pixelSize: AuroraTheme.fontSizeSmall
                font.family: AuroraTheme.fontFamily
                color: AuroraState.effectsManaged
                    ? AuroraTheme.colorOnPrimary
                    : AuroraTheme.colorOnBackground
                elide: Text.ElideRight
            }
        }

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

                TapHandler { onTapped: AuroraState.setPreset(modelData) }

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
