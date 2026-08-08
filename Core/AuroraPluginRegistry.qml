/*
 * AuroraPluginRegistry.qml
 *
 * Runtime plugin discovery and lifecycle registry.
 *
 * Plugins live outside the Aurora repository:
 *
 *   ~/.config/aurora/plugins/<plugin-id>/plugin.qml
 *
 * Aurora discovers only files named plugin.qml at that depth, so helper
 * QML files inside a plugin package are never instantiated accidentally.
 */

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {

    id: registry

    readonly property int apiVersion: 1

    readonly property string pluginDirectory: {
        const xdgConfigHome = Quickshell.env("XDG_CONFIG_HOME")
        const home = Quickshell.env("HOME") || ""
        const base = xdgConfigHome && xdgConfigHome.length > 0
            ? xdgConfigHome
            : home + "/.config"

        return base + "/aurora/plugins"
    }

    property var _providers: ({})
    property var _loadedPaths: ({})
    property bool discoveryStarted: false
    property var _hostParent: null

    readonly property var registeredNames: Object.keys(_providers)

    function registerProvider(name, providerObject) {
        const normalizedName = (name ?? "").toString().trim()

        if (!normalizedName || !providerObject) {
            console.log("[Aurora] Plugin registration rejected: invalid name or object")
            return false
        }

        if (registry._providers[normalizedName] !== undefined) {
            console.log("[Aurora] Plugin '" + normalizedName +
                        "' is already registered - ignoring duplicate.")
            return false
        }

        const nextProviders = Object.assign({}, registry._providers)
        nextProviders[normalizedName] = providerObject
        registry._providers = nextProviders

        console.log("[Aurora] Plugin registered:", normalizedName)

        if (typeof providerObject.initialize === "function")
            providerObject.initialize()

        return true
    }

    function unregisterProvider(name) {
        const normalizedName = (name ?? "").toString().trim()

        if (!normalizedName || registry._providers[normalizedName] === undefined)
            return

        const nextProviders = Object.assign({}, registry._providers)
        delete nextProviders[normalizedName]
        registry._providers = nextProviders

        const nextPlugins = Object.assign({}, AuroraState.plugins ?? ({}))
        delete nextPlugins[normalizedName]
        AuroraState.plugins = nextPlugins

        console.log("[Aurora] Plugin unregistered:", normalizedName)
    }

    // Discover once per Quickshell instance. Multiple AuroraPlayer
    // instances therefore cannot create duplicate plugin objects.
    function discoverPlugins(parentItem) {
        if (registry.discoveryStarted)
            return

        registry.discoveryStarted = true
        registry._hostParent = parentItem

        pluginDiscovery.command = [
            "find",
            registry.pluginDirectory,
            "-mindepth", "2",
            "-maxdepth", "2",
            "-type", "f",
            "-name", "plugin.qml",
            "-print"
        ]
        pluginDiscovery.running = true
    }

    function loadPlugin(path, parentItem) {
        const normalizedPath = (path ?? "").toString().trim()

        if (!normalizedPath || registry._loadedPaths[normalizedPath] !== undefined)
            return

        const nextLoaded = Object.assign({}, registry._loadedPaths)
        nextLoaded[normalizedPath] = true
        registry._loadedPaths = nextLoaded

        const component = Qt.createComponent(normalizedPath)

        if (component.status === Component.Ready) {
            registry.instantiate(component, normalizedPath, parentItem)
            return
        }

        if (component.status === Component.Loading) {
            component.statusChanged.connect(() => {
                if (component.status === Component.Ready)
                    registry.instantiate(component, normalizedPath, parentItem)
                else if (component.status === Component.Error)
                    console.log("[Aurora] Plugin failed to load:",
                                normalizedPath, component.errorString())
            })
            return
        }

        if (component.status === Component.Error)
            console.log("[Aurora] Plugin failed to load:",
                        normalizedPath, component.errorString())
    }

    function instantiate(component, path, parentItem) {
        const obj = component.createObject(parentItem, {
            auroraState: AuroraState,
            auroraConfig: AuroraConfig,
            auroraRegistry: registry
        })

        if (obj === null) {
            console.log("[Aurora] Plugin failed to instantiate:",
                        path, component.errorString())
            return
        }

        console.log("[Aurora] Plugin instance created:", path)
    }

    Process {
        id: pluginDiscovery

        stdout: SplitParser {
            splitMarker: "\n"

            onRead: data => {
                const path = data.toString().trim()

                if (path.length > 0)
                    registry.loadPlugin(path, registry._hostParent)
            }
        }

        onExited: (exitCode, exitStatus) => {
            // find returns 1 when its directory does not exist. This is
            // an expected first-run state, not an Aurora failure.
            if (exitCode !== 0)
                console.log("[Aurora] Plugin discovery finished with code", exitCode)
        }
    }
}
