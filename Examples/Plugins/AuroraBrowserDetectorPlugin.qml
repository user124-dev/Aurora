/*
 * ╔══════════════════════════════════════════════════════════════╗
 * ║                  Aurora - Example Plugin                    ║
 * ╚══════════════════════════════════════════════════════════════╝
 *
 * File        : AuroraBrowserDetectorPlugin.qml
 * Module      : Examples/Plugins
 * Component   : Example Plugin
 * Version     : 0.1.0-dev
 *
 * Description:
 * Reference plugin - lives in Examples/, not Providers/, on purpose:
 * this is a template to copy into your OWN separate location (so an
 * Aurora update never touches it), not something Aurora loads on its
 * own. Demonstrates the full loop end to end without ever importing
 * anything from Aurora/Core directly - auroraState and auroraRegistry
 * arrive as plain properties, supplied by whoever instantiates this
 * (AuroraPluginRegistry.loadConfiguredPlugins(), or your own config if
 * you import + instantiate it by hand - see Blueprint/PLUGINS.md).
 *
 * What it does: reads AuroraState.playerName (already public - the
 * same property AuroraInfo reads) and decides whether the source
 * currently on screen looks like a browser, writing that into its own
 * AuroraState.plugins["browserDetector"] slot. Never touches any of
 * AuroraState's own top-level properties.
 */

import QtQuick

Item {
    id: plugin

    // Supplied by whoever instantiates this - see AuroraPluginRegistry
    // (config-driven loading) or Blueprint/PLUGINS.md (manual import).
    // Left undefined here on purpose: this file never assumes how it
    // was loaded.
    property var auroraState
    property var auroraConfig
    property var auroraRegistry

    readonly property string pluginName: "browserDetector"

    // Matched against MPRIS identity, lowercased. Not exhaustive - add
    // your own here if a browser you use isn't recognized.
    readonly property var knownBrowserIdentities: [
        "firefox", "chromium", "chrome", "brave", "google-chrome"
    ]

    function looksLikeBrowser(identity) {
        const lowered = (identity ?? "").toLowerCase()
        return plugin.knownBrowserIdentities.some(name => lowered.includes(name))
    }

    // Reassigns AuroraState.plugins wholesale (never mutates the
    // existing object in place) so QML's change notification actually
    // fires - same rule AuroraPluginRegistry follows for its own
    // bookkeeping.
    function evaluate() {
        if (!plugin.auroraState)
            return

        const identity = plugin.auroraState.playerName ?? ""
        const isBrowser = plugin.looksLikeBrowser(identity)

        const next = Object.assign({}, plugin.auroraState.plugins ?? ({}))
        next[plugin.pluginName] = {
            isBrowserPlaying: isBrowser && plugin.auroraState.connected,
            browserName: isBrowser ? identity : ""
        }
        plugin.auroraState.plugins = next
    }

    function initialize() {
        console.log("[AuroraBrowserDetectorPlugin] initialized")
        plugin.evaluate()
    }

    Connections {
        target: plugin.auroraState
        function onPlayerNameChanged() { plugin.evaluate() }
        function onConnectedChanged() { plugin.evaluate() }
    }

    Component.onCompleted: {
        if (plugin.auroraRegistry)
            plugin.auroraRegistry.registerProvider(plugin.pluginName, plugin)
        else
            console.log("[AuroraBrowserDetectorPlugin] no auroraRegistry supplied - not registering")
    }
}
