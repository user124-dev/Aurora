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
import "../Providers"

QtObject {
    id: state

    //
    // Player
    //
    property bool connected: false
	property string playerName: ""
    property string playbackState: "Stopped"
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
    // Components call these instead of importing AuroraPlayerProvider
    // directly - keeps "components depend only on AuroraState" true
    // for commands, not just for reading data.
    //
    function togglePlaying() { AuroraPlayerProvider.togglePlaying() }
    function next() { AuroraPlayerProvider.next() }
    function previous() { AuroraPlayerProvider.previous() }
    function seek(fraction) { AuroraPlayerProvider.seek(fraction) }
}
