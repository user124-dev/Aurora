/*
 * ╔══════════════════════════════════════════════════════════════╗
 * ║                      Aurora Player                          ║
 * ╚══════════════════════════════════════════════════════════════╝
 *
 * File        : AuroraControls.qml
 * Module      : Components
 * Component   : Transport Controls
 * Version     : 0.1.0-dev
 *
 * Description:
 * Shuffle / previous / play-pause / next / repeat. Everything here
 * calls AuroraState (.previous() / .togglePlaying() / .next() /
 * .toggleShuffle() / .cycleRepeat()) - never touches a Provider
 * directly. Shuffle and repeat tint themselves from
 * AuroraState.shuffleEnabled / .repeatMode, and quietly do nothing
 * if the active player doesn't support them (see
 * AuroraPlayerProvider - both are optional in MPRIS).
 *
 * Icons are hand-drawn with QtQuick.Shapes and plain Text (core Qt)
 * instead of a host icon font, so this file has zero host imports.
 * Swap these for real icon assets under Assets/Icons/ whenever
 * that's ready - this was the fastest path to something that
 * actually renders.
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import "../Core"

RowLayout {
    id: root
    spacing: AuroraConfig.controlsRowSpacing

    // ------------------------------------------------------------
    // Shuffle
    // ------------------------------------------------------------
    Rectangle {
        implicitWidth: AuroraConfig.secondaryButtonSize
        implicitHeight: AuroraConfig.secondaryButtonSize
        radius: width / 2
        color: shuffleHover.hovered ? AuroraTheme.colorContainer : "transparent"
        opacity: AuroraState.connected ? 1 : 0.5

        Behavior on color {
            ColorAnimation { duration: AuroraConfig.fastAnimation }
        }

        HoverHandler { id: shuffleHover }
        TapHandler {
            enabled: AuroraState.connected
            onTapped: AuroraState.toggleShuffle()
        }

        Text {
            anchors.centerIn: parent
            text: "\u21C4"
            font.pixelSize: parent.width * AuroraConfig.shuffleIconRatio
            color: AuroraState.shuffleEnabled ? AuroraTheme.colorPrimary : AuroraTheme.colorOnBackground

            Behavior on color {
                ColorAnimation { duration: AuroraConfig.fastAnimation }
            }
        }
    }

    // ------------------------------------------------------------
    // Previous / Play-Pause / Next - its own tighter RowLayout so
    // this cluster reads as one group, distinct from the looser
    // gap around Shuffle/Repeat.
    // ------------------------------------------------------------
    RowLayout {
        spacing: AuroraConfig.controlsButtonSpacing

        Rectangle {
            implicitWidth: AuroraConfig.controlButtonSize
            implicitHeight: AuroraConfig.controlButtonSize
            radius: width / 2
            color: prevHover.hovered ? AuroraTheme.colorContainer : "transparent"

            Behavior on color {
                ColorAnimation { duration: AuroraConfig.fastAnimation }
            }

            HoverHandler { id: prevHover }
            TapHandler {
                enabled: AuroraState.connected
                onTapped: AuroraState.previous()
            }

            Row {
                anchors.centerIn: parent
                spacing: AuroraConfig.transportGlyphSpacing

                Rectangle {
                    width: AuroraConfig.transportBarWidth
                    height: AuroraConfig.transportGlyphHeight
                    anchors.verticalCenter: parent.verticalCenter
                    color: AuroraTheme.colorOnBackground
                }

                Shape {
                    width: AuroraConfig.transportGlyphWidth
                    height: AuroraConfig.transportGlyphHeight
                    anchors.verticalCenter: parent.verticalCenter
                    ShapePath {
                        fillColor: AuroraTheme.colorOnBackground
                        strokeColor: "transparent"
                        startX: AuroraConfig.transportGlyphWidth; startY: 0
                        PathLine { x: 0; y: AuroraConfig.transportGlyphHeight / 2 }
                        PathLine { x: AuroraConfig.transportGlyphWidth; y: AuroraConfig.transportGlyphHeight }
                        PathLine { x: AuroraConfig.transportGlyphWidth; y: 0 }
                    }
                }
            }
        }

        Rectangle {
            implicitWidth: AuroraConfig.playButtonSize
            implicitHeight: AuroraConfig.playButtonSize
            radius: width / 2
            // Same hover mechanism as shuffle/prev/next/repeat below,
            // adapted to Play's resting color: this button is already
            // filled (colorPrimary), not transparent-until-hovered
            // like the other four, so hover darkens it slightly
            // instead of swapping to colorContainer/transparent -
            // AuroraTheme has no dedicated "primary hover" token yet,
            // and adding one is out of scope for this fix. Darkens by
            // scaling r/g/b directly (0.85) rather than Qt.darker() -
            // verified against the real runtime that Qt.darker()'s
            // factor argument does not behave predictably here (even
            // mild-looking factors like 110-150 collapsed toward
            // black), while direct channel scaling is simple and
            // gives the expected result.
            readonly property color playHoverColor: Qt.rgba(
                AuroraTheme.colorPrimary.r * 0.85,
                AuroraTheme.colorPrimary.g * 0.85,
                AuroraTheme.colorPrimary.b * 0.85,
                1)
            color: playHover.hovered ? playHoverColor : AuroraTheme.colorPrimary
            opacity: AuroraState.connected ? 1 : 0.5

            Behavior on color {
                ColorAnimation { duration: AuroraConfig.fastAnimation }
            }

            HoverHandler { id: playHover }
            TapHandler {
                enabled: AuroraState.connected
                onTapped: AuroraState.togglePlaying()
            }

            Shape {
                visible: AuroraState.playbackState !== "Playing"
                anchors.centerIn: parent
                width: AuroraConfig.playPauseGlyphWidth
                height: AuroraConfig.playPauseGlyphHeight
                ShapePath {
                    fillColor: AuroraTheme.colorOnPrimary
                    strokeColor: "transparent"
                    startX: 0; startY: 0
                    PathLine { x: AuroraConfig.playPauseGlyphWidth; y: AuroraConfig.playPauseGlyphHeight / 2 }
                    PathLine { x: 0; y: AuroraConfig.playPauseGlyphHeight }
                    PathLine { x: 0; y: 0 }
                }
            }

            Row {
                visible: AuroraState.playbackState === "Playing"
                anchors.centerIn: parent
                spacing: AuroraConfig.pauseGlyphBarSpacing
                Rectangle { width: AuroraConfig.pauseBarWidth; height: AuroraConfig.playPauseGlyphHeight; color: AuroraTheme.colorOnPrimary }
                Rectangle { width: AuroraConfig.pauseBarWidth; height: AuroraConfig.playPauseGlyphHeight; color: AuroraTheme.colorOnPrimary }
            }
        }

        Rectangle {
            implicitWidth: AuroraConfig.controlButtonSize
            implicitHeight: AuroraConfig.controlButtonSize
            radius: width / 2
            color: nextHover.hovered ? AuroraTheme.colorContainer : "transparent"

            Behavior on color {
                ColorAnimation { duration: AuroraConfig.fastAnimation }
            }

            HoverHandler { id: nextHover }
            TapHandler {
                enabled: AuroraState.connected
                onTapped: AuroraState.next()
            }

            Row {
                anchors.centerIn: parent
                spacing: AuroraConfig.transportGlyphSpacing

                Shape {
                    width: AuroraConfig.transportGlyphWidth
                    height: AuroraConfig.transportGlyphHeight
                    anchors.verticalCenter: parent.verticalCenter
                    ShapePath {
                        fillColor: AuroraTheme.colorOnBackground
                        strokeColor: "transparent"
                        startX: 0; startY: 0
                        PathLine { x: AuroraConfig.transportGlyphWidth; y: AuroraConfig.transportGlyphHeight / 2 }
                        PathLine { x: 0; y: AuroraConfig.transportGlyphHeight }
                        PathLine { x: 0; y: 0 }
                    }
                }

                Rectangle {
                    width: AuroraConfig.transportBarWidth
                    height: AuroraConfig.transportGlyphHeight
                    anchors.verticalCenter: parent.verticalCenter
                    color: AuroraTheme.colorOnBackground
                }
            }
        }
    }

    // ------------------------------------------------------------
    // Repeat - small "1" badge distinguishes repeat-one from
    // repeat-all without needing a second icon.
    // ------------------------------------------------------------
    Rectangle {
        implicitWidth: AuroraConfig.secondaryButtonSize
        implicitHeight: AuroraConfig.secondaryButtonSize
        radius: width / 2
        color: repeatHover.hovered ? AuroraTheme.colorContainer : "transparent"
        opacity: AuroraState.connected ? 1 : 0.5

        Behavior on color {
            ColorAnimation { duration: AuroraConfig.fastAnimation }
        }

        HoverHandler { id: repeatHover }
        TapHandler {
            enabled: AuroraState.connected
            onTapped: AuroraState.cycleRepeat()
        }

        Text {
            anchors.centerIn: parent
            text: "\u21BB"
            font.pixelSize: parent.width * AuroraConfig.repeatIconRatio
            color: AuroraState.repeatMode !== "None" ? AuroraTheme.colorPrimary : AuroraTheme.colorOnBackground

            Behavior on color {
                ColorAnimation { duration: AuroraConfig.fastAnimation }
            }
        }

        Text {
            visible: AuroraState.repeatMode === "Track"
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: AuroraConfig.repeatBadgeMargin
            anchors.bottomMargin: AuroraConfig.repeatBadgeMargin
            text: "1"
            font.pixelSize: parent.width * AuroraConfig.repeatBadgeRatio
            font.bold: true
            color: AuroraTheme.colorPrimary
        }
    }
}
