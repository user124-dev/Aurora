/*
 * ╔══════════════════════════════════════════════════════════════╗
 * ║                      Aurora Player                          ║
 * ╚══════════════════════════════════════════════════════════════╝
 *
 * File        : AuroraPlayerProvider.qml
 * Module      : Providers
 * Component   : Player Provider
 * Version     : 0.1.0-dev
 *
 * Description:
 * Reads information from MPRIS and updates AuroraState. Also the
 * single point of contact for sending playback commands back out to
 * MPRIS — components should call the functions below instead of
 * touching MprisController directly.
 *
 * MprisController.players can hold two entries for the same audio
 * (a browser tab mirroring a native player, a notification proxy in
 * front of the real one) - computeMeaningfulPlayers() collapses
 * those before anything reaches AuroraState.players, unless
 * AuroraConfig.mergeDuplicatePlayers turns that off. Selecting a
 * source with selectPlayer() pins syncPlayer() to it until that
 * source disappears, at which point this falls back to either
 * priority-based auto-switching (see pickByPriority()) or
 * MprisController.activePlayer.
 */

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.services
import "../Core"

// Note: qs.services is a hard import. If it's missing (a host other
// than "ii"), this file fails to load at parse time - no runtime
// guard here can catch that. See Blueprint/DECISIONS.md.

