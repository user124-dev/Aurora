/*
 * Aurora Theme Provider
 *
 * The standalone Aurora build uses Aurora's bundled theme as its
 * platform-independent baseline. Host-specific theme adapters can be
 * added later without coupling Core or Components to a desktop shell.
 */

pragma Singleton

import QtQuick
import Quickshell
import "../Core"
import "../Themes/Default"

Singleton {
    id: provider

    readonly property bool usingSystemTheme: AuroraConfig.themeMode === AuroraConfig.themeSystem
    property bool initialized: false

    function initialize() {
        if (initialized)
            return
        initialized = true
        resolve()
        console.log("[Aurora] ThemeProvider initialized")
    }

    function resolve() {
        // `themeSystem` intentionally falls back to Aurora's neutral bundled
        // theme in standalone mode. Host adapters can override this provider
        // in an embedding configuration later.
        applyAuroraTheme()
    }

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

    Connections {
        target: AuroraConfig
        function onThemeModeChanged() { provider.resolve() }
    }
}
