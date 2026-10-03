/*
 * ╔══════════════════════════════════════════════════════════════╗
 * ║                      Aurora Player                          ║
 * ╚══════════════════════════════════════════════════════════════╝
 *
 * File        : AuroraWallpaperProvider.qml
 * Module      : Providers
 * Component   : Wallpaper Provider
 * Version     : 0.1.0-dev
 *
 * Description:
 * Finds the current desktop wallpaper for the themeWallpaper background
 * and publishes it as AuroraState.wallpaperSource. Quickshell documents no
 * API for this, and Wayland defines no protocol for asking "what is the
 * wallpaper" either: whichever tool draws it (hyprpaper, swww, GNOME...) is
 * the one that knows. So this is a best-effort chain over the tools that do
 * expose it, tried in order, first answer wins:
 *
 *   hyprpaper -> `hyprctl hyprpaper listactive`  ("MONITOR = /path")
 *   swww      -> `swww query`                     ("... currently displaying: image: /path")
 *   gsettings -> org.gnome.desktop.background     ('file:///path')
 *
 * Every tool is optional. If none answers, AuroraState.wallpaperAvailable
 * stays false and AuroraBackground falls back to its default surface -
 * the widget never depends on this succeeding. To support another tool,
 * add a strategy to strategyOrder/strategyTool and a parser; nothing in
 * Core or Components needs to change.
 *
 * Arguments are always separate argv elements (never a shell string built
 * from data), and the lookup only runs while themeWallpaper is active.
 */

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../Core"

