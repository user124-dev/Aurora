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
 * Reads information from MPRIS and updates AuroraState.
 * Also the single point of contact for sending playback
 * commands back out to MPRIS — components should call the
 * functions below instead of touching MprisController directly.
 */

pragma Singleton

import QtQuick
import qs.services
import "../Core"

// Note: qs.services is a hard import. If it's missing (a host other
// than "ii"), this file fails to load at parse time - no runtime
// guard here can catch that. See Blueprint/DECISIONS.md.

QtObject {

    id: provider

    function initialize() {
        console.log("[Aurora] PlayerProvider initialized")
        syncPlayer()
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

    function syncPlayer() {

        // Read everything off activePlayer directly (not a
        // separate activeTrack shortcut — MprisController does not
        // expose one, going by how both reference files use it).
        const p = MprisController.activePlayer
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
    // .toggleShuffle() / .cycleRepeat() forward straight to these -
    // AuroraControls and AuroraInfo call AuroraState, never this
    // file directly.
    // ------------------------------------------------------------

    function togglePlaying() {
        MprisController.activePlayer?.togglePlaying()
    }

    function next() {
        MprisController.activePlayer?.next()
    }

    function previous() {
        MprisController.activePlayer?.previous()
    }

    // fraction: 0.0 - 1.0 position along the timeline
    function seek(fraction) {
        const p = MprisController.activePlayer
        if (p && p.canSeek && p.length > 0)
            p.position = fraction * p.length
    }

    // Both of these are no-ops if the active player doesn't expose the
    // property - checked instead of assumed, since Shuffle/LoopStatus
    // are optional in MPRIS and not every player implements them.
    function toggleShuffle() {
        const p = MprisController.activePlayer
        if (!p || p.shuffle === undefined)
            return
        p.shuffle = !p.shuffle
        AuroraState.shuffleEnabled = p.shuffle
    }

    function cycleRepeat() {
        const p = MprisController.activePlayer
        if (!p || p.loopStatus === undefined)
            return
        const order = ["None", "Playlist", "Track"]
        const nextMode = order[(order.indexOf(p.loopStatus) + 1) % order.length]
        p.loopStatus = nextMode
        AuroraState.repeatMode = nextMode
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
            AuroraState.position = MprisController.activePlayer?.position ?? 0
        }
    }

    Connections {

        target: MprisController

        function onTrackChanged() {
            provider.syncPlayer()
        }

        function onActivePlayerChanged() {
            provider.syncPlayer()
        }
    }
}
