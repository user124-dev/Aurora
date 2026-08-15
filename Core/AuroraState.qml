/*
 * AuroraState.qml — shared runtime state.
 * Providers own integrations; Components consume this state and emit actions.
 */
pragma Singleton

import QtQuick

QtObject {
    id: state

    // Player
    property bool connected: false
    property string playerName: ""
    property string playbackState: "Stopped"
    property bool canGoNext: false
    property bool canGoPrevious: false

    // Multi-player
    property var players: []

    // Track
    property string title: ""
    property string artist: ""
    property string album: ""

    // Cover
    property url coverArt: ""

    // Timeline
    property real duration: 0
    property real position: 0
    readonly property real progress:
        duration > 0 ? Math.max(0, Math.min(1, position / duration)) : 0
    property bool canSeek: false

    // Audio / visualizer
    property real spectrumLevel: 0.0
    property list<real> spectrumLevels: []
    property bool audioAvailable: false

    // PipeWire / system audio
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
    property bool equalizerAvailable: false
    property var equalizerPresets: []
    property string currentPreset: ""
    property bool effectsManaged: false
    property bool effectsWarning: false
    property string effectsBackend: ""

    // Session queue / history. Aurora owns this session layer; it never
    // pretends that MPRIS Playlists are universally available.
    property var sessionQueue: []
    property var sessionHistory: []
    property int sessionQueueIndex: -1
    property string sessionSource: ""
    property string sessionPlaybackStatus: "Idle"
    property string sessionPlaybackMessage: ""

    // Lyrics
    property bool lyricsAvailable: false
    property bool lyricsLoading: false
    property string lyricsStatus: "Unavailable"
    property string lyricsPlain: ""
    property string lyricsSynced: ""
    property var lyricsLines: []
    property int lyricsCurrentLine: -1

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
