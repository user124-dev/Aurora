/*
 * ╔══════════════════════════════════════════════════════════════╗
 * ║                      Aurora Player                          ║
 * ╚══════════════════════════════════════════════════════════════╝
 *
 * File        : AuroraSpectrum.qml
 * Module      : Components
 * Component   : Spectrum
 * Version     : 0.1.0-dev
 *
 * Description:
 * AuroraConfig.bars animated bars, driven by AuroraState.spectrumLevels.
 * That array is filled exclusively by AuroraAudioProvider (cava) - this
 * file never runs a process and never touches cava itself. If the
 * array is empty (no cava, or nothing playing yet) this falls back to
 * a soft idle wave instead of sitting dead.
 */

import QtQuick
import "../Core"

Item {
    id: root

    implicitHeight: 28

    readonly property int barCount: AuroraConfig.bars
    readonly property bool live: AuroraState.spectrumLevels.length > 0
    readonly property real barWidth:
        Math.max(1, (width - (barCount - 1) * AuroraConfig.barSpacing) / barCount)

    property int idleTick: 0

    Timer {
        interval: 120
        running: AuroraState.playbackState === "Playing" && !root.live
        repeat: true
        onTriggered: root.idleTick += 1
    }

    Repeater {
        model: root.barCount

        Rectangle {
            id: bar

            readonly property real level: root.live
                ? (AuroraState.spectrumLevels[index] ?? 0)
                : (AuroraState.playbackState === "Playing"
                    ? 0.15 + 0.15 * Math.abs(Math.sin((root.idleTick + index) * 0.5))
                    : 0.06)

            x: index * (root.barWidth + AuroraConfig.barSpacing)
            width: root.barWidth
            height: Math.max(2, level * root.height)
            anchors.bottom: root.bottom
            radius: width / 2
            color: AuroraTheme.colorPrimary
            opacity: AuroraState.connected ? 1 : 0.3

            Behavior on height {
                NumberAnimation { duration: AuroraConfig.fastAnimation }
            }
        }
    }
}
