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
 */

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../Core"

Singleton {
    id: provider

    readonly property string configPath:
        Qt.resolvedUrl("../Assets/cava/raw_output_config.txt").toString().replace("file://", "")

    property bool initialized: false
    property bool availabilityWarningLogged: false
    property bool barsMismatchWarned: false

    function initialize() {
        if (provider.initialized)
            return

        provider.initialized = true
        console.log("[Aurora] AudioProvider initialized")
    }

    Process {
        id: cava

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

                // A successful frame proves that cava is available. This
                // prevents a previous failed start from suppressing a later
                // useful diagnostic forever.
                provider.availabilityWarningLogged = false
            }
        }

        onExited: (exitCode, exitStatus) => {
            // When playback stops Quickshell terminates cava intentionally.
            // SIGTERM is therefore a normal lifecycle event, not a failure.
            const intentionallyStopped = exitCode === 15

            if (exitCode !== 0 && !intentionallyStopped && !provider.availabilityWarningLogged) {
                console.log("[Aurora] cava is unavailable (exit code", exitCode + ")")
                provider.availabilityWarningLogged = true
            }

            AuroraState.spectrumLevels = []
            AuroraState.audioAvailable = false
        }
    }
}
