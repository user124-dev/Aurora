/*
 * Aurora Theme Provider
 *
 * Theme definitions live in the repository's Themes/ directory. Components
 * consume AuroraTheme only; this provider is the runtime bridge between the
 * selected theme file and the visual contract.
 */
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../Core"

Singleton {
    id: provider

    readonly property string configPath:
        (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/aurora/theme.json"
    readonly property string themeDirectory: Quickshell.shellDir + "/Themes"
    readonly property bool usingSystemTheme: AuroraConfig.themeMode === AuroraConfig.themeSystem
    property string activeTheme: "aurora"
    property bool initialized: false
    property string requestedTheme: "aurora"

    function fallbackPalette() {
        return {
            name: "aurora",
            background: "#0e1319", onBackground: "#efe7dc", container: "#1b222b",
            muted: "#9aa3ad", primary: "#efe3d8", onPrimary: "#171310", outline: "#39434f",
            fontFamily: "sans-serif", fontSizeSmall: 11, fontSizeNormal: 13,
            fontSizeLarge: 15, fontSizeHuge: 22
        }
    }

    function applyPalette(p) {
        const palette = p || provider.fallbackPalette()
        const name = String(palette.name || provider.requestedTheme || "aurora")
        activeTheme = name
        AuroraTheme.colorBackground = String(palette.background || "#0e1319")
        AuroraTheme.colorOnBackground = String(palette.onBackground || "#efe7dc")
        AuroraTheme.colorContainer = String(palette.container || "#1b222b")
        AuroraTheme.colorMuted = String(palette.muted || "#9aa3ad")
        AuroraTheme.colorPrimary = String(palette.primary || "#efe3d8")
        AuroraTheme.colorOnPrimary = String(palette.onPrimary || "#171310")
        AuroraTheme.colorOutline = String(palette.outline || "#39434f")
        AuroraTheme.fontFamily = String(palette.fontFamily || "sans-serif")
        AuroraTheme.fontSizeSmall = Number(palette.fontSizeSmall || 11)
        AuroraTheme.fontSizeNormal = Number(palette.fontSizeNormal || 13)
        AuroraTheme.fontSizeLarge = Number(palette.fontSizeLarge || 15)
        AuroraTheme.fontSizeHuge = Number(palette.fontSizeHuge || 22)
    }

    function loadTheme(name) {
        const normalized = String(name || "aurora").trim().toLowerCase()
        provider.requestedTheme = normalized || "aurora"
        themeDefinition.path = themeDirectory + "/" + provider.requestedTheme + ".json"
    }

    function applyStoredTheme() {
        provider.loadTheme(themeAdapter.name || "aurora")
    }

    function initialize() {
        if (initialized)
            return
        initialized = true
        provider.applyPalette(provider.fallbackPalette())
        themeFile.reload()
        console.log("[Aurora] ThemeProvider initialized; themes: " + provider.themeDirectory)
    }

    FileView {
        id: themeFile
        path: provider.configPath
        watchChanges: true
        printErrors: false
        onLoaded: provider.applyStoredTheme()
        onFileChanged: reload()
        onLoadFailed: {
            // Expected on a fresh install, before `aurora-theme set` has ever
            // run: no selection file yet. initialize() already applied the
            // fallback palette synchronously, so nothing is left unstyled.
            // If the file later becomes unreadable, keep the last known-good
            // palette rather than replacing it with transparent/undefined data.
            console.log("[Aurora] " + provider.configPath + " unavailable; keeping active theme: " + provider.activeTheme)
        }

        JsonAdapter {
            id: themeAdapter
            property string name: "aurora"
        }
    }

    FileView {
        id: themeDefinition
        path: ""
        watchChanges: true
        printErrors: false
        onLoaded: {
            try {
                const parsed = JSON.parse(themeDefinition.text())
                provider.applyPalette(parsed)
            } catch (error) {
                console.warn("[Aurora] Invalid theme definition: " + provider.requestedTheme)
                provider.applyPalette(provider.fallbackPalette())
            }
        }
        onFileChanged: reload()
        onLoadFailed: {
            console.warn("[Aurora] Theme not found: " + provider.requestedTheme + "; using aurora fallback")
            provider.applyPalette(provider.fallbackPalette())
        }
    }

    Connections {
        target: AuroraConfig
        function onThemeModeChanged() { provider.applyStoredTheme() }
    }

    Component.onCompleted: provider.initialize()
}
