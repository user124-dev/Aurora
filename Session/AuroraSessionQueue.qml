/*
 * AuroraSessionQueue.qml
 *
 * Aurora-owned session queue/history. This layer is deliberately separate
 * from MPRIS Playlists: MPRIS does not guarantee a usable playlist API for
 * browsers, MPV, VLC and every other source Aurora may encounter.
 *
 * Queue entries are metadata snapshots, not promises that Aurora can seek
 * into a foreign player's internal playlist. When a source exposes only
 * next/previous, Aurora can request the next item and verify the resulting
 * metadata; arbitrary item playback remains source-dependent.
 */
pragma Singleton

import QtQuick
import Quickshell
import "../Core"

Singleton {
    id: session

    readonly property int historyLimit: 50
    property var queueBySource: ({})
    property var historyBySource: ({})
    property string pendingPlaybackId: ""

    function sourceKey(identity) {
        return String(identity || "unknown").trim() || "unknown"
    }

    function entryFromState() {
        if (!AuroraState.connected || !AuroraState.title)
            return null

        return {
            id: Qt.md5([
                AuroraState.playerName,
                AuroraState.title,
                AuroraState.artist,
                AuroraState.album,
                Math.round(AuroraState.duration)
            ].join("|")),
            source: AuroraState.playerName || "Unknown",
            title: AuroraState.title,
            artist: AuroraState.artist,
            album: AuroraState.album,
            coverArt: String(AuroraState.coverArt || ""),
            duration: AuroraState.duration,
            addedAt: Date.now()
        }
    }

    function cloneMap(map) {
        return Object.assign({}, map || {})
    }

    function addCurrent() {
        const entry = entryFromState()
        if (!entry)
            return false

        const key = sourceKey(entry.source)
        const next = cloneMap(session.queueBySource)
        const queue = (next[key] || []).slice()
        if (queue.some(item => item.id === entry.id)) {
            syncState()
            return false
        }

        queue.push(entry)
        next[key] = queue
        session.queueBySource = next
        syncState()
        return true
    }

    function remove(index) {
        const key = sourceKey(AuroraState.playerName)
        const next = cloneMap(session.queueBySource)
        const queue = (next[key] || []).slice()
        if (index < 0 || index >= queue.length)
            return false

        queue.splice(index, 1)
        next[key] = queue
        session.queueBySource = next
        syncState()
        return true
    }

    function clearQueue() {
        const key = sourceKey(AuroraState.playerName)
        const next = cloneMap(session.queueBySource)
        next[key] = []
        session.queueBySource = next
        session.pendingPlaybackId = ""
        syncState()
    }

    function currentQueue() {
        return session.queueBySource[sourceKey(AuroraState.playerName)] || []
    }

    function currentHistory() {
        return session.historyBySource[sourceKey(AuroraState.playerName)] || []
    }

    function playNextQueued() {
        const queue = currentQueue()
        if (queue.length === 0) {
            AuroraState.sessionPlaybackStatus = "Idle"
            AuroraState.sessionPlaybackMessage = "La cola de Aurora está vacía."
            return false
        }

        const next = queue[0]
        if (!AuroraState.canGoNext) {
            AuroraState.sessionPlaybackStatus = "Unsupported"
            AuroraState.sessionPlaybackMessage = "La fuente actual no expone next() mediante MPRIS."
            return false
        }

        session.pendingPlaybackId = next.id
        AuroraState.sessionPlaybackStatus = "Requested"
        AuroraState.sessionPlaybackMessage = "Aurora solicitó el siguiente elemento a la fuente."
        AuroraState.next()
        return true
    }

    function playQueuedItem(index) {
        const queue = currentQueue()
        if (index < 0 || index >= queue.length)
            return false

        const requested = queue[index]
        const current = entryFromState()
        if (current && current.id === requested.id) {
            AuroraState.sessionPlaybackStatus = "Playing"
            AuroraState.sessionPlaybackMessage = "El elemento ya está activo."
            return true
        }

        // There is no standard MPRIS action for arbitrary playlist-item
        // selection. Only the immediately following item can be requested
        // safely through the generic contract exposed by Aurora today.
        if (index === 0 && AuroraState.canGoNext)
            return playNextQueued()

        AuroraState.sessionPlaybackStatus = "Unsupported"
        AuroraState.sessionPlaybackMessage = "La fuente no expone selección directa de ese elemento."
        return false
    }

    function recordHistory(entry) {
        if (!entry)
            return

        const key = sourceKey(entry.source)
        const next = cloneMap(session.historyBySource)
        const history = (next[key] || []).filter(item => item.id !== entry.id)
        history.unshift(entry)
        next[key] = history.slice(0, session.historyLimit)
        session.historyBySource = next
    }

    function syncState() {
        const queue = currentQueue()
        AuroraState.sessionQueue = queue
        AuroraState.sessionHistory = currentHistory()
        AuroraState.sessionSource = sourceKey(AuroraState.playerName)
        AuroraState.sessionQueueIndex = queue.length > 0 ? 0 : -1
    }

    function handleTrackChanged() {
        const entry = session.entryFromState()
        if (!entry)
            return

        session.recordHistory(entry)

        if (session.pendingPlaybackId) {
            if (entry.id === session.pendingPlaybackId) {
                const next = cloneMap(session.queueBySource)
                const key = session.sourceKey(entry.source)
                next[key] = (next[key] || []).filter(item => item.id !== entry.id)
                session.queueBySource = next
                session.pendingPlaybackId = ""
                AuroraState.sessionPlaybackStatus = "Playing"
                AuroraState.sessionPlaybackMessage = "Elemento de cola confirmado por la fuente."
            } else {
                AuroraState.sessionPlaybackStatus = "SourceControlled"
                AuroraState.sessionPlaybackMessage = "La fuente avanzó, pero no confirmó el elemento solicitado."
            }
        }

        session.syncState()
    }

    function handleConnectionChanged(connected) {
        if (!connected) {
            session.pendingPlaybackId = ""
            AuroraState.sessionPlaybackStatus = "Idle"
            AuroraState.sessionPlaybackMessage = "Sin fuente MPRIS activa."
        }
        session.syncState()
    }

    function handlePlayerSelection() {
        session.syncState()
    }

    Connections {
        target: AuroraState
        function onTrackChanged() { session.handleTrackChanged() }
        function onConnectionChanged(connected) { session.handleConnectionChanged(connected) }
        function onSelectPlayer() { session.handlePlayerSelection() }
    }

    Component.onCompleted: session.syncState()
}
