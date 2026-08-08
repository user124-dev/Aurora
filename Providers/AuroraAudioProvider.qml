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
import Quickshell
import Quickshell.Io
import "../Core"

Singleton {

    id: provider

    // Resolved relative to this file, over to Assets/cava.
    readonly property string configPath:
        Qt.resolvedUrl("../Assets/cava/raw_output_config.txt").toString().replace("file://", "")

    property bool initialized: false
    property bool availabilityWarningLogged: false

    // Set once the first time cava's bar count doesn't match
    // AuroraConfig.bars, so the mismatch gets logged once instead of
    // on every packet (cava's own framerate=60 config would otherwise
    // spam this). See DECISIONS.md -> "cava config duplicado a
    // proposito" for why this isn't read from the config file itself.
    property bool barsMismatchWarned: false

    function initialize() {
        if (provider.initialized)
            return

        provider.initialized = true
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

                if (values.length !== AuroraConfig.bars && !provider.barsMismatchWarned) {
                    console.log("[Aurora] cava reported", values.length, "bars, but AuroraConfig.bars is",
                        AuroraConfig.bars, "- check Assets/cava/raw_output_config.txt's bars= setting")
                    provider.barsMismatchWarned = true
                }

                const levels = values.map(v =>
                    Math.max(0, Math.min(1, v / AuroraConfig.spectrumMaxRange))
                )

                AuroraState.spectrumLevels = levels
                AuroraState.spectrumLevel =
                    levels.reduce((sum, v) => sum + v, 0) / levels.length
                AuroraState.audioAvailable = true
            }
        }

        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 && !provider.availabilityWarningLogged) {
                console.log("[Aurora] cava is unavailable (exit code", exitCode + ")")
                provider.availabilityWarningLogged = true
            }

            AuroraState.spectrumLevels = []
            AuroraState.audioAvailable = false
        }
    }
}
