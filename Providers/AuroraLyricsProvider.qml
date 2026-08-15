/*
 * AuroraLyricsProvider.qml
 *
 * Optional lyrics adapter. LRCLIB is the first backend because it exposes
 * plain and timestamped lyrics without an API key. The backend is isolated
 * so another source can be added without changing Components.
 */
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../Core"

Singleton {
    id: provider

    readonly property string backendName: "LRCLIB"
    readonly property string endpoint: "https://lrclib.net/api/get"
    property string requestKey: ""
    property string buffer: ""

    function initialize() {
        AuroraState.lyricsAvailable = AuroraConfig.lyricsIntegrationEnabled
        AuroraState.lyricsStatus = AuroraState.lyricsAvailable ? "Ready" : "Disabled"
        if (AuroraState.lyricsAvailable)
            provider.refresh()
    }

    function refresh() {
        if (!AuroraState.lyricsAvailable)
            return

        if (!AuroraState.connected || !AuroraState.title || !AuroraState.artist) {
            clear("No track")
            return
        }

        const duration = Math.round(AuroraState.duration || 0)
        if (duration <= 0) {
            clear("Duration unavailable")
            return
        }

        const key = [AuroraState.title, AuroraState.artist, AuroraState.album, duration].join("|")
        if (key === provider.requestKey && !AuroraState.lyricsLoading)
            return

        provider.requestKey = key
        provider.buffer = ""
        AuroraState.lyricsLoading = true
        AuroraState.lyricsStatus = "Loading"
        AuroraState.lyricsPlain = ""
        AuroraState.lyricsSynced = ""
        AuroraState.lyricsLines = []
        AuroraState.lyricsCurrentLine = -1

        if (request.running)
            request.running = false

        request.command = [
            "curl", "-fsSL",
            "--connect-timeout", "5",
            "--max-time", "15",
            "-H", "User-Agent: Aurora/0.1.0-dev (https://github.com/user124-dev/Aurora)",
            provider.endpoint +
                "?artist_name=" + encodeURIComponent(AuroraState.artist) +
                "&track_name=" + encodeURIComponent(AuroraState.title) +
                "&album_name=" + encodeURIComponent(AuroraState.album) +
                "&duration=" + String(duration)
        ]
        request.running = true
    }

    function clear(status) {
        AuroraState.lyricsLoading = false
        AuroraState.lyricsPlain = ""
        AuroraState.lyricsSynced = ""
        AuroraState.lyricsLines = []
        AuroraState.lyricsCurrentLine = -1
        AuroraState.lyricsStatus = status || "Unavailable"
    }

    function parseSynced(value) {
        if (!value)
            return []

        const result = []
        const lines = String(value).split("\n")
        const pattern = /^\[(\d+):(\d{2}(?:\.\d+)?)\]\s?(.*)$/

        for (const line of lines) {
            const match = line.match(pattern)
            if (!match)
                continue
            const minutes = Number(match[1])
            const seconds = Number(match[2])
            if (!isFinite(minutes) || !isFinite(seconds))
                continue
            result.push({ time: minutes * 60 + seconds, text: match[3] })
        }

        return result.sort((a, b) => a.time - b.time)
    }

    function applyPayload(payload) {
        const plain = String(payload?.plainLyrics || "")
        const synced = String(payload?.syncedLyrics || "")
        AuroraState.lyricsPlain = plain
        AuroraState.lyricsSynced = synced
        AuroraState.lyricsLines = parseSynced(synced)
        AuroraState.lyricsCurrentLine = -1
        AuroraState.lyricsLoading = false
        AuroraState.lyricsStatus = plain || synced ? "Ready" : "Instrumental"
    }

    Process {
        id: request

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => provider.buffer += data.toString()
        }

        onRunningChanged: {
            if (running)
                provider.buffer = ""
        }

        onExited: (exitCode, exitStatus) => {
            if (Number(exitCode) !== 0) {
                provider.clear("Not found")
                return
            }

            try {
                provider.applyPayload(JSON.parse(provider.buffer.trim()))
            } catch (error) {
                provider.clear("Invalid response")
            }
        }
    }

    Timer {
        interval: AuroraConfig.lyricsRefreshInterval
        running: AuroraState.lyricsLines.length > 0 && AuroraState.playbackState === "Playing"
        repeat: true
        onTriggered: {
            const lines = AuroraState.lyricsLines
            let active = -1
            for (let i = 0; i < lines.length; ++i) {
                if (AuroraState.position + 0.15 >= Number(lines[i].time))
                    active = i
                else
                    break
            }
            AuroraState.lyricsCurrentLine = active
        }
    }

    Connections {
        target: AuroraState
        function onTrackChanged() { provider.refresh() }
        function onConnectionChanged(connected) {
            if (connected)
                provider.refresh()
            else
                provider.clear("No track")
        }
    }

    Component.onCompleted: provider.initialize()
}
