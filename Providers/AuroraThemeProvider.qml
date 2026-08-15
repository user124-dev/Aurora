/*
 * Aurora Theme Provider
 *
 * Theme selection is persisted outside the runtime tree so the widget stays
 * portable. Components only see AuroraTheme; they never read this file.
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
    readonly property bool usingSystemTheme: AuroraConfig.themeMode === AuroraConfig.themeSystem
    property string activeTheme: "aurora"
    property bool initialized: false

    function palette(name) {
        switch (name) {
        case "midnight":
            return {
                background: "#070b10", onBackground: "#e6edf3", container: "#111923",
                muted: "#8290a0", primary: "#9cc9ff", onPrimary: "#07111d", outline: "#293746"
            }
        case "paper":
            return {
                background: "#f2eee7", onBackground: "#26231f", container: "#e3ded4",
                muted: "#777066", primary: "#514b43", onPrimary: "#f8f5ef", outline: "#c8c0b4"
            }
        case "nebula":
            return {
                background: "#171319", onBackground: "#f0e4dc", container: "#282027",
                muted: "#aa98a2", primary: "#e8b9a6", onPrimary: "#21120d", outline: "#493942"
            }
        default:
            return {
                background: "#0e1319", onBackground: "#efe7dc", container: "#1b222b",
                muted: "#9aa3ad", primary: "#efe3d8", onPrimary: "#171310", outline: "#39434f"
            }
        }
    }

    function apply(name) {
        const p = palette(name)
        activeTheme = ["aurora", "midnight", "paper", "nebula"].includes(name) ? name : "aurora"
        AuroraTheme.colorBackground = p.background
        AuroraTheme.colorOnBackground = p.onBackground
        AuroraTheme.colorContainer = p.container
        AuroraTheme.colorMuted = p.muted
        AuroraTheme.colorPrimary = p.primary
        AuroraTheme.colorOnPrimary = p.onPrimary
        AuroraTheme.colorOutline = p.outline
        AuroraTheme.fontFamily = "sans-serif"
        AuroraTheme.fontSizeSmall = 11
        AuroraTheme.fontSizeNormal = 13
        AuroraTheme.fontSizeLarge = 15
        AuroraTheme.fontSizeHuge = 22
    }

    function initialize() {
        if (initialized)
            return
        initialized = true
        apply("aurora")
        themeFile.reload()
        console.log("[Aurora] ThemeProvider initialized")
    }

    function applyStoredTheme() {
        const requested = themeAdapter.name || "aurora"
        provider.apply(requested)
    }

    FileView {
        id: themeFile
        path: provider.configPath
        watchChanges: true
        printErrors: false
        onLoaded: provider.applyStoredTheme()
        onFileChanged: reload()

        JsonAdapter {
            id: themeAdapter
            property string name: "aurora"
        }
    }

    Connections {
        target: AuroraConfig
        function onThemeModeChanged() { provider.applyStoredTheme() }
    }

    Component.onCompleted: provider.initialize()
}
