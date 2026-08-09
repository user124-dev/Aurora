/*
 * ╔══════════════════════════════════════════════════════════════╗
 * ║                      Aurora Player                          ║
 * ╚══════════════════════════════════════════════════════════════╝
 *
 * File        : AuroraState.qml
 * Module      : Core
 * Component   : Global State
 * Version     : 0.1.0-dev
 *
 * Description:
 * Stores the shared runtime state used by all Aurora components.
 *
 * Philosophy:
 * Single Source of Truth. Providers own integrations; Components only
 * consume this state and emit actions through its signals.
 */
pragma Singleton

import QtQuick

QtObject {
    id: state

    // Player
    property bool connected: false
    property string playerName: ""
    property string playbackState: "Stopped"

    // Multi-player
    property var players: []

    // Track
    property string title: ""
    property string artist: ""
    property string album: ""

    // Cover
    property url coverArt: ""

    // Timeline
    // MPRIS exposes these as real-valued seconds with millisecond precision.
    property real duration: 0
    property real position: 0
    readonly property real progress:
        duration > 0 ? Math.max(0, Math.min(1, position / duration)) : 0
    property bool canSeek: false

    // Audio / visualizer
    // `audioAvailable` describes the visualizer sample source (currently
    // Cava). PipeWire state is kept separately because PipeWire describes
    // the system audio graph, not spectrum samples.
    property real spectrumLevel: 0.0
    property list<real> spectrumLevels: []
    property bool audioAvailable: false

    // PipeWire / system audio
    // Written exclusively by AuroraPipewireProvider. Quickshell's official
    // PipeWire API is the primary integration layer; direct pw-* commands
    // are deliberately not part of the normal runtime path.
    property bool pipewireAvailable: false
    property bool pipewireReady: false
    property string defaultOutputName: ""
    property string defaultOutputDescription: ""
    property real defaultOutputVolume: 0
    property bool defaultOutputMuted: false
    property var audioStreams: []

    // Playback modes
    property bool shuffleEnabled: false
    property string repeatMode: "None"

    // Equalizer / effects
    // EasyEffects remains optional. These properties describe discovery
    // and preset state without claiming that Aurora owns the whole effects
    // graph. Snapshot/restore ownership is separate so Aurora never resets
    // user changes accidentally.
    property bool equalizerAvailable: false
    property var equalizerPresets: []
    property string currentPreset: ""
    property bool effectsManaged: false
    property bool effectsWarning: false
    property string effectsBackend: ""

    // Plugins
    property var plugins: ({})

    // Widget
    property int widgetMode: AuroraConfig.compact

    // Events
    signal trackChanged()
    signal connectionChanged(bool connected)

    // Actions
    signal togglePlaying()
    signal next()
    signal previous()
    signal seek(real fraction)
    signal toggleShuffle()
    signal cycleRepeat()
    signal selectPlayer(string identity)
    signal setPreset(string name)
}
