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
 * Single Source of Truth.
 */
pragma Singleton

import QtQuick

QtObject {
    id: state

    //
    // Player
    //
    property bool connected: false
    property string playerName: ""
    property string playbackState: "Stopped"

    //
    // Multi-player
    // AuroraPlayerProvider dedupes MPRIS sources that describe the
    // same audio twice (a browser tab mirroring a native player) and
    // writes the survivors here as plain data - AuroraPlayerSwitcher
    // renders from this, never from MprisController directly.
    //
    property var players: []

    //
    // Track
    //
    property string title: ""
    property string artist: ""
    property string album: ""

    //
    // Cover
    //
    property url coverArt: ""

    //
    // Timeline
    //
    // MPRIS exposes duration/position as time values and they can contain
    // fractions of a second. Keeping them as real values avoids visible
    // truncation/jumps in the seek bar while playback is progressing.
    //
    property real duration: 0
    property real position: 0

    // Calculated automatically from duration and position.
    // Clamp the value so a provider hiccup can never make the UI render
    // outside the valid 0..1 progress range.
    readonly property real progress:
        duration > 0 ? Math.max(0, Math.min(1, position / duration)) : 0

    property bool canSeek: false

    //
    // Audio
    //
    // `spectrumLevels` contains the normalized 0..1 bars supplied by
    // AuroraAudioProvider. Components consume this data only; they never
    // access cava directly.
    //
    property real spectrumLevel: 0.0
    property list<real> spectrumLevels: []
    property bool audioAvailable: false

    //
    // Playback modes
    // Not every MPRIS player exposes these - AuroraPlayerProvider
    // defaults to false/"None" when a player doesn't support them.
    //
    property bool shuffleEnabled: false
    property string repeatMode: "None" // "None" | "Track" | "Playlist"

    //
    // Equalizer
    // Written exclusively by AuroraEqualizerProvider. `equalizerAvailable`
    // reflects whether EasyEffects was detected on this system - components
    // should hide/disable equalizer UI when it's false rather than assume
    // presence, same graceful-absence pattern AuroraAudioProvider already
    // uses for cava. `presets` are names only (no file paths) - Components
    // never see the filesystem layer, same rule as everything else here.
    //
    property bool equalizerAvailable: false
    property var equalizerPresets: []
    property string currentPreset: ""

    //
    // Plugins
    // Third-party code writes here, and only here - never into any
    // property above. Keyed by plugin name (AuroraState.plugins["foo"]),
    // written via AuroraPluginRegistry so a plugin can never collide with
    // what the official Providers already own. See Core/AuroraPluginRegistry.qml
    // and Blueprint/PLUGINS.md.
    //
    property var plugins: ({})

    //
    // Widget
    //
    property int widgetMode: AuroraConfig.compact

    //
    // Events
    // Property changes already emit onXChanged individually, but
    // that's noisy for a listener that just wants "a new track
    // started" as one event instead of three (title, then artist,
    // then album landing separately as the provider syncs them).
    //
    signal trackChanged()
    signal connectionChanged(bool connected)

    //
    // Actions
    // Signals, not forwarding functions - AuroraState never imports a
    // Provider to call it directly (that would be a Core/ file
    // depending on Providers/, the one dependency direction this
    // project rules out - see DECISIONS.md → "Actions go through
    // AuroraState"). AuroraPlayerProvider listens via Connections and
    // acts on whichever player resolveActivePlayer() is showing.
    // Components still just call AuroraState.togglePlaying() etc. -
    // invoking a signal and calling a function look identical from
    // the caller's side, so nothing outside this file changes.
    //
    signal togglePlaying()
    signal next()
    signal previous()
    signal seek(real fraction)
    signal toggleShuffle()
    signal cycleRepeat()
    signal selectPlayer(string identity)
    signal setPreset(string name)
}
