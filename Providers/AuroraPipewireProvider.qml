/*
 * ╔══════════════════════════════════════════════════════════════╗
 * ║                      Aurora Player                          ║
 * ╚══════════════════════════════════════════════════════════════╝
 *
 * File        : AuroraPipewireProvider.qml
 * Module      : Providers
 * Component   : PipeWire Provider
 * Version     : 0.1.0-dev
 *
 * Description:
 * Infrastructure adapter over Quickshell's official PipeWire API.
 *
 * Aurora uses Quickshell as its primary integration layer. This provider
 * therefore does not shell out to `wpctl`, `pw-cli`, or pactl for normal
 * runtime state. Direct PipeWire tooling remains a future escape hatch for
 * features Quickshell does not expose.
 *
 * The provider is observational for now: it reports the default output,
 * volume/mute state, readiness, and streams linked to that output. It does
 * not change routing or volume. That keeps ownership explicit until Aurora
 * has a proper user-facing audio-control contract and snapshot/restore
 * policy.
 */

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import "../Core"

Singleton {
    id: provider

    property bool initialized: false

    readonly property bool available: true
    readonly property bool ready: Pipewire.ready
    readonly property var defaultSink: Pipewire.defaultAudioSink
    readonly property var defaultSource: Pipewire.defaultAudioSource

    readonly property string defaultOutputName:
        defaultSink?.name ?? ""
    readonly property string defaultOutputDescription:
        defaultSink?.description ?? ""
    readonly property real defaultOutputVolume:
        boundSink?.audio?.volume ?? 0
    readonly property bool defaultOutputMuted:
        boundSink?.audio?.muted ?? false

    readonly property var outputStreams: collectOutputStreams(outputLinks.linkGroups)

    function initialize() {
        if (provider.initialized)
            return

        provider.initialized = true
        syncState()
        console.log("[Aurora] PipewireProvider initialized")
    }

    function collectOutputStreams(groups) {
        if (!groups)
            return []

        const result = []
        const seen = new Set()

        for (const group of groups) {
            const source = group?.source
            if (!source || !source.isStream)
                continue

            const key = String(source.id)
            if (seen.has(key))
                continue

            seen.add(key)
            result.push({
                id: source.id,
                name: source.name ?? "",
                description: source.description ?? ""
            })
        }

        return result
    }

    function syncState() {
        AuroraState.pipewireAvailable = provider.available
        AuroraState.pipewireReady = provider.ready
        AuroraState.defaultOutputName = provider.defaultOutputName
        AuroraState.defaultOutputDescription = provider.defaultOutputDescription
        AuroraState.defaultOutputVolume = provider.defaultOutputVolume
        AuroraState.defaultOutputMuted = provider.defaultOutputMuted
        AuroraState.audioStreams = provider.outputStreams
    }

    // PipeWire objects are unbound by default. Binding the current default
    // sink enables PwNodeAudio.volume/muted safely. Quickshell documents that
    // these properties require a PwObjectTracker.
    PwObjectTracker {
        id: boundObjects
        objects: [provider.defaultSink]
    }

    readonly property var boundSink:
        provider.defaultSink && provider.defaultSink.ready ? provider.defaultSink : null

    // Tracks links into the current default output. Quickshell exposes the
    // tracked linkGroups as data, but PwNodeLinkTracker does not expose a
    // linkGroupsChanged signal. Aurora therefore samples this small graph on
    // a lightweight timer instead of connecting to a signal that does not
    // exist in the official API.
    PwNodeLinkTracker {
        id: outputLinks
        node: provider.defaultSink
    }

    Connections {
        target: Pipewire

        function onReadyChanged() { provider.syncState() }
        function onDefaultAudioSinkChanged() { provider.syncState() }
        function onDefaultAudioSourceChanged() { provider.syncState() }
    }

    // PwNodeLinkTracker.linkGroups and Pipewire's ObjectModel collections do
    // not provide the change signals used by the old implementation. A
    // modest polling interval keeps Aurora reactive without depending on
    // undocumented signals or shell commands.
    Timer {
        interval: 500
        running: provider.initialized
        repeat: true
        onTriggered: provider.syncState()
    }

    // `target` must resolve to a QObject or null. Avoid optional chaining here:
    // when no sink exists it produces JavaScript `undefined`, which QML warns
    // about while constructing Connections.
    Connections {
        target: provider.boundSink ? provider.boundSink.audio : null

        function onVolumeChanged() { provider.syncState() }
        function onMutedChanged() { provider.syncState() }
    }
}
