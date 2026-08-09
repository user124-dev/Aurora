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
 * directly. The parent exposes `hovered` so AuroraPlayer can distinguish
 * a control click from a widget-area click.
 *
 * Icons are hand-drawn with QtQuick.Shapes and plain Text (core Qt)
 * instead of a host icon font, so this file has zero host imports.
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import "../Core"

RowLayout {
    id: root

    // Consumed by AuroraPlayer to keep transport clicks from changing
    // Compact / Hover / Expanded mode.
    property bool hovered: false

    spacing: AuroraConfig.controlsRowSpacing

    HoverHandler {
        id: controlsHover
        onHoveredChanged: root.hovered = controlsHover.hovered
    }

    // ------------------------------------------------------------
    // Shuffle
    // ------------------------------------------------------------
    Rectangle {
        implicitWidth: AuroraConfig.secondaryButtonSize
        implicitHeight: AuroraConfig.secondaryButtonSize
        radius: width / 2
        color: shuffleHover.hovered ? AuroraTheme.colorContainer : "transparent"
        opacity: AuroraState.connected ? AuroraConfig.connectedOpacity : AuroraConfig.disconnectedOpacity

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
    // Previous / Play-Pause / Next
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
            readonly property color playHoverColor: Qt.rgba(
                AuroraTheme.colorPrimary.r * AuroraConfig.playHoverFactor,
                AuroraTheme.colorPrimary.g * AuroraConfig.playHoverFactor,
                AuroraTheme.colorPrimary.b * AuroraConfig.playHoverFactor,
                1.0)
            color: playHover.hovered ? playHoverColor : AuroraTheme.colorPrimary
            opacity: AuroraState.connected ? AuroraConfig.connectedOpacity : AuroraConfig.disconnectedOpacity

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
    // Repeat
    // ------------------------------------------------------------
    Rectangle {
        implicitWidth: AuroraConfig.secondaryButtonSize
        implicitHeight: AuroraConfig.secondaryButtonSize
        radius: width / 2
        color: repeatHover.hovered ? AuroraTheme.colorContainer : "transparent"
        opacity: AuroraState.connected ? AuroraConfig.connectedOpacity : AuroraConfig.disconnectedOpacity

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
