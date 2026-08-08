pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// Small compatibility adapter around Quickshell's official MPRIS API.
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

        const playing = list.find(player => player?.isPlaying)
        return playing ?? list[0]
    }

    function signature(list) {
        return (list ?? []).map(player => [
            player?.identity ?? "",
            player?.trackTitle ?? "",
            player?.trackArtist ?? "",
            player?.isPlaying ? "1" : "0"
        ].join("|")).join(";;")
    }

    function refresh() {
        const nextSignature = controller.signature(controller.players)
        const nextActive = controller.activePlayer
        const nextIdentity = nextActive?.identity ?? ""

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
