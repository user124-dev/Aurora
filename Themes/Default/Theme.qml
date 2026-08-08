/*
 * ╔══════════════════════════════════════════════════════════════╗
 * ║                      Aurora Player                          ║
 * ╚══════════════════════════════════════════════════════════════╝
 *
 * File        : Theme.qml
 * Module      : Themes/Default
 * Component   : Bundled Palette
 * Version     : 0.1.0-dev
 *
 * Description:
 * Aurora's own palette. Static data only - no imports, no host
 * dependency. This remains Aurora's host-independent fallback palette.
 * The runtime default is ThemeSystem; this palette can be selected explicitly.
 */

pragma Singleton

import QtQuick

QtObject {

    readonly property color colorBackground: "#1a1a24"
    readonly property color colorOnBackground: "#e8e6f0"
    readonly property color colorContainer: "#2a2a3a"
    readonly property color colorMuted: "#8f8ba8"
    readonly property color colorPrimary: "#7dd8c8"
    readonly property color colorOnPrimary: "#0c2420"
    readonly property color colorOutline: "#38384a"

    readonly property string fontFamily: "sans-serif"
    readonly property int fontSizeSmall: 11
    readonly property int fontSizeNormal: 13
    readonly property int fontSizeLarge: 15
    readonly property int fontSizeHuge: 22
}
