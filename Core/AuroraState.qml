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
  	property int duration: 0
  	property int position: 0
  
  	// Calculated automatically from duration and position.
  	readonly property real progress:
    duration > 0 ? position / duration : 0

  	property bool canSeek: false

    //
    // Audio
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
    // Plugins
    // Third-party code writes here, and only here - never into any
    // property above. Keyed by plugin name (AuroraState.plugins["foo"]),
    // written via AuroraPluginRegistry so a plugin can never collide
    // with what the three official Providers already own. See
    // Core/AuroraPluginRegistry.qml and Blueprint/PLUGINS.md.
    //
    property var plugins: ({})

    //
    // Widget
    //
     property int widgetMode: AuroraConfig.Compact
    //
    // Debug
    //
    readonly property bool ready: true

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
}
