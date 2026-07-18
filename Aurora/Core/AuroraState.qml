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

    //
    // Audio
    //
	property real spectrumLevel: 0.0
    //
    // Widget
    //
     property int widgetMode: AuroraConfig.Compact
    //
    // Debug
    //
    readonly property bool ready: true
}
