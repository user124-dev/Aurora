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
    }

    function syncPlayer() {

        AuroraState.connected =
            MprisController.activePlayer !== null

        if (!AuroraState.connected) {
            clearState()
            return
        }

        AuroraState.playerName =
            MprisController.activePlayer?.identity ?? ""

        AuroraState.playbackState =
            MprisController.isPlaying ? "Playing" : "Paused"

        AuroraState.title =
            MprisController.activeTrack?.title ?? ""

        AuroraState.artist =
            MprisController.activeTrack?.artist ?? ""

        AuroraState.album =
            MprisController.activeTrack?.album ?? ""

        AuroraState.coverArt =
            MprisController.activeTrack?.artUrl ?? ""
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
