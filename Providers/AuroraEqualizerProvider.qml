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
 * EasyEffects CLI. EasyEffects is optional and Aurora does not claim
 * ownership of its global effects graph yet.
 */

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../Core"

Singleton {
    id: provider

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
        AuroraState.effectsBackend = ""
        AuroraState.effectsManaged = false
        AuroraState.effectsWarning = false
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

    // Detection only proves that EasyEffects is installed. It does not mean
    // Aurora is currently changing system audio. The warning is enabled only
    // after Aurora actually requests a preset load.
    Process {
        id: detection
        command: ["bash", "-c", "command -v easyeffects"]
        onExited: (exitCode, exitStatus) => {
            const available = Number(exitCode) === 0
            AuroraState.equalizerAvailable = available

            if (available) {
                AuroraState.effectsBackend = "EasyEffects"
                provider.refreshPresets()
            } else {
                AuroraState.equalizerPresets = []
                AuroraState.currentPreset = ""
                AuroraState.effectsBackend = ""
                AuroraState.effectsManaged = false
                AuroraState.effectsWarning = false
                console.log("[Aurora] EasyEffects not found - equalizer unavailable")
            }
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
            if (Number(exitCode) !== 0 && Number(exitCode) !== 1)
                console.log("[Aurora] Preset discovery finished with code", exitCode)
        }
    }

    Process {
        id: loader
        property string presetName: ""
        command: ["easyeffects", "-l", loader.presetName]
        onExited: (exitCode, exitStatus) => {
            if (Number(exitCode) === 0) {
                AuroraState.currentPreset = loader.presetName
                AuroraState.effectsManaged = true
                AuroraState.effectsWarning = true
                console.log("[Aurora] EasyEffects preset loaded by Aurora:", loader.presetName)
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
