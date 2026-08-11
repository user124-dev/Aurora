/*
 * Aurora Player Provider
 *
 * The provider talks to AuroraMprisController, which wraps Quickshell's
 * official MPRIS service. This keeps the rest of Aurora independent from
 * host-specific service trees.
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

    // Cover art is cached locally instead of binding Image.source directly
    // to a remote MPRIS trackArtUrl. Browser integrations can replace their
    // temporary artwork file during a track change, which races an async
    // Image loader. A stable local copy avoids that race for HTTP(S) art.
    readonly property string artCacheDirectory: Quickshell.cachePath("cover-art")
    property string pendingArtRequest: ""
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
        provider.pendingArtRequest = ""
    }

    function normalized(value) {
        return String(value ?? "").trim().toLowerCase()
    }

    function isSameTrack(a, b) {
        const titleA = normalized(a?.trackTitle)
        const titleB = normalized(b?.trackTitle)
        const artistA = normalized(a?.trackArtist)
        const artistB = normalized(b?.trackArtist)
        const albumA = normalized(a?.trackAlbum)
        const albumB = normalized(b?.trackAlbum)

        // Prefer strong metadata matching. A title-only heuristic can merge
        // unrelated songs that happen to share a name.
        if (titleA && titleB) {
            const sameTitle = titleA === titleB || titleA.includes(titleB) || titleB.includes(titleA)
            const sameArtist = !artistA || !artistB || artistA === artistB || artistA.includes(artistB) || artistB.includes(artistA)
            const sameAlbum = !albumA || !albumB || albumA === albumB || albumA.includes(albumB) || albumB.includes(albumA)
            return sameTitle && sameArtist && sameAlbum
        }

        // Metadata-poor browser players can still be recognized when their
        // position and duration are close enough to represent the same stream.
        return Math.abs((a?.position ?? 0) - (b?.position ?? 0)) <= AuroraConfig.duplicatePositionTolerance &&
               Math.abs((a?.length ?? 0) - (b?.length ?? 0)) <= AuroraConfig.duplicateLengthTolerance &&
               (a?.length ?? 0) > 0 && (b?.length ?? 0) > 0
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
        provider.requestArtCache(player.trackArtUrl ?? "")
        AuroraState.duration = player.length ?? 0
        AuroraState.position = player.position ?? 0
        AuroraState.canSeek = !!player.canSeek && !!player.positionSupported
        AuroraState.shuffleEnabled = player.shuffleSupported ? player.shuffle : false
        AuroraState.repeatMode = player.loopSupported ? String(player.loopState) : "None"

        if (AuroraState.title !== previousTitle || AuroraState.artist !== previousArtist)
            AuroraState.trackChanged()
    }

    function togglePlaying() {
        const player = resolveActivePlayer()
        if (player?.canTogglePlaying)
            player.togglePlaying()
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
        if (player && player.canSeek && player.positionSupported && player.lengthSupported && player.length > 0)
            player.position = Math.max(0, Math.min(1, fraction)) * player.length
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

    function requestArtCache(url) {
        if (!url) {
            provider.pendingArtRequest = ""
            AuroraState.coverArt = ""
            return
        }

        // Local/data artwork should stay untouched. Only remote HTTP(S)
        // resources need a downloaded stable copy.
        if (!/^https?:\/\//i.test(url)) {
            provider.pendingArtRequest = url
            AuroraState.coverArt = url
            return
        }

        if (url === provider.pendingArtRequest)
            return

        provider.pendingArtRequest = url

        if (artCache.running)
            artCache.running = false

        artCache.targetUrl = url
        artCache.cachedPath = provider.artCacheDirectory + "/" + Qt.md5(url)

        // Do not interpolate the URL into a shell command. Passing each
        // argument directly prevents shell metacharacters or quotes in a
        // remote URL from becoming executable syntax. `--create-dirs` lets
        // curl create Aurora's cache directory without a shell wrapper.
        artCache.command = [
            "curl", "-fsSL",
            "--create-dirs",
            "--connect-timeout", "5",
            "--max-time", "20",
            "--retry", "1",
            url,
            "-o", artCache.cachedPath
        ]
        artCache.running = true
    }

    Process {
        id: artCache
        property string targetUrl: ""
        property string cachedPath: ""

        onExited: (exitCode, exitStatus) => {
            if (artCache.targetUrl !== provider.pendingArtRequest)
                return

            AuroraState.coverArt = exitCode === 0 ? Qt.resolvedUrl(artCache.cachedPath) : ""
        }
    }

    // Only instantiate the state file when the feature is enabled. The
    // default remains false, avoiding a harmless but noisy missing-file
    // warning on first startup.
    Loader {
        id: lastSourceLoader
        active: AuroraConfig.rememberLastSource
        asynchronous: false

        sourceComponent: FileView {
            id: lastSourceFile
            property alias identity: lastSource.identity
            path: Quickshell.statePath("aurora-last-source.json")
            watchChanges: true
            onFileChanged: reload()
            onAdapterUpdated: writeAdapter()

            JsonAdapter {
                id: lastSource
                property string identity: ""
            }
        }
    }

    function saveLastSource(identity) {
        if (lastSourceLoader.item)
            lastSourceLoader.item.identity = identity
    }

    function restoreLastSource() {
        if (lastSourceLoader.item && lastSourceLoader.item.identity)
            selectedIdentity = lastSourceLoader.item.identity
    }

    Timer {
        interval: AuroraConfig.positionUpdateInterval
        running: AuroraState.playbackState === "Playing"
        repeat: true
        onTriggered: AuroraState.position = provider.resolveActivePlayer()?.position ?? 0
    }

    Connections {
        target: AuroraMprisController
        function onAuroraTrackChanged() {
            provider.syncPlayer()
            provider.syncPlayerList()
        }
        function onAuroraActivePlayerChanged() {
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