Singleton {
    id: provider

    readonly property bool wallpaperMode: AuroraConfig.themeMode === AuroraConfig.themeWallpaper

    // strategy name -> executable that must be on PATH for it to be tried.
    readonly property var strategyTool: ({
        hyprpaper: "hyprctl",
        swww: "swww",
        gsettings: "gsettings"
    })
    readonly property var strategyOrder: ["hyprpaper", "swww", "gsettings"]

    property bool initialized: false
    property bool toolsKnown: false
    property var tools: ({})
    property bool probing: false
    property var queue: []
    property string current: ""
    property string buffer: ""
    // Whichever strategy answered last is tried first next time, so a
    // steady-state poll costs one process instead of up to three.
    property string lastBackend: ""
    property bool unavailableLogged: false
    property bool converting: false
    property string conversionSource: ""
    property string conversionBackend: ""
    property int conversionSerial: 0
    property string convertedSource: ""
    property string convertedUrl: ""

    readonly property string cacheRoot:
        (Quickshell.env("XDG_CACHE_HOME") || ((Quickshell.env("HOME") || ".") + "/.cache")) + "/aurora"

    function initialize() {
        if (provider.initialized)
            return

        provider.initialized = true
        console.log("[Aurora] WallpaperProvider initialized")
        if (provider.wallpaperMode)
            provider.probe()
    }

    function expandHome(path) {
        if (path.startsWith("~/"))
            return (Quickshell.env("HOME") || "") + path.slice(1)
        return path
    }

    // Accepts a plain path or an existing URL (gsettings returns file://).
    // '#' and '?' are escaped by hand because encodeURI leaves them alone,
    // and both are legal in file names but would truncate a file:// URL.
    function toUrl(value) {
        if (!value)
            return ""
        if (/^[a-z][a-z0-9+.-]*:\/\//i.test(value))
            return value
        return "file://" + encodeURI(value).replace(/#/g, "%23").replace(/\?/g, "%3F")
    }

    function localPath(value) {
        if (!value)
            return ""
        if (value.startsWith("file://"))
            return decodeURIComponent(value.slice(7))
        return value
    }

    function needsConversion(value) {
        const path = provider.localPath(value).toLowerCase()
        return /\.(jxl|avif|heic|heif|jp2|j2k)$/.test(path)
    }

    function parseHyprpaper(text) {
        for (const line of String(text).split("\n")) {
            const match = line.match(/=\s*(\S.*?)\s*$/)
            if (match && /^[\/~]/.test(match[1]))
                return provider.expandHome(match[1])
        }
        return ""
    }

    function parseSwww(text) {
        for (const line of String(text).split("\n")) {
            // A solid-color output reads "color: RRGGBB" instead and has
            // no image to show, so it correctly falls through to "none".
            const match = line.match(/currently displaying:\s*image:\s*(\S.*?)\s*$/)
            if (match)
                return provider.expandHome(match[1])
        }
        return ""
    }

    function parseGsettings(text) {
        const match = String(text).trim().match(/^'(.*)'$/)
        if (!match || match[1].length === 0)
            return ""
        return provider.expandHome(match[1])
    }

    function parse(strategy, text) {
        if (strategy === "hyprpaper")
            return provider.parseHyprpaper(text)
        if (strategy === "swww")
            return provider.parseSwww(text)
        if (strategy === "gsettings")
            return provider.parseGsettings(text)
        return ""
    }

    function probe() {
        if (!provider.initialized || provider.probing)
            return

        provider.probing = true
        if (!provider.toolsKnown) {
            provider.buffer = ""
            toolDetection.running = true
            return
        }
        provider.startCycle()
    }

    function startCycle() {
        const order = provider.strategyOrder.filter(name => provider.tools[provider.strategyTool[name]] === true)
        const preferred = order.indexOf(provider.lastBackend)
        if (preferred > 0) {
            order.splice(preferred, 1)
            order.unshift(provider.lastBackend)
        }
        provider.queue = order
        provider.tryNext()
    }

    function tryNext() {
        if (provider.queue.length === 0) {
            provider.publish("", "")
            provider.probing = false
            return
        }

        provider.current = provider.queue[0]
        provider.queue = provider.queue.slice(1)
        provider.buffer = ""

        if (provider.current === "hyprpaper")
            hyprpaper.running = true
        else if (provider.current === "swww")
            swww.running = true
        else
            gsettingsScheme.running = true
    }

    // A failed or empty answer just moves on to the next strategy.
    function finishStrategy(text) {
        const value = provider.parse(provider.current, text)
        if (value) {
            provider.lastBackend = provider.current
            provider.publishSource(value, provider.current)
            provider.probing = false
            return
        }
        provider.tryNext()
    }

    function publishSource(path, backend) {
        const local = provider.localPath(path)
        if (!provider.needsConversion(path) ||
            (!provider.tools.ffmpeg && !provider.tools.magick)) {
            provider.publish(provider.toUrl(path), backend)
            return
        }

        if (provider.convertedSource === local && provider.convertedUrl !== "") {
            provider.publish(provider.convertedUrl, backend)
            return
        }

        provider.conversionSerial += 1
        provider.conversionSource = provider.localPath(path)
        provider.conversionBackend = backend
        provider.converting = true
        wallpaperCacheDir.running = true
    }

    // Assigning an unchanged value emits no change signal in QML, so a steady
    // poll never makes the Image in AuroraBackground reload the same file.
    function publish(url, backend) {
        const available = url !== ""

        AuroraState.wallpaperSource = url
        AuroraState.wallpaperBackend = backend
        AuroraState.wallpaperAvailable = available

        if (available) {
            provider.unavailableLogged = false
        } else if (!provider.unavailableLogged) {
            console.log("[Aurora] No wallpaper source answered (hyprpaper, swww, gsettings) - using the default background")
            provider.unavailableLogged = true
        }
    }

    // One fixed script, no interpolation: prints the name of each tool that
    // exists so strategies for missing tools are skipped without spawning a
    // process that can only fail.
    Process {
        id: toolDetection
        command: ["sh", "-c", "for c in hyprctl swww gsettings ffmpeg magick; do command -v \"$c\" >/dev/null 2>&1 && echo \"$c\"; done"]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => provider.buffer += data.toString() + "\n"
        }

        onExited: (exitCode, exitStatus) => {
            const found = {}
            for (const name of provider.buffer.split("\n")) {
                if (name.trim().length > 0)
                    found[name.trim()] = true
            }
            provider.tools = found
            provider.toolsKnown = true
            provider.startCycle()
        }
    }

    Process {
        id: wallpaperCacheDir
        command: ["mkdir", "-p", provider.cacheRoot]

        onExited: (exitCode, exitStatus) => {
            if (Number(exitCode) !== 0 || !provider.converting) {
                provider.converting = false
                provider.publish(provider.toUrl(provider.conversionSource), provider.conversionBackend)
                return
            }

            const target = provider.cacheRoot + "/wallpaper-" + provider.conversionSerial + ".png"
            if (provider.tools.magick) {
                wallpaperConverter.command = ["magick", provider.conversionSource, "-resize", "1280x1280>", target]
            } else {
                wallpaperConverter.command = ["ffmpeg", "-y", "-i", provider.conversionSource, "-frames:v", "1", "-vf", "scale=1280:-2:force_original_aspect_ratio=decrease", target]
            }
            wallpaperConverter.running = true
        }
    }

    Process {
        id: wallpaperConverter
        command: []

        stdout: SplitParser {
            onRead: data => {}
        }
        stderr: SplitParser {
            onRead: data => {}
        }

        onExited: (exitCode, exitStatus) => {
            const target = provider.cacheRoot + "/wallpaper-" + provider.conversionSerial + ".png"
            provider.converting = false
            if (Number(exitCode) === 0) {
                provider.convertedSource = provider.conversionSource
                provider.convertedUrl = provider.toUrl(target) + "?v=" + provider.conversionSerial
                provider.publish(provider.convertedUrl, provider.conversionBackend)
            } else {
                // Keep the original path as a final fallback: some Qt builds
                // can decode formats that are not universally available.
                provider.publish(provider.toUrl(provider.conversionSource), provider.conversionBackend)
            }
        }
    }

    Process {
        id: hyprpaper
        command: ["hyprctl", "hyprpaper", "listactive"]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => provider.buffer += data.toString() + "\n"
        }
        // Expected noise when hyprctl runs outside Hyprland.
        stderr: SplitParser {
            onRead: data => {}
        }

        onExited: (exitCode, exitStatus) => provider.finishStrategy(Number(exitCode) === 0 ? provider.buffer : "")
    }

    Process {
        id: swww
        command: ["swww", "query"]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => provider.buffer += data.toString() + "\n"
        }
        // Expected noise when the swww daemon is not running.
        stderr: SplitParser {
            onRead: data => {}
        }

        onExited: (exitCode, exitStatus) => provider.finishStrategy(Number(exitCode) === 0 ? provider.buffer : "")
    }

    // GNOME keeps a separate key for dark mode, so the color scheme decides
    // which one is actually on screen. Both keys are fixed literals.
    Process {
        id: gsettingsScheme
        command: ["gsettings", "get", "org.gnome.desktop.interface", "color-scheme"]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => provider.buffer += data.toString() + "\n"
        }
        stderr: SplitParser {
            onRead: data => {}
        }

        onExited: (exitCode, exitStatus) => {
            // No GNOME schema on this system: not an error, just not GNOME.
            if (Number(exitCode) !== 0) {
                provider.finishStrategy("")
                return
            }

            const key = provider.buffer.indexOf("dark") >= 0 ? "picture-uri-dark" : "picture-uri"
            provider.buffer = ""
            gsettingsUri.command = ["gsettings", "get", "org.gnome.desktop.background", key]
            gsettingsUri.running = true
        }
    }

    Process {
        id: gsettingsUri

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => provider.buffer += data.toString() + "\n"
        }
        stderr: SplitParser {
            onRead: data => {}
        }

        onExited: (exitCode, exitStatus) => provider.finishStrategy(Number(exitCode) === 0 ? provider.buffer : "")
    }

    Timer {
        interval: AuroraConfig.wallpaperRefreshInterval
        running: provider.initialized && provider.wallpaperMode
        repeat: true
        onTriggered: provider.probe()
    }

    Connections {
        target: AuroraConfig
        function onThemeModeChanged() {
            if (provider.wallpaperMode)
                provider.probe()
        }
    }
}
