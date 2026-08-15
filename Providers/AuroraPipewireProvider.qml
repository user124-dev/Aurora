/*
 * AuroraPipewireProvider.qml
 *
 * Infrastructure adapter over Quickshell's official PipeWire API. The
 * provider is observational: it reports default output, volume/mute,
 * readiness and streams, but does not change routing or volume.
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

    readonly property string defaultOutputName: defaultSink?.name ?? ""
    readonly property string defaultOutputDescription: defaultSink?.description ?? ""
    readonly property real defaultOutputVolume: boundSink?.audio?.volume ?? 0
    readonly property bool defaultOutputMuted: boundSink?.audio?.muted ?? false
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

    PwObjectTracker {
        id: boundObjects
        objects: [provider.defaultSink]
    }

    readonly property var boundSink:
        provider.defaultSink && provider.defaultSink.ready ? provider.defaultSink : null

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

    Timer {
        interval: AuroraConfig.pipewireRefreshInterval
        running: provider.initialized
        repeat: true
        onTriggered: provider.syncState()
    }

    Connections {
        target: provider.boundSink ? provider.boundSink.audio : null
        function onVolumeChanged() { provider.syncState() }
        function onMutedChanged() { provider.syncState() }
    }
}
