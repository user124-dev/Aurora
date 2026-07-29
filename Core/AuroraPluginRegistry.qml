/*
 * ╔══════════════════════════════════════════════════════════════╗
 * ║                      Aurora Player                          ║
 * ╚══════════════════════════════════════════════════════════════╝
 *
 * File        : AuroraPluginRegistry.qml
 * Module      : Core
 * Component   : Plugin Registry
 * Version     : 0.1.0-dev
 *
 * Description:
 * The one door third-party code knocks on. A plugin is a .qml file
 * that lives OUTSIDE Aurora's own folder (so an Aurora update never
 * touches it) and calls registerProvider() itself, from its own
 * Component.onCompleted, once it's alive. It gets there one of two
 * ways:
 *
 *   - listed in AuroraConfig.pluginPaths -> loadConfiguredPlugins()
 *     instantiates it via Qt.createComponent(). No import statement
 *     anywhere in Aurora's own tree ever references it.
 *   - imported and instantiated by hand in the host's own Quickshell
 *     config, the same way AuroraPlayer itself is (see INSTALL.md).
 *
 * Either way, this hands the plugin AuroraState/AuroraConfig/itself
 * as plain properties at creation time (auroraState / auroraConfig /
 * auroraRegistry) instead of the plugin importing "../../Core"
 * directly - a plugin living outside Aurora's folder has no reliable
 * relative path back to it, and an absolute one would break the
 * moment Aurora gets installed somewhere else (see INSTALL.md's
 * alternate-path option). See Blueprint/PLUGINS.md for the full
 * picture and a worked example.
 *
 * Philosophy:
 * A plugin never sees AuroraState's own top-level properties as
 * something to write to - only its own AuroraState.plugins[name]
 * slot. Two plugins colliding with each other, or a plugin clobbering
 * something an official Provider owns, should be architecturally
 * impossible here, not just discouraged in a comment.
 */

pragma Singleton

import QtQuick

QtObject {

    id: registry

    // Keyed by plugin name -> the object it registered. Internal -
    // components never read this map, they read AuroraState.plugins
    // for actual data. Reassigned wholesale rather than mutated in
    // place on every change, since `property var` only notifies on
    // reassignment, not on editing an existing object's fields.
    property var _providers: ({})

    readonly property var registeredNames: Object.keys(_providers)

    function registerProvider(name, providerObject) {
        if (registry._providers[name] !== undefined) {
            console.log("[Aurora] Plugin '" + name + "' is already registered - ignoring duplicate.")
            return
        }

        const next = Object.assign({}, registry._providers)
        next[name] = providerObject
        registry._providers = next

        console.log("[Aurora] Plugin registered:", name)

        if (typeof providerObject.initialize === "function")
            providerObject.initialize()
    }

    // Not called automatically on destruction - a plugin that cares
    // about cleaning up after itself calls this from its own
    // Component.onDestruction. Optional, not assumed.
    function unregisterProvider(name) {
        if (registry._providers[name] === undefined)
            return

        const nextProviders = Object.assign({}, registry._providers)
        delete nextProviders[name]
        registry._providers = nextProviders

        const nextPlugins = Object.assign({}, AuroraState.plugins)
        delete nextPlugins[name]
        AuroraState.plugins = nextPlugins

        console.log("[Aurora] Plugin unregistered:", name)
    }

    // ------------------------------------------------------------
    // MARK: Loading
    // Qt.createComponent() is the closest thing QML has to "load
    // this file with no import statement anywhere" - AuroraConfig.
    // pluginPaths is just a list of strings, so adding a plugin never
    // means editing anything under Aurora/ itself.
    // ------------------------------------------------------------

    function loadConfiguredPlugins(parentItem) {
        const paths = AuroraConfig.pluginPaths ?? []
        for (const path of paths)
            registry.loadPlugin(path, parentItem)
    }

    function loadPlugin(path, parentItem) {
        const component = Qt.createComponent(path)

        if (component.status === Component.Ready) {
            registry.instantiate(component, path, parentItem)
        } else if (component.status === Component.Loading) {
            component.statusChanged.connect(() => {
                if (component.status === Component.Ready)
                    registry.instantiate(component, path, parentItem)
                else if (component.status === Component.Error)
                    console.log("[Aurora] Plugin failed to load:", path, component.errorString())
            })
        } else if (component.status === Component.Error) {
            console.log("[Aurora] Plugin failed to load:", path, component.errorString())
        }
    }

    function instantiate(component, path, parentItem) {
        const obj = component.createObject(parentItem, {
            auroraState: AuroraState,
            auroraConfig: AuroraConfig,
            auroraRegistry: registry
        })

        if (obj === null)
            console.log("[Aurora] Plugin failed to instantiate:", path, component.errorString())

        // obj is expected to call auroraRegistry.registerProvider()
        // itself from Component.onCompleted - this function's job
        // ends at getting it alive, not at registering it.
    }
}
