/*
 * ╔══════════════════════════════════════════════════════════════╗
 * ║                      Aurora Player                          ║
 * ╚══════════════════════════════════════════════════════════════╝
 *
 * File        : AuroraTheme.qml
 * Module      : Core
 * Component   : Theme Contract
 * Version     : 0.1.0-dev
 *
 * Description:
 * The only visual contract that visual components may read for
 * colors and typography. Defaults to Aurora's own bundled palette
 * (Themes/Default/Theme.qml), so this already looks right before
 * AuroraThemeProvider ever runs.
 *
 * Philosophy:
 * Components read AuroraTheme. Only AuroraThemeProvider writes it.
 * Nothing else in Aurora should know a host theme system exists.
 */

pragma Singleton

import QtQuick
import "../Themes/Default"

QtObject {

    // ============================================================
    // MARK: Colors
    // ============================================================

    property color colorBackground: Theme.colorBackground
    property color colorOnBackground: Theme.colorOnBackground
    property color colorContainer: Theme.colorContainer
    property color colorMuted: Theme.colorMuted
    property color colorPrimary: Theme.colorPrimary
    property color colorOnPrimary: Theme.colorOnPrimary
    property color colorOutline: Theme.colorOutline


    // ============================================================
    // MARK: Typography
    // ============================================================

    property string fontFamily: Theme.fontFamily
    property int fontSizeSmall: Theme.fontSizeSmall
    property int fontSizeNormal: Theme.fontSizeNormal
    property int fontSizeLarge: Theme.fontSizeLarge
    property int fontSizeHuge: Theme.fontSizeHuge
}
