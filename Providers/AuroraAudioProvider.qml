/*
 * ╔══════════════════════════════════════════════════════════════╗
 * ║                      Aurora Player                          ║
 * ╚══════════════════════════════════════════════════════════════╝
 *
 * File        : AuroraAudioProvider.qml
 * Module      : Providers
 * Component   : Audio Provider
 * Version     : 0.1.0-dev
 *
 * Description:
 * Feeds AuroraState.spectrumLevels from cava. MPRIS only carries
 * track metadata and transport controls, never audio samples, so
 * the spectrum needs a source of its own - this is it.
 *
 * Requires the `cava` binary. If it isn't installed, the process
 * simply fails to start and spectrumLevels stays empty - Spectrum.qml
 * is expected to fall back to an idle animation in that case.
 */

pragma Singleton

import QtQuick
import Quickshell.Io
import "../Core"

QtObject {

    id: provider

    // Resolved relative to this file, over to Assets/cava.
    readonly property string configPath:
        Qt.resolvedUrl("../Assets/cava/raw_output_config.txt").toString().replace("file://", "")

    readonly property real maxRange: 1000

    function initialize() {
        console.log("[Aurora] AudioProvider initialized")
    }

    Process {
        id: cava

        // Only burns CPU while something is actually playing.
        running: AuroraState.playbackState === "Playing"
        command: ["cava", "-p", provider.configPath]

        onRunningChanged: {
            if (!running) {
                AuroraState.spectrumLevels = []
                AuroraState.audioAvailable = false
            }
        }

        stdout: SplitParser {
            onRead: data => {
                const values = data
                    .split(";")
                    .map(v => parseFloat(v))
                    .filter(v => !isNaN(v))

                if (values.length === 0)
                    return

                const levels = values.map(v =>
                    Math.max(0, Math.min(1, v / provider.maxRange))
                )

                AuroraState.spectrumLevels = levels
                AuroraState.spectrumLevel =
                    levels.reduce((sum, v) => sum + v, 0) / levels.length
                AuroraState.audioAvailable = true
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                console.log("[Aurora] cava exited with code", exitCode, "- is it installed?")
            AuroraState.spectrumLevels = []
            AuroraState.audioAvailable = false
        }
    }
}
