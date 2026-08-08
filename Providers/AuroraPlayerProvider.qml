/*
 * Aurora Player Provider
 *
 * The provider talks to AuroraMprisController, which wraps Quickshell's
 * official MPRIS service. This keeps the rest of Aurora independent from
 * End-4/ii and other host-specific service trees.
 */

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../Core"
import "."

Singleton {
    id: provider

    property string selectedIdentity: ""
    readonly property var meaningfulPlayers: computeMeaningfulPlayers(AuroraMprisController.players ?? [])

    function initialize() {
        provider.restoreLastSource()
        provider.syncPlayer()
        provider.syncPlayerList()
        console.log("[Aurora] PlayerProvider initialized")
    }

    function clearState() {
        AuroraState.connected = false
        AuroraState.playerName = ""
        AuroraState.playbackState = "Stopped"
        AuroraState.title = ""
        AuroraState.artist = ""
        AuroraState.album = ""
        AuroraState.coverArt = ""
        AuroraState.duration = 0
        AuroraState.position = 0
        AuroraState.canSeek = false
        AuroraState.shuffleEnabled = false
        AuroraState.repeatMode = "None"
    }

    function isSameTrack(a, b) {
        if (a.trackTitle && b.trackTitle)
            return a.trackTitle.includes(b.trackTitle) || b.trackTitle.includes(a.trackTitle)

        return Math.abs((a.position ?? 0) - (b.position ?? 0)) <= AuroraConfig.duplicatePositionTolerance &&
               Math.abs((a.length ?? 0) - (b.length ?? 0)) <= AuroraConfig.duplicateLengthTolerance
    }

    function computeMeaningfulPlayers(players) {
        if (!AuroraConfig.mergeDuplicatePlayers)
            return players

        const used = new Set()
        const result = []

        for (let i = 0; i < players.length; ++i) {
            if (used.has(i))
                continue

            const group = [i]
            for (let j = i + 1; j < players.length; ++j) {
                if (!used.has(j) && isSameTrack(players[i], players[j]))
                    group.push(j)
            }

            group.forEach(index => used.add(index))
            const withArt = group.find(index => players[index]?.trackArtUrl)
            result.push(players[withArt ?? group[0]])
        }

        return result
    }

    function resolveActivePlayer() {
        if (selectedIdentity !== "") {
            const selected = meaningfulPlayers.find(player => player?.identity === selectedIdentity)
            if (selected)
                return selected
            selectedIdentity = ""
        }

        if (AuroraConfig.autoSwitchEnabled && (AuroraConfig.sourcePriority ?? []).length > 0) {
            const prioritized = pickByPriority()
            if (prioritized)
                return prioritized
        }

        return AuroraMprisController.activePlayer
    }

    function pickByPriority() {
        for (const name of AuroraConfig.sourcePriority ?? []) {
            const lowered = (name ?? "").toLowerCase()
            const match = meaningfulPlayers.find(player => {
                const identity = (player?.identity ?? "").toLowerCase()
                return player?.isPlaying && (identity.includes(lowered) || lowered.includes(identity))
            })
            if (match)
                return match
        }
        return null
    }

    function syncPlayerList() {
        const active = resolveActivePlayer()
        const live = meaningfulPlayers.map(player => ({
            identity: player?.identity ?? "",
            title: player?.trackTitle ?? "",
            selected: player === active,
            status: player?.isPlaying ? "Playing" : "Paused"
        }))

        const liveIdentities = live.map(player => player.identity.toLowerCase())
        const offline = (AuroraConfig.sourcePriority ?? [])
            .filter(name => {
                const lowered = (name ?? "").toLowerCase()
                return !liveIdentities.some(identity => identity.includes(lowered) || lowered.includes(identity))
            })
            .map(name => ({ identity: name, title: "", selected: false, status: "Offline" }))

        AuroraState.players = live.concat(offline)
    }

    function selectPlayer(identity) {
        if (!meaningfulPlayers.some(player => player?.identity === identity))
            return
        selectedIdentity = identity
        saveLastSource(identity)
        syncPlayer()
        syncPlayerList()
    }

    function syncPlayer() {
        const player = resolveActivePlayer()
        const wasConnected = AuroraState.connected
        const previousTitle = AuroraState.title
        const previousArtist = AuroraState.artist

        AuroraState.connected = !!player
        if (!player) {
            clearState()
            if (wasConnected)
                AuroraState.connectionChanged(false)
            return
        }

        if (!wasConnected)
            AuroraState.connectionChanged(true)

        AuroraState.playerName = player.identity ?? ""
        AuroraState.playbackState = player.isPlaying ? "Playing" : "Paused"
        AuroraState.title = player.trackTitle ?? ""
        AuroraState.artist = player.trackArtist ?? ""
        AuroraState.album = player.trackAlbum ?? ""
        AuroraState.coverArt = player.trackArtUrl ?? ""
        AuroraState.duration = player.length ?? 0
        AuroraState.position = player.position ?? 0
        AuroraState.canSeek = player.canSeek ?? false
        AuroraState.shuffleEnabled = player.shuffleSupported ? player.shuffle : false
        AuroraState.repeatMode = player.loopSupported ? String(player.loopState) : "None"

        if (AuroraState.title !== previousTitle || AuroraState.artist !== previousArtist)
            AuroraState.trackChanged()
    }

    function togglePlaying() {
        resolveActivePlayer()?.togglePlaying()
    }

    function next() {
        const player = resolveActivePlayer()
        if (player?.canGoNext)
            player.next()
    }

    function previous() {
        const player = resolveActivePlayer()
        if (player?.canGoPrevious)
            player.previous()
    }

    function seek(fraction) {
        const player = resolveActivePlayer()
        if (player && player.canSeek && player.length > 0)
            player.position = fraction * player.length
    }

    function toggleShuffle() {
        const player = resolveActivePlayer()
        if (player?.canControl && player.shuffleSupported)
            player.shuffle = !player.shuffle
    }

    function cycleRepeat() {
        const player = resolveActivePlayer()
        if (!player?.canControl || !player.loopSupported)
            return

        const order = ["None", "Track", "Playlist"]
        const current = String(player.loopState)
        const nextMode = order[(order.indexOf(current) + 1) % order.length]
        player.loopState = nextMode
    }

    FileView {
        id: lastSourceFile
        path: Quickshell.statePath("aurora-last-source.json")
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()

        JsonAdapter {
            id: lastSource
            property string identity: ""
        }
    }

    function saveLastSource(identity) {
        if (AuroraConfig.rememberLastSource)
            lastSource.identity = identity
    }

    function restoreLastSource() {
        if (AuroraConfig.rememberLastSource && lastSource.identity)
            selectedIdentity = lastSource.identity
    }

    Timer {
        interval: AuroraConfig.positionUpdateInterval
        running: AuroraState.playbackState === "Playing"
        repeat: true
        onTriggered: AuroraState.position = provider.resolveActivePlayer()?.position ?? 0
    }

    Connections {
        target: AuroraMprisController
        function onTrackChanged() {
            provider.syncPlayer()
            provider.syncPlayerList()
        }
        function onActivePlayerChanged() {
            provider.syncPlayer()
            provider.syncPlayerList()
        }
    }

    Connections {
        target: AuroraState
        function onTogglePlaying() { provider.togglePlaying() }
        function onNext() { provider.next() }
        function onPrevious() { provider.previous() }
        function onSeek(fraction) { provider.seek(fraction) }
        function onToggleShuffle() { provider.toggleShuffle() }
        function onCycleRepeat() { provider.cycleRepeat() }
        function onSelectPlayer(identity) { provider.selectPlayer(identity) }
    }
}
