import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import "../Providers"
import "../Core"

RowLayout {
    id: root
    spacing: 4

    RippleButton {
        implicitWidth: 26
        implicitHeight: 26
        enabled: AuroraState.connected
        colBackground: "transparent"
        colBackgroundHover: Appearance.colors.colSecondaryContainer
        colRipple: Appearance.colors.colSecondaryContainer
        downAction: () => AuroraPlayerProvider.previous()

        contentItem: MaterialSymbol {
            anchors.centerIn: parent
            iconSize: Appearance.font.pixelSize.large
            fill: 1
            color: Appearance.colors.colOnLayer1
            text: "skip_previous"
        }
    }

    RippleButton {
        id: playPause
        implicitWidth: 32
        implicitHeight: 32
        enabled: AuroraState.connected
        buttonRadius: implicitWidth / 2
        colBackground: Appearance.colors.colPrimary
        colBackgroundHover: Appearance.colors.colPrimary
        colRipple: Appearance.colors.colOnPrimary
        downAction: () => AuroraPlayerProvider.togglePlaying()

        contentItem: MaterialSymbol {
            anchors.centerIn: parent
            iconSize: Appearance.font.pixelSize.large
            fill: 1
            color: Appearance.colors.colOnPrimary
            text: AuroraState.playbackState === "Playing" ? "pause" : "play_arrow"
        }
    }

    RippleButton {
        implicitWidth: 26
        implicitHeight: 26
        enabled: AuroraState.connected
        colBackground: "transparent"
        colBackgroundHover: Appearance.colors.colSecondaryContainer
        colRipple: Appearance.colors.colSecondaryContainer
        downAction: () => AuroraPlayerProvider.next()

        contentItem: MaterialSymbol {
            anchors.centerIn: parent
            iconSize: Appearance.font.pixelSize.large
            fill: 1
            color: Appearance.colors.colOnLayer1
            text: "skip_next"
        }
    }
}
