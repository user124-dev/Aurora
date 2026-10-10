/*
 * AuroraEqualizerProvider.qml — EasyEffects preset and bypass control.
 * EasyEffects remains optional; Aurora only changes its global bypass when
 * the user explicitly selects "Sonido normal" or loads a preset.
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
        if (!AuroraState.equalizerAvailable || !name || loader.running)
            return

        loader.presetName = name
        loader.running = true
    }

    function setBypass(bypassed) {
        if (!AuroraState.equalizerAvailable || bypasser.running)
            return

        bypasser.targetBypassed = Boolean(bypassed)
        bypasser.running = true
    }

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
                AuroraState.effectsBypassed = false
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
            "-printf", "%f\\n"
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
                // A selected preset should be audible, so turn bypass off.
                provider.setBypass(false)
            } else {
                console.log("[Aurora] Failed to load EasyEffects preset:",
                    loader.presetName, "(exit code", exitCode + ")")
            }
        }
    }

    Process {
        id: bypasser
        property bool targetBypassed: false
        command: ["easyeffects", "-b", bypasser.targetBypassed ? "1" : "2"]

        onExited: (exitCode, exitStatus) => {
            if (Number(exitCode) === 0) {
                AuroraState.effectsBypassed = bypasser.targetBypassed
                AuroraState.effectsManaged = !bypasser.targetBypassed
                AuroraState.effectsWarning = !bypasser.targetBypassed
                console.log("[Aurora] EasyEffects bypass:",
                    bypasser.targetBypassed ? "enabled (normal sound)" : "disabled (effects active)")
            } else {
                console.log("[Aurora] Failed to change EasyEffects bypass (exit code", exitCode + ")")
            }
        }
    }

    Connections {
        target: AuroraState
        function onSetPreset(name) { provider.loadPreset(name) }
        function onSetEffectsBypass(bypassed) { provider.setBypass(bypassed) }
    }
}
