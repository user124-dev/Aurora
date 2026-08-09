/*
 * ╔══════════════════════════════════════════════════════════════╗
 * ║                      Aurora Player                          ║
 * ╚══════════════════════════════════════════════════════════════╝
 *
 * File        : AuroraConfig.qml
 * Module      : Core
 * Component   : Configuration
 * Version     : 0.1.0-dev
 *
 * Description:
 * Global configuration shared across every Aurora component.
 */

pragma Singleton

import QtQuick

QtObject {
    readonly property int compact: 0
    readonly property int hover: 1
    readonly property int expanded: 2

    readonly property int themeAurora: 0
    readonly property int themeSystem: 1

    property int themeMode: themeAurora

    readonly property int compactWidth: 48
    readonly property int compactHeight: 48
    readonly property int hoverWidth: 360
    readonly property int hoverHeight: 72

    // Expanded needs enough vertical budget for switcher + cover/info +
    // spectrum + controls without forcing the layout to overflow. The
    // extra width also leaves a clean area for the future equalizer section.
    readonly property int expandedWidth: 620
    readonly property int expandedHeight: 380

    readonly property int widgetPadding: 8
    readonly property int widgetSpacing: 10
    readonly property int expandedPadding: 20
    readonly property int expandedSpacing: 14

    readonly property int coverSize: 110
    readonly property real coverRadius: 18
    readonly property real widgetRadius: 18
    readonly property int expandedCoverSize: 120
    readonly property int coverBorderWidth: 1
    readonly property real coverFallbackIconRatio: 0.4

    readonly property real backgroundArtOpacity: 0.35
    readonly property real backgroundDimOpacity: 0.55
    readonly property real backgroundBlurRadius: 64
    readonly property real backgroundBlurStrength: 1.0
    readonly property real backgroundPanelOpacity: 0.98
    readonly property int backgroundBorderWidth: 1

    readonly property int bars: 48
    readonly property int barSpacing: 2
    readonly property real logoOpacity: 0.10
    readonly property int spectrumHeight: 28
    readonly property int spectrumIdleInterval: 120
    readonly property real spectrumMaxRange: 1000
    readonly property real spectrumGain: 1.35
    readonly property real spectrumGamma: 0.82
    readonly property real spectrumNoiseFloor: 0.015
    readonly property real spectrumMinBarWidth: 1
    readonly property real spectrumMinBarHeight: 2
    readonly property real spectrumIdleBaseLevel: 0.15
    readonly property real spectrumIdleAmplitude: 0.15
    readonly property real spectrumIdleWaveSpeed: 0.5
    readonly property real spectrumIdleRestLevel: 0.06
    readonly property real spectrumIdleOpacity: 0.3
    readonly property int spectrumAnimation: 70
    readonly property int expandedSpectrumHeight: 90

    readonly property int controlButtonSize: 26
    readonly property int playButtonSize: 32
    readonly property int secondaryButtonSize: 22
    readonly property int controlsButtonSpacing: 4
    readonly property int controlsRowSpacing: 8
    readonly property int seekTrackHeight: 6
    readonly property real shuffleIconRatio: 0.6
    readonly property real repeatIconRatio: 0.62
    readonly property real repeatBadgeRatio: 0.34
    readonly property int transportGlyphSpacing: 1
    readonly property int transportBarWidth: 2
    readonly property int transportGlyphWidth: 8
    readonly property int transportGlyphHeight: 10
    readonly property int playPauseGlyphWidth: 12
    readonly property int playPauseGlyphHeight: 14
    readonly property int pauseBarWidth: 4
    readonly property int pauseGlyphBarSpacing: 3
    readonly property int repeatBadgeMargin: -2
    readonly property real playHoverFactor: 0.85
    readonly property real connectedOpacity: 1.0
    readonly property real disconnectedOpacity: 0.5

    readonly property int infoRowSpacing: 2
    readonly property int infoProgressTopMargin: 2
    readonly property int infoTimeTopMargin: 1

    readonly property int switcherChipHeight: 22
    readonly property int switcherChipSpacing: 6
    readonly property int switcherChipPadding: 10
    readonly property int switcherStatusDotSize: 6
    readonly property real switcherOfflineOpacity: 0.45
    readonly property int switcherOfflineBorderWidth: 1

    property bool mergeDuplicatePlayers: true
    property var sourcePriority: []
    property bool autoSwitchEnabled: false
    property bool rememberLastSource: false
    readonly property real duplicatePositionTolerance: 2
    readonly property real duplicateLengthTolerance: 2

    readonly property int positionUpdateInterval: 1000
    readonly property int fastAnimation: 150
    readonly property int normalAnimation: 250
    readonly property int slowAnimation: 450
    readonly property int hoverDelay: 150
    readonly property int hideDelay: 250

    property bool developerMode: false

    // How deep AuroraEqualizerProvider scans EasyEffects' output-preset
    // folder for `.json` files. 1 = top-level only, matching EasyEffects'
    // own flat preset layout - not a filesystem limit, a deliberate
    // decision so a preset that some other tool nests in a subfolder
    // doesn't silently show up as if EasyEffects itself created it.
    readonly property int equalizerPresetScanDepth: 1
}
