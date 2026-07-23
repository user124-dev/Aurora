/*
 * ╔══════════════════════════════════════════════════════════════╗
 * ║                      Aurora Player                          ║
 * ╚══════════════════════════════════════════════════════════════╝
 *
 * File        : AuroraThemeProvider.qml
 * Module      : Providers
 * Component   : Theme Provider
 * Version     : 0.1.0-dev
 *
 * Description:
 * Resolves AuroraTheme from one of two sources, based on
 * AuroraConfig.themeMode:
 *
 *   ThemeAurora  -> Themes/Default/Theme.qml (Aurora's own palette)
 *   ThemeSystem  -> the host's theme singleton
 *
 * This is the ONLY file in Aurora allowed to know a host theme
 * system exists. Porting Aurora to a shell other than "ii" means
 * rewriting applySystemTheme() below - nothing under Core/ or
 * Components/ should need to change.
 */

pragma Singleton

import QtQuick
import qs.modules.common
import "../Core"
import "../Themes/Default"

// Note: qs.modules.common is a hard import, same caveat as
// AuroraPlayerProvider - a host without it fails at parse time,
// regardless of themeMode. See Blueprint/DECISIONS.md.

QtObject {

    id: provider

    readonly property bool usingSystemTheme: AuroraConfig.themeMode === AuroraConfig.ThemeSystem

    function initialize() {
        console.log("[Aurora] ThemeProvider initialized")
        resolve()
    }

    // Note: resolve() copies values once, it does not bind AuroraTheme
    // to Appearance reactively. If the host's Appearance changes at
    // runtime (e.g. a dynamic wallpaper-based scheme) while themeMode
    // is already ThemeSystem, AuroraTheme will not follow it until
    // something calls resolve() again - see Blueprint/DECISIONS.md,
    // "Abierto / Pendiente". Making this reactive would mean either
    // AuroraTheme importing qs.modules.common directly (breaks host
    // isolation) or this file listening for a host color-change signal
    // that hasn't been confirmed to exist ("ii" doesn't document one).
    function resolve() {
        if (AuroraConfig.themeMode === AuroraConfig.ThemeSystem)
            applySystemTheme()
        else
            applyAuroraTheme()
    }

    // Aurora's own bundled look. Zero host dependency.
    function applyAuroraTheme() {
        AuroraTheme.colorBackground = Theme.colorBackground
        AuroraTheme.colorOnBackground = Theme.colorOnBackground
        AuroraTheme.colorContainer = Theme.colorContainer
        AuroraTheme.colorMuted = Theme.colorMuted
        AuroraTheme.colorPrimary = Theme.colorPrimary
        AuroraTheme.colorOnPrimary = Theme.colorOnPrimary
        AuroraTheme.colorOutline = Theme.colorOutline

        AuroraTheme.fontFamily = Theme.fontFamily
        AuroraTheme.fontSizeSmall = Theme.fontSizeSmall
        AuroraTheme.fontSizeNormal = Theme.fontSizeNormal
        AuroraTheme.fontSizeLarge = Theme.fontSizeLarge
        AuroraTheme.fontSizeHuge = Theme.fontSizeHuge
    }

    // The one place in Aurora that reads the "ii" host's Appearance
    // singleton. Swap this function to port Aurora elsewhere.
    function applySystemTheme() {
        AuroraTheme.colorBackground = Appearance.colors.colLayer1
        AuroraTheme.colorOnBackground = Appearance.colors.colOnLayer1
        AuroraTheme.colorContainer = Appearance.colors.colSecondaryContainer
        AuroraTheme.colorMuted = Appearance.colors.colSubtext
        AuroraTheme.colorPrimary = Appearance.colors.colPrimary
        AuroraTheme.colorOnPrimary = Appearance.colors.colOnPrimary
        AuroraTheme.colorOutline = Appearance.colors.colOutline

        AuroraTheme.fontFamily = Theme.fontFamily
        AuroraTheme.fontSizeSmall = Appearance.font.pixelSize.smaller
        AuroraTheme.fontSizeNormal = Appearance.font.pixelSize.small
        AuroraTheme.fontSizeLarge = Appearance.font.pixelSize.large
        AuroraTheme.fontSizeHuge = Appearance.font.pixelSize.huge
    }

    Connections {
        target: AuroraConfig
        function onThemeModeChanged() {
            provider.resolve()
        }
    }
}
