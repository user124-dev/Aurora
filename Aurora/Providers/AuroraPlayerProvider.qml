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
    }

    function syncPlayer() {

        // Read everything off activePlayer directly (not a
        // separate activeTrack shortcut — MprisController does not
        // expose one, going by how both reference files use it).
        const p = MprisController.activePlayer

        AuroraState.connected = !!p

        if (!AuroraState.connected) {
            clearState()
            return
        }

        AuroraState.playerName = p?.identity ?? ""

        AuroraState.playbackState = p?.isPlaying ? "Playing" : "Paused"

        AuroraState.title = p?.trackTitle ?? ""
        AuroraState.artist = p?.trackArtist ?? ""
        AuroraState.album = p?.trackAlbum ?? ""

        AuroraState.coverArt = p?.trackArtUrl ?? ""

        AuroraState.duration = p?.length ?? 0
        AuroraState.position = p?.position ?? 0
        AuroraState.canSeek = p?.canSeek ?? false
    }

    // ------------------------------------------------------------
    // MARK: Commands
    // Controls.qml and Info.qml call these instead of reaching
    // into MprisController themselves.
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
