pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// Compatibility adapter around Quickshell's official MPRIS API.
// AuroraPlayerProvider consumes this stable interface instead of importing
// a host-specific service such as End-4/ii's qs.services.
Singleton {
    id: controller

    readonly property var players: Mpris.players.values
    readonly property var activePlayer: chooseActive(players)

    property string lastSignature: ""
    property string lastActiveIdentity: ""

    function chooseActive(list) {
        if (!list || list.length === 0)
            return null

        // Prefer an actually playing source. If nothing is playing, retain
        // the first connected player as the deterministic fallback.
        const playing = list.find(player => player?.isPlaying)
        return playing ?? list[0]
    }

    function playerKey(player) {
        // dbusName distinguishes multiple instances with the same human
        // readable identity. It is preferred for change detection only;
        // Components continue to receive human-readable identity strings.
        return player?.dbusName || player?.identity || ""
    }

    function signature(list) {
        return (list ?? []).map(player => [
            controller.playerKey(player),
            player?.uniqueId ?? "",
            player?.trackTitle ?? "",
            player?.trackArtist ?? "",
            player?.trackAlbum ?? "",
            player?.trackArtUrl ?? "",
            player?.playbackState ?? "",
            player?.isPlaying ? "1" : "0"
        ].join("|")).join(";;")
    }

    function refresh() {
        const nextSignature = controller.signature(controller.players)
        const nextActive = controller.activePlayer
        const nextIdentity = controller.playerKey(nextActive)

        if (nextSignature !== controller.lastSignature) {
            controller.lastSignature = nextSignature
            controller.auroraTrackChanged()
        }

        if (nextIdentity !== controller.lastActiveIdentity) {
            controller.lastActiveIdentity = nextIdentity
            controller.auroraActivePlayerChanged()
        }
    }

    // These names intentionally avoid colliding with Qt/QML's automatic
    // property change signals (activePlayerChanged, playersChanged, etc.).
    signal auroraTrackChanged()
    signal auroraActivePlayerChanged()

    Timer {
        interval: 250
        running: true
        repeat: true
        onTriggered: controller.refresh()
    }

    Component.onCompleted: controller.refresh()
}