QtObject {

    id: provider

    function initialize() {
        console.log("[Aurora] PlayerProvider initialized")
        provider.restoreLastSource()
        syncPlayer()
        syncPlayerList()
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

    // ------------------------------------------------------------
    // MARK: Multi-player
    // MprisController.players can list the same audio twice under
    // two identities - a browser tab mirroring a native player, a
    // notification proxy sitting in front of the real one.
    // computeMeaningfulPlayers() collapses those before anything
    // reaches AuroraState; selectPlayer() lets a component ask for a
    // specific source instead of whatever MPRIS calls "active".
    // ------------------------------------------------------------

    // "" means automatic (follow priority/MprisController.activePlayer,
    // the only mode that existed before selection existed). Sits here,
    // not in AuroraState, since components never need the raw identity -
    // they read the `selected` flag already folded into each entry
    // of AuroraState.players.
    property string selectedIdentity: ""

    readonly property var meaningfulPlayers: computeMeaningfulPlayers(MprisController.players ?? [])

    onMeaningfulPlayersChanged: {
        syncPlayerList()
        syncPlayer()
    }

    // Same track reported under two MPRIS names if either title
    // contains the other, or - when one side has no usable title -
    // their timelines are close enough that sharing one by
    // coincidence would be unlikely. Math.abs() on both sides on
    // purpose: a naive subtraction reads "close" for any pair where
    // one position is smaller than the other by more than the
    // threshold, in the wrong direction.
    function isSameTrack(a, b) {
        if (a.trackTitle && b.trackTitle) {
            if (a.trackTitle.includes(b.trackTitle) || b.trackTitle.includes(a.trackTitle))
                return true
            // Both sides have a usable title and they don't match -
            // stop here. Falling through to the position/duration
            // check below would let two different tracks that happen
            // to start at a similar position read as "the same
            // source" by coincidence.
            return false
        }

        const closePosition = Math.abs((a.position ?? 0) - (b.position ?? 0)) <= 2
        const closeLength = Math.abs((a.length ?? 0) - (b.length ?? 0)) <= 2
        return closePosition && closeLength
    }

    // One representative per group of duplicates, preferring
    // whichever copy actually has cover art. An index already
    // claimed by an earlier group is skipped instead of re-tested,
    // so the same source can't end up representing two groups at
    // once. Skipped entirely when AuroraConfig.mergeDuplicatePlayers
    // is off - every raw MPRIS entry is then "meaningful" on its own,
    // duplicates included.
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
                if (used.has(j))
                    continue
                if (isSameTrack(players[i], players[j]))
                    group.push(j)
            }

            group.forEach(idx => used.add(idx))

            const withArt = group.find(idx => players[idx].trackArtUrl && players[idx].trackArtUrl.length > 0)
            result.push(players[withArt !== undefined ? withArt : group[0]])
        }

        return result
    }

    // The pinned selection wins if it's still around; failing that,
    // priority-based auto-switch (if configured); failing that, the
    // pin clears and this falls back to automatic, same as before
    // priority existed.
    function resolveActivePlayer() {
        if (provider.selectedIdentity !== "") {
            const pinned = provider.meaningfulPlayers.find(p => (p?.identity ?? "") === provider.selectedIdentity)
            if (pinned)
                return pinned
            provider.selectedIdentity = ""
        }

        if (AuroraConfig.autoSwitchEnabled && (AuroraConfig.sourcePriority ?? []).length > 0) {
            const byPriority = provider.pickByPriority()
            if (byPriority)
                return byPriority
        }

        return MprisController.activePlayer
    }

    // Walks AuroraConfig.sourcePriority in order and returns the
    // first entry that's both currently on the bus and actually
    // playing - a lower-priority source that's merely paused doesn't
    // steal focus from whatever's really making sound. Same
    // substring matching convention as isSameTrack()/
    // AuroraBrowserDetectorPlugin.looksLikeBrowser(), since MPRIS
    // identities aren't standardized enough for an exact match.
    function pickByPriority() {
        const priority = AuroraConfig.sourcePriority ?? []

        for (const name of priority) {
            const lowered = (name ?? "").toLowerCase()
            const match = provider.meaningfulPlayers.find(p => {
                const identity = (p?.identity ?? "").toLowerCase()
                return p?.isPlaying && (identity.includes(lowered) || lowered.includes(identity))
            })
            if (match)
                return match
        }

        return null
    }

    // Rebuilds the plain-data list AuroraPlayerSwitcher renders from.
    // Only called when the player set or the selection actually
    // changes, not on every position tick - AuroraState.players
    // rarely needs to change even while AuroraState.position does,
    // every second, while something is playing.
    function syncPlayerList() {
        const active = provider.resolveActivePlayer()

        const live = provider.meaningfulPlayers.map(p => ({
            identity: p?.identity ?? "",
            title: p?.trackTitle ?? "",
            selected: p === active,
            // Only Playing/Paused are real MPRIS states reachable
            // here - a player almost always just leaves the bus
            // instead of reporting Stopped, so there's nothing
            // reliable to map to it. See DECISIONS.md → "Fase 4:
            // estados de fuente".
            status: p?.isPlaying ? "Playing" : "Paused"
        }))

        const liveIdentities = live.map(p => p.identity.toLowerCase())

        // Sources listed in AuroraConfig.sourcePriority but not
        // currently seen on the bus get a synthetic "Offline" entry
        // instead of just disappearing - lets AuroraPlayerSwitcher
        // show "these are the sources Aurora knows about", not only
        // "these happen to be open right now". Nothing appears here
        // unless sourcePriority is actually configured.
        const offline = (AuroraConfig.sourcePriority ?? [])
            .filter(name => {
                const lowered = (name ?? "").toLowerCase()
                return !liveIdentities.some(identity => identity.includes(lowered) || lowered.includes(identity))
            })
            .map(name => ({
                identity: name,
                title: "",
                selected: false,
                status: "Offline"
            }))

        AuroraState.players = live.concat(offline)
    }

    // identity: one of AuroraState.players[i].identity. Re-syncs
    // immediately instead of waiting for the next MPRIS event, so
    // tapping a chip in AuroraPlayerSwitcher feels instant. No-op on
    // an Offline entry's identity - there's no real player behind it
    // to pin to, so resolveActivePlayer() would just clear the pin
    // again on the next sync.
    function selectPlayer(identity) {
        const isReal = provider.meaningfulPlayers.some(p => (p?.identity ?? "") === identity)
        if (!isReal)
            return

        provider.selectedIdentity = identity
        provider.saveLastSource(identity)
        provider.syncPlayer()
        provider.syncPlayerList()
    }

    function syncPlayer() {

        // resolveActivePlayer() returns the manually selected source
        // if selectPlayer() pinned one and it's still around, else
        // the priority-based pick or MprisController.activePlayer -
        // same as before multi-player selection existed, so a
        // single-player setup behaves identically to today.
        const p = provider.resolveActivePlayer()
        const wasConnected = AuroraState.connected
        const previousTitle = AuroraState.title
        const previousArtist = AuroraState.artist

        AuroraState.connected = !!p

        if (!AuroraState.connected) {
            clearState()
            if (wasConnected)
                AuroraState.connectionChanged(false)
            return
        }

        if (!wasConnected)
            AuroraState.connectionChanged(true)

        AuroraState.playerName = p?.identity ?? ""

        AuroraState.playbackState = p?.isPlaying ? "Playing" : "Paused"

        AuroraState.title = p?.trackTitle ?? ""
        AuroraState.artist = p?.trackArtist ?? ""
        AuroraState.album = p?.trackAlbum ?? ""

        AuroraState.coverArt = p?.trackArtUrl ?? ""

        AuroraState.duration = p?.length ?? 0
        AuroraState.position = p?.position ?? 0
        AuroraState.canSeek = p?.canSeek ?? false

        // Shuffle/LoopStatus are optional in the MPRIS spec - not every
        // player exposes them. Reading a property Quickshell's MprisPlayer
        // doesn't define just yields undefined here, so this degrades to
        // "off" instead of failing.
        AuroraState.shuffleEnabled = p?.shuffle ?? false
        AuroraState.repeatMode = p?.loopStatus ?? "None"

        if (AuroraState.title !== previousTitle || AuroraState.artist !== previousArtist)
            AuroraState.trackChanged()
    }

    // ------------------------------------------------------------
    // MARK: Commands
    // AuroraState.togglePlaying() / .next() / .previous() / .seek() /
    // .toggleShuffle() / .cycleRepeat() / .selectPlayer() forward
    // straight to these - AuroraControls, AuroraInfo and
    // AuroraPlayerSwitcher call AuroraState, never this file directly.
    // ------------------------------------------------------------

    // All six read the currently displayed source via
    // resolveActivePlayer() - not MprisController.activePlayer
    // directly - so a command always lands on whichever player
    // AuroraState/AuroraPlayerSwitcher is actually showing, manual
    // selection included. Controlling a different source than the
    // one on screen would be a worse bug than any of these being a
    // no-op.

    function togglePlaying() {
        provider.resolveActivePlayer()?.togglePlaying()
    }

    function next() {
        provider.resolveActivePlayer()?.next()
    }

    function previous() {
        provider.resolveActivePlayer()?.previous()
    }

    // fraction: 0.0 - 1.0 position along the timeline
    function seek(fraction) {
        const p = provider.resolveActivePlayer()
        if (p && p.canSeek && p.length > 0)
            p.position = fraction * p.length
    }

    // Both of these are no-ops if the active player doesn't expose the
    // property - checked instead of assumed, since Shuffle/LoopStatus
    // are optional in MPRIS and not every player implements them.
    function toggleShuffle() {
        const p = provider.resolveActivePlayer()
        if (!p || p.shuffle === undefined)
            return
        p.shuffle = !p.shuffle
        AuroraState.shuffleEnabled = p.shuffle
    }

    function cycleRepeat() {
        const p = provider.resolveActivePlayer()
        if (!p || p.loopStatus === undefined)
            return
        const order = ["None", "Playlist", "Track"]
        const nextMode = order[(order.indexOf(p.loopStatus) + 1) % order.length]
        p.loopStatus = nextMode
        AuroraState.repeatMode = nextMode
    }

    // ------------------------------------------------------------
    // MARK: Persistence
    // Remembers the last manually selected source's identity across
    // restarts, when AuroraConfig.rememberLastSource is on. Uses core
    // Quickshell (FileView/JsonAdapter + Quickshell.statePath()) -
    // not a host-specific mechanism, same host-isolation rule
    // everything else in this file already follows for MPRIS itself.
    // See DECISIONS.md → "Fase 4: fuentes múltiples avanzadas".
    // ------------------------------------------------------------

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
        if (!AuroraConfig.rememberLastSource)
            return
        lastSource.identity = identity
    }

    // Called once from initialize(), before the first syncPlayer() -
    // only sets the pin, doesn't sync anything itself. If the saved
    // source isn't around, resolveActivePlayer() clears the pin the
    // same way it already does for any other stale selection.
    function restoreLastSource() {
        if (!AuroraConfig.rememberLastSource)
            return
        if (lastSource.identity)
            provider.selectedIdentity = lastSource.identity
    }

    // ------------------------------------------------------------
    // MARK: Position polling
    // MPRIS signals track/player changes but not a continuous
    // position tick while playing, so this fills the gap.
    // ------------------------------------------------------------

    Timer {
        interval: AuroraConfig.positionUpdateInterval
        running: AuroraState.playbackState === "Playing"
        repeat: true
        onTriggered: {
            AuroraState.position = provider.resolveActivePlayer()?.position ?? 0
        }
    }

    Connections {

        target: MprisController

        function onTrackChanged() {
            provider.syncPlayer()
            provider.syncPlayerList()
        }

        function onActivePlayerChanged() {
            provider.syncPlayer()
            provider.syncPlayerList()
        }
    }

    // Listens for the action signals AuroraState exposes
    // (togglePlaying/next/previous/seek/toggleShuffle/cycleRepeat/
    // selectPlayer) instead of AuroraState importing this file to call
    // it directly - see DECISIONS.md → "Actions go through
    // AuroraState". The functions below already existed for this same
    // purpose; this just wires them to fire when the signal does.
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
