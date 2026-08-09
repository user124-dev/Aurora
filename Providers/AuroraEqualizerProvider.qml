/*
 * ╔══════════════════════════════════════════════════════════════╗
 * ║                      Aurora Player                          ║
 * ╚══════════════════════════════════════════════════════════════╝
 *
 * File        : AuroraEqualizerProvider.qml
 * Module      : Providers
 * Component   : Equalizer Provider (Level A)
 * Version     : 0.1.0-dev
 *
 * Description:
 * Level A equalizer support: preset discovery and loading via the
 * EasyEffects CLI (`easyeffects -l <preset>`). EasyEffects has no
 * documented D-Bus API for live per-band control (see DECISIONS.md),
 * so Level A deliberately stops at "pick a preset someone already
 * tuned in EasyEffects itself" rather than exposing individual bands -
 * that's Level B, exploratory, gated on a stable GSettings key path
 * that doesn't exist yet.
 *
 * Philosophy:
 * EasyEffects is optional, exactly like cava. If it isn't installed,
 * AuroraState.equalizerAvailable stays false and Aurora's playback,
 * metadata and spectrum features are entirely unaffected - same
 * graceful-degradation rule AuroraAudioProvider already follows.
 */

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../Core"

Singleton {
    id: provider

    // EasyEffects stores presets as flat `.json` files under its own
    // config folder - there is no CLI flag to list them, so this reads
    // the same directory EasyEffects itself reads from. Output presets
    // (playback) are used, not input presets (microphone capture) -
    // Aurora is a playback widget, so input presets are out of scope,
    // not an oversight.
    readonly property string presetDirectory: {
        const xdgConfigHome = Quickshell.env("XDG_CONFIG_HOME")
        const home = Quickshell.env("HOME") || ""
        const base = xdgConfigHome && xdgConfigHome.length > 0
            ? xdgConfigHome
            : home + "/.config"

        return base + "/easyeffects/output"
    }

    property bool initialized: false

    function initialize() {
        if (provider.initialized)
            return

        provider.initialized = true
        detection.running = true
        console.log("[Aurora] EqualizerProvider initialized")
    }

    function refreshPresets() {
        if (!AuroraState.equalizerAvailable)
            return
        discovery.running = true
    }

    function loadPreset(name) {
        if (!AuroraState.equalizerAvailable || !name)
            return

        loader.presetName = name
        loader.running = true
    }

    // Detects whether the `easyeffects` executable exists at all before
    // touching the filesystem or claiming the feature is available -
    // same order of operations AuroraAudioProvider uses for cava.
    Process {
        id: detection
        command: ["bash", "-c", "command -v easyeffects"]
        onExited: (exitCode, exitStatus) => {
            const available = exitCode === 0
            AuroraState.equalizerAvailable = available

            if (available)
                provider.refreshPresets()
            else
                console.log("[Aurora] EasyEffects not found - equalizer unavailable")
        }
    }

    Process {
        id: discovery
        command: [
            "find", provider.presetDirectory,
            "-maxdepth", String(AuroraConfig.equalizerPresetScanDepth),
            "-type", "f",
            "-name", "*.json",
            "-printf", "%f\n"
        ]

        property string buffer: ""

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const name = data.toString().trim().replace(/\.json$/, "")
                if (name.length === 0)
                    return
                if (!AuroraState.equalizerPresets.includes(name))
                    AuroraState.equalizerPresets = AuroraState.equalizerPresets.concat([name])
            }
        }

        onRunningChanged: {
            if (running)
                AuroraState.equalizerPresets = []
        }

        onExited: (exitCode, exitStatus) => {
            // `find` returns 1 when the directory doesn't exist yet - a
            // fresh EasyEffects install with zero saved presets, not an
            // Aurora failure.
            if (exitCode !== 0 && exitCode !== 1)
                console.log("[Aurora] Preset discovery finished with code", exitCode)
        }
    }

    Process {
        id: loader
        property string presetName: ""
        command: ["easyeffects", "-l", loader.presetName]
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                AuroraState.currentPreset = loader.presetName
            } else {
                console.log("[Aurora] Failed to load EasyEffects preset:",
                    loader.presetName, "(exit code", exitCode + ")")
            }
        }
    }

    Connections {
        target: AuroraState
        function onSetPreset(name) { provider.loadPreset(name) }
    }
}
