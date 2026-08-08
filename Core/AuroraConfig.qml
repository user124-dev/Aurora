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
 *
 * Philosophy:
 * No magic numbers.
 * Everything configurable lives here.
 */

pragma Singleton

import QtQuick

QtObject {

    // ============================================================
    // MARK: Widget Modes
    // ============================================================

    readonly property int compact: 0
    readonly property int hover: 1
    readonly property int expanded: 2


    // ============================================================
    // MARK: Theme Mode
    // ============================================================

    readonly property int themeAurora: 0
    readonly property int themeSystem: 1

    // Defaults to Aurora's own bundled theme, so the widget looks
    // right with zero host integration. Set to themeSystem to pull
    // colors from the host shell instead - see AuroraThemeProvider,
    // the only file that knows how to read a given host's theme.
    property int themeMode: themeAurora


    // ============================================================
    // MARK: Widget Size
    // ============================================================

    readonly property int compactWidth: 48
    readonly property int compactHeight: 48

    readonly property int hoverWidth: 360
    readonly property int hoverHeight: 72

    readonly property int expandedWidth: 520
    readonly property int expandedHeight: 300

    // Shared padding/spacing for AuroraCompactView and AuroraHoverView -
    // named now instead of the literal 8/10 that used to sit directly
    // inside AuroraPlayer.qml's old RowLayout.
    readonly property int widgetPadding: 8
    readonly property int widgetSpacing: 10


    // ============================================================
    // MARK: Expanded Layout
    // ============================================================

    // AuroraExpandedView is the first real layout for the 520x300
    // AuroraConfig always reserved - own padding/spacing instead of
    // reusing widgetPadding/widgetSpacing, since it has room to breathe
    // that the Compact/Hover strip never did.
    readonly property int expandedPadding: 20
    readonly property int expandedSpacing: 14


    // ============================================================
    // MARK: Cover
    // ============================================================

    readonly property int coverSize: 110
    readonly property real coverRadius: 18

    // Outer widget shape - separate from coverRadius even though
    // they currently match, so changing one doesn't silently change
    // the other.
    readonly property real widgetRadius: 18

    // Bigger cover for AuroraExpandedView - the only place with
    // enough vertical room to justify it.
    readonly property int expandedCoverSize: 120

    // Fallback state (no art yet / not connected): outline width and
    // how big the placeholder note glyph reads relative to the cover.
    readonly property int coverBorderWidth: 1
    readonly property real coverFallbackIconRatio: 0.4


    // ============================================================
    // MARK: Background
    // ============================================================

    // AuroraBackground's ambient blurred-art layer: how visible the
    // art itself is, and how much the dimming layer on top of it
    // darkens things back down so foreground text stays readable
    // regardless of how bright the art is.
    readonly property real backgroundArtOpacity: 0.35
    readonly property real backgroundDimOpacity: 0.55
    readonly property real backgroundBlurRadius: 64

    // The panel itself - separate constant from coverBorderWidth even
    // though both are currently 1, same reasoning as coverRadius vs
    // widgetRadius: changing one shouldn't silently change the other.
    readonly property real backgroundPanelOpacity: 0.98
    readonly property int backgroundBorderWidth: 1


    // ============================================================
    // MARK: Spectrum
    // ============================================================

    readonly property int bars: 48
    readonly property int barSpacing: 2
    readonly property real logoOpacity: 0.10

    // Compact/Hover footprint - AuroraExpandedView overrides this via
    // Layout.fillHeight/expandedSpectrumHeight below instead of using
    // this value directly.
    readonly property int spectrumHeight: 28

    // Tick rate for the idle wave's sine animation when there's no
    // cava data yet but something is playing.
    readonly property int spectrumIdleInterval: 120

    // Minimum height in AuroraExpandedView; Layout.fillHeight lets it
    // grow past this into whatever room the card has left over.
    readonly property int expandedSpectrumHeight: 64


    // ============================================================
    // MARK: Controls
    // ============================================================

    readonly property int controlButtonSize: 26
    readonly property int playButtonSize: 32
    // Shuffle / Repeat - smaller than transport, since they're toggles
    // rather than the primary play/pause/skip cluster.
    readonly property int secondaryButtonSize: 22
    readonly property int controlsButtonSpacing: 4
    readonly property int controlsRowSpacing: 8
    readonly property int seekTrackHeight: 6

    // Hand-drawn icon glyphs (Text/Shape, not an icon font) size
    // themselves as a ratio of their own button's width, not a fixed
    // pixel value - so they stay proportional if a button size above
    // ever changes.
    readonly property real shuffleIconRatio: 0.6
    readonly property real repeatIconRatio: 0.62
    readonly property real repeatBadgeRatio: 0.34

    // Internal spacing inside the hand-drawn Previous/Next glyphs
    // (bar + triangle) and the paused-state two-bar Play/Pause glyph.
    readonly property int transportGlyphSpacing: 1
    readonly property int pauseGlyphBarSpacing: 3


    // ============================================================
    // MARK: Player Switcher
    // ============================================================

    // Only rendered by AuroraPlayerSwitcher when there's more than
    // one MPRIS source to choose from - height matches
    // secondaryButtonSize for visual consistency with Shuffle/Repeat.
    readonly property int switcherChipHeight: 22
    readonly property int switcherChipSpacing: 6
    readonly property int switcherChipPadding: 10

    // Status dot inside each chip (Playing/Paused/Offline) - see
    // AuroraPlayerSwitcher.qml and DECISIONS.md → "Fase 4: fuentes
    // múltiples avanzadas".
    readonly property int switcherStatusDotSize: 6
    readonly property real switcherOfflineOpacity: 0.45
    readonly property int switcherOfflineBorderWidth: 1


    // ============================================================
    // MARK: Sources
    // Configuration for AuroraPlayerProvider's multi-source handling -
    // none of this changes anything by default (every property below
    // preserves the exact behavior Aurora had before Fase 4's source
    // work), it only turns on once set explicitly. See PROVIDERS.md
    // and DECISIONS.md → "Fase 4: fuentes múltiples avanzadas".
    // ============================================================

    // Whether MprisController.players entries describing the same
    // audio twice (a browser tab mirroring a native player) collapse
    // into one via computeMeaningfulPlayers(). Off shows every raw
    // MPRIS entry, duplicates included.
    property bool mergeDuplicatePlayers: true

    // Ordered list of identity substrings (matched case-insensitively,
    // same convention as isSameTrack()/looksLikeBrowser() elsewhere in
    // the project - MPRIS identities aren't standardized enough for an
    // exact match). Doubles as the "known sources" list for the
    // synthetic Offline status below. Empty means no priority and no
    // Offline entries - same as before this existed.
    property var sourcePriority: []

    // When true and sourcePriority is non-empty, automatically follows
    // the highest-priority source that's currently playing instead of
    // whatever MPRIS calls "active". A manual selectPlayer() call
    // always wins over this - see AuroraPlayerProvider.resolveActivePlayer().
    property bool autoSwitchEnabled: false

    // Persists the last manually selected source's identity to disk
    // (Quickshell.statePath(), via FileView/JsonAdapter - core
    // Quickshell, not a host-specific mechanism) and restores it the
    // next time Aurora starts.
    property bool rememberLastSource: false


    // ============================================================
    // MARK: Playback Sync
    // ============================================================

    // MPRIS does not push position updates continuously while playing,
    // so the provider polls on this interval to keep the timeline live.
    readonly property int positionUpdateInterval: 1000


    // ============================================================
    // MARK: Animations
    // ============================================================

    readonly property int fastAnimation: 150
    readonly property int normalAnimation: 250
    readonly property int slowAnimation: 450


    // ============================================================
    // MARK: Hover
    // ============================================================

    readonly property int hoverDelay: 150
    readonly property int hideDelay: 250


    // ============================================================
    // MARK: Plugins
    // ============================================================

    // Absolute paths or file:// URLs to third-party plugin .qml files -
    // not relative paths, since AuroraPluginRegistry loads these via
    // Qt.createComponent() and a plugin can live anywhere. Empty by
    // default: Aurora does nothing extra unless you actually add one.
    // See Blueprint/PLUGINS.md.
    property var pluginPaths: []


    // ============================================================
    // MARK: Developer
    // ============================================================

    property bool developerMode: false

}
