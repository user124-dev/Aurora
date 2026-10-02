/*
 * AuroraLyricsPanel.qml — synced/plain lyrics for the current track.
 *
 * Reads AuroraState only (title, lyrics*), like every other component.
 * The lyrics backend and the timing of the active line live in
 * AuroraLyricsProvider; this file just follows AuroraState.lyricsCurrentLine.
 *
 * Auto-scroll is contextual, not a marquee: it reacts only when the active
 * line *changes*, never to raw playback position, so nothing moves while a
 * line is being sung. On a change it does nothing if the line is still
 * visible with the line before and after it (the "context"); otherwise it
 * eases the line to the middle of the view. Fresh lyrics (a new track or
 * source, lyrics that arrive mid-song, the panel being opened) are placed
 * without animation instead - gliding through thirty lines to reach the
 * right one would read as a bug, not as smoothness.
 */
import QtQuick
import QtQuick.Layouts
import "../Core"

Item {
    id: root
    property bool hovered: false
    implicitHeight: 118

    // True until the next placement should snap instead of animate.
    property bool jumpNext: true
    // True until the panel has been laid out once, so the first placement
    // uses real item positions rather than the zeroes of a fresh Repeater.
    property bool awaitingLayout: true

    // Moves the view to `target` (clamped to the scrollable range).
    // Always stops a running scroll first so two never fight over contentY.
    function scrollTo(target, animate) {
        const maxScroll = Math.max(0, lyricsColumn.implicitHeight - lyricsFlickable.height)
        const clamped = Math.max(0, Math.min(maxScroll, target))

        scrollAnimation.stop()
        if (Math.abs(clamped - lyricsFlickable.contentY) < 1)
            return

        if (animate) {
            scrollAnimation.to = clamped
            scrollAnimation.start()
        } else {
            lyricsFlickable.contentY = clamped
        }
    }

    function scrollToCurrent() {
        if (AuroraState.lyricsLines.length === 0)
            return

        const index = AuroraState.lyricsCurrentLine

        // Before the first line, or after seeking back to the intro.
        if (index < 0) {
            root.scrollTo(0, !root.jumpNext)
            return
        }

        const item = lyricsRepeater.itemAt(index)
        // Delegate not built yet; layoutSettled() will call this again.
        if (!item)
            return

        // Missing neighbours (first/last line) count as the line itself.
        const previous = lyricsRepeater.itemAt(index - 1) ?? item
        const next = lyricsRepeater.itemAt(index + 1) ?? item

        const viewTop = lyricsFlickable.contentY
        const viewBottom = viewTop + lyricsFlickable.height
        const hasContext = previous.y >= viewTop && next.y + next.height <= viewBottom
        if (hasContext && !root.jumpNext)
            return

        root.scrollTo(item.y + item.height / 2 - lyricsFlickable.height / 2, !root.jumpNext)
        root.jumpNext = false
    }

    function layoutSettled() {
        if (!root.awaitingLayout || lyricsFlickable.contentHeight <= 0 || lyricsFlickable.height <= 0)
            return

        root.awaitingLayout = false
        root.scrollToCurrent()
    }

    Connections {
        target: AuroraState

        // A new lyric set (new track, new source, late arrival, or none):
        // start from the top and snap to the right line once it is known.
        function onLyricsLinesChanged() {
            root.jumpNext = true
            root.awaitingLayout = true
            scrollAnimation.stop()
            lyricsFlickable.contentY = 0
        }

        function onLyricsCurrentLineChanged() {
            root.scrollToCurrent()
        }
    }

    HoverHandler {
        onHoveredChanged: root.hovered = hovered
    }

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: AuroraTheme.colorContainer
        opacity: 0.92

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 5

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: AuroraState.title || "Lyrics"
                    font.pixelSize: AuroraTheme.fontSizeSmall
                    font.family: AuroraTheme.fontFamily
                    color: AuroraTheme.colorOnBackground
                    elide: Text.ElideRight
                }

                Text {
                    text: AuroraState.lyricsLoading ? "Loading…" : AuroraState.lyricsStatus
                    font.pixelSize: AuroraTheme.fontSizeSmall
                    font.family: AuroraTheme.fontFamily
                    color: AuroraTheme.colorMuted
                }
            }

            Flickable {
                id: lyricsFlickable
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                contentWidth: width
                contentHeight: lyricsColumn.implicitHeight
                boundsBehavior: Flickable.StopAtBounds

                onContentHeightChanged: root.layoutSettled()
                onHeightChanged: root.layoutSettled()
                // If the user takes over, the automatic scroll lets go.
                onMovementStarted: scrollAnimation.stop()

                NumberAnimation {
                    id: scrollAnimation
                    target: lyricsFlickable
                    property: "contentY"
                    duration: AuroraConfig.lyricsAnimation
                    easing.type: AuroraAnimations.standard
                }

                Column {
                    id: lyricsColumn
                    width: parent.width
                    spacing: 3

                    Repeater {
                        id: lyricsRepeater
                        model: AuroraState.lyricsLines

                        Text {
                            id: lineLabel
                            readonly property bool isCurrent: index === AuroraState.lyricsCurrentLine

                            width: lyricsColumn.width
                            text: modelData.text || " "
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap
                            font.pixelSize: lineLabel.isCurrent
                                ? AuroraTheme.fontSizeNormal
                                : AuroraTheme.fontSizeSmall
                            font.family: AuroraTheme.fontFamily
                            color: lineLabel.isCurrent
                                ? AuroraTheme.colorPrimary
                                : AuroraTheme.colorOnBackground
                            opacity: lineLabel.isCurrent ? 1 : 0.72

                            Behavior on font.pixelSize {
                                NumberAnimation {
                                    duration: AuroraConfig.lyricsAnimation
                                    easing.type: AuroraAnimations.standard
                                }
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: AuroraConfig.lyricsAnimation
                                    easing.type: AuroraAnimations.standard
                                }
                            }

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: AuroraConfig.lyricsAnimation
                                    easing.type: AuroraAnimations.standard
                                }
                            }
                        }
                    }

                    Text {
                        visible: AuroraState.lyricsLines.length === 0 && AuroraState.lyricsPlain.length > 0
                        width: lyricsColumn.width
                        text: AuroraState.lyricsPlain
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                        font.pixelSize: AuroraTheme.fontSizeSmall
                        font.family: AuroraTheme.fontFamily
                        color: AuroraTheme.colorOnBackground
                    }

                    Text {
                        visible: !AuroraState.lyricsLoading &&
                                 AuroraState.lyricsLines.length === 0 &&
                                 AuroraState.lyricsPlain.length === 0
                        width: lyricsColumn.width
                        text: "No hay letra disponible para esta pista."
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: AuroraTheme.fontSizeSmall
                        font.family: AuroraTheme.fontFamily
                        color: AuroraTheme.colorMuted
                    }
                }
            }
        }
    }
}
