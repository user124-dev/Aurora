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


    // ============================================================
    // MARK: Cover
    // ============================================================

    readonly property int coverSize: 110
    readonly property real coverRadius: 18

    // Outer widget shape - separate from coverRadius even though
    // they currently match, so changing one doesn't silently change
    // the other.
    readonly property real widgetRadius: 18


    // ============================================================
    // MARK: Spectrum
    // ============================================================

    readonly property int bars: 48
    readonly property int barSpacing: 2
    readonly property real logoOpacity: 0.10


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
