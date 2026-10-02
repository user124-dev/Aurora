/*
 * ╔══════════════════════════════════════════════════════════════╗
 * ║                      Aurora Player                          ║
 * ╚══════════════════════════════════════════════════════════════╝
 *
 * File        : AuroraInfo.qml
 * Module      : Components
 * Component   : Track Info
 * Version     : 0.1.0-dev
 *
 * Description:
 * Title, artist (with album folded in when the player reports one),
 * a click/drag-to-seek progress bar and elapsed time. Depends only
 * on AuroraState (reads track/progress data, and AuroraState.seek()
 * is how this asks for a seek - never touches a Provider directly).
 *
 * Title and artist cross-fade when the track changes. Text cannot be
 * interpolated, so each label shows a *Shown copy of the wanted string:
 * fade out, swap it while invisible, fade in. The elapsed-time label is
 * left alone on purpose - it ticks every second and would flicker.
 */

import QtQuick
import QtQuick.Layouts
import "../Core"

Item {
    id: root

    implicitHeight: column.implicitHeight

    readonly property string titleTarget:
        AuroraState.connected ? (AuroraState.title || "Untitled") : "Not playing"

    // Folded into one line instead of a third row - keeps
    // AuroraHoverView's tighter height budget intact. Not
    // every player reports an album (radio streams, browser
    // tabs), so this degrades to just the artist when empty.
    readonly property string artistTarget: {
        if (AuroraState.artist && AuroraState.album)
            return `${AuroraState.artist} — ${AuroraState.album}`
        return AuroraState.artist || AuroraState.album
    }

    // What the labels actually show. Assigned imperatively (never bound to
    // the target): a live binding would swap the text the instant the
    // target changes, before the fade-out had a chance to hide it.
    property string titleShown: ""
    property string artistShown: ""

    // change handlers can fire while the component is still being built,
    // before the animations below exist - so they wait for completion.
    property bool ready: false

    onTitleTargetChanged: {
        if (root.ready)
            titleFade.restart()
    }
    onArtistTargetChanged: {
        if (root.ready)
            artistFade.restart()
    }

    // Called from the fade animations at the moment the label is invisible.
    function showTitle() { root.titleShown = root.titleTarget }
    function showArtist() { root.artistShown = root.artistTarget }

    Component.onCompleted: {
        root.showTitle()
        root.showArtist()
        root.ready = true
    }

    SequentialAnimation {
        id: titleFade
        NumberAnimation {
            target: titleLabel
            property: "opacity"
            to: 0
            duration: AuroraConfig.crossfadeAnimation
            easing.type: AuroraAnimations.standard
        }
        ScriptAction { script: root.showTitle() }
        NumberAnimation {
            target: titleLabel
            property: "opacity"
            to: 1
            duration: AuroraConfig.crossfadeAnimation
            easing.type: AuroraAnimations.standard
        }
    }

    SequentialAnimation {
        id: artistFade
        NumberAnimation {
            target: artistLabel
            property: "opacity"
            to: 0
            duration: AuroraConfig.crossfadeAnimation
            easing.type: AuroraAnimations.standard
        }
        ScriptAction { script: root.showArtist() }
        NumberAnimation {
            target: artistLabel
            property: "opacity"
            to: 1
            duration: AuroraConfig.crossfadeAnimation
            easing.type: AuroraAnimations.standard
        }
    }

    function formatTime(seconds) {
        if (!seconds || seconds <= 0 || isNaN(seconds))
            return "0:00"
        const total = Math.floor(seconds)
        const m = Math.floor(total / 60)
        const s = total % 60
        return m + ":" + (s < 10 ? "0" : "") + s
    }

    ColumnLayout {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: AuroraConfig.infoRowSpacing

        Text {
            id: titleLabel
            Layout.fillWidth: true
            font.pixelSize: AuroraTheme.fontSizeLarge
            font.family: AuroraTheme.fontFamily
            color: AuroraTheme.colorOnBackground
            elide: Text.ElideRight
            text: root.titleShown
        }

        Text {
            id: artistLabel
            Layout.fillWidth: true
            font.pixelSize: AuroraTheme.fontSizeSmall
            font.family: AuroraTheme.fontFamily
            color: AuroraTheme.colorMuted
            elide: Text.ElideRight
            visible: AuroraState.connected && (AuroraState.artist !== "" || AuroraState.album !== "")
            text: root.artistShown
        }

        Item {
            id: progressRow
            Layout.fillWidth: true
            Layout.topMargin: AuroraConfig.infoProgressTopMargin
            implicitHeight: AuroraConfig.seekTrackHeight
            visible: AuroraState.connected

            Rectangle {
                id: track
                anchors.fill: parent
                radius: height / 2
                color: AuroraTheme.colorContainer

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    radius: parent.radius
                    color: AuroraTheme.colorPrimary
                    width: parent.width * Math.max(0, Math.min(1, AuroraState.progress))

                    Behavior on width {
                        NumberAnimation { duration: AuroraConfig.normalAnimation }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                enabled: AuroraState.canSeek
                cursorShape: AuroraState.canSeek ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: mouse => AuroraState.seek(Math.max(0, Math.min(1, mouse.x / width)))
                onPositionChanged: mouse => {
                    if (pressed)
                        AuroraState.seek(Math.max(0, Math.min(1, mouse.x / width)))
                }
            }
        }

        Text {
            Layout.topMargin: AuroraConfig.infoTimeTopMargin
            font.pixelSize: AuroraTheme.fontSizeSmall
            font.family: AuroraTheme.fontFamily
            color: AuroraTheme.colorMuted
            visible: AuroraState.connected
            text: root.formatTime(AuroraState.position) + " / " + root.formatTime(AuroraState.duration)
        }
    }
}
