/*
 * AuroraEqualizerSwitcher.qml — one EasyEffects button with a unified menu.
 * Presets and the normal-sound bypass option share identical row dimensions.
 */
import QtQuick
import "../Core"

Item {
    id: root

    property bool hovered: false
    property bool menuOpen: false
    readonly property bool shown: AuroraState.equalizerAvailable

    implicitWidth: 260
    implicitHeight: root.shown ? content.implicitHeight : 0
    opacity: root.shown ? 1 : 0
    visible: root.opacity > 0
    clip: false

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

    Column {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 4

        Rectangle {
            id: mainButton
            width: parent.width
            height: AuroraConfig.switcherChipHeight
            radius: height / 2
            color: root.menuOpen || AuroraState.effectsManaged || AuroraState.effectsBypassed
                ? AuroraTheme.colorPrimary
                : AuroraTheme.colorContainer

            Behavior on color {
                ColorAnimation { duration: AuroraConfig.fastAnimation }
            }

            Text {
                anchors.fill: parent
                anchors.leftMargin: AuroraConfig.switcherChipPadding
                anchors.rightMargin: AuroraConfig.switcherChipPadding
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: AuroraState.effectsBypassed
                    ? "EasyEffects · Sonido normal"
                    : (AuroraState.currentPreset.length > 0
                        ? "EasyEffects · " + AuroraState.currentPreset
                        : "EasyEffects")
                font.pixelSize: AuroraTheme.fontSizeSmall
                font.family: AuroraTheme.fontFamily
                color: root.menuOpen || AuroraState.effectsManaged || AuroraState.effectsBypassed
                    ? AuroraTheme.colorOnPrimary
                    : AuroraTheme.colorOnBackground
                elide: Text.ElideRight
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: 9
                anchors.verticalCenter: parent.verticalCenter
                text: root.menuOpen ? "▴" : "▾"
                font.pixelSize: AuroraTheme.fontSizeSmall
                font.family: AuroraTheme.fontFamily
                color: root.menuOpen || AuroraState.effectsManaged || AuroraState.effectsBypassed
                    ? AuroraTheme.colorOnPrimary
                    : AuroraTheme.colorOnBackground
            }

            TapHandler {
                onTapped: root.menuOpen = !root.menuOpen
            }
        }

        Column {
            id: menu
            width: parent.width
            spacing: 4
            visible: root.menuOpen
            enabled: visible

            Repeater {
                model: [{ label: "Sonido normal", bypass: true }]
                    .concat(AuroraState.equalizerPresets.map(name => ({ label: name, bypass: false })))

                Rectangle {
                    id: option
                    required property var modelData
                    width: menu.width
                    height: AuroraConfig.switcherChipHeight
                    radius: height / 2
                    color: modelData.bypass
                        ? (AuroraState.effectsBypassed ? AuroraTheme.colorPrimary : AuroraTheme.colorContainer)
                        : ((!AuroraState.effectsBypassed && modelData.label === AuroraState.currentPreset)
                            ? AuroraTheme.colorPrimary : AuroraTheme.colorContainer)

                    Behavior on color {
                        ColorAnimation { duration: AuroraConfig.fastAnimation }
                    }

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: AuroraConfig.switcherChipPadding
                        anchors.rightMargin: AuroraConfig.switcherChipPadding
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                        text: option.modelData.label
                        font.pixelSize: AuroraTheme.fontSizeSmall
                        font.family: AuroraTheme.fontFamily
                        color: option.color === AuroraTheme.colorPrimary
                            ? AuroraTheme.colorOnPrimary
                            : AuroraTheme.colorOnBackground
                        elide: Text.ElideRight
                    }

                    TapHandler {
                        onTapped: {
                            if (option.modelData.bypass) {
                                AuroraState.setEffectsBypass(true)
                            } else {
                                AuroraState.setPreset(option.modelData.label)
                            }
                            root.menuOpen = false
                        }
                    }
                }
            }
        }
    }
}
