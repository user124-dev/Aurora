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

    readonly property int Compact: 0
    readonly property int Hover: 1
    readonly property int Expanded: 2


    // ============================================================
    // MARK: Theme Mode
    // ============================================================

    readonly property int ThemeAurora: 0
    readonly property int ThemeSystem: 1

    // Defaults to Aurora's own bundled theme, so the widget looks
    // right with zero host integration. Set to ThemeSystem to pull
    // colors from the host shell instead - see AuroraThemeProvider,
    // the only file that knows how to read a given host's theme.
    property int themeMode: ThemeAurora


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


    // ============================================================
    // MARK: Spectrum
    // ============================================================

    readonly property int bars: 48
    readonly property int barSpacing: 2
    readonly property real logoOpacity: 0.10

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


    // ============================================================
    // MARK: Player Switcher
    // ============================================================

    // Only rendered by AuroraPlayerSwitcher when there's more than
    // one MPRIS source to choose from - height matches
    // secondaryButtonSize for visual consistency with Shuffle/Repeat.
    readonly property int switcherChipHeight: 22
    readonly property int switcherChipSpacing: 6
    readonly property int switcherChipPadding: 10


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
    // MARK: Developer
    // ============================================================

    property bool developerMode: false

}
