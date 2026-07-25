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
            font.pixelSize: parent.width * 0.6
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
                spacing: 1

                Rectangle {
                    width: 2
                    height: 10
                    anchors.verticalCenter: parent.verticalCenter
                    color: AuroraTheme.colorOnBackground
                }

                Shape {
                    width: 8
                    height: 10
                    anchors.verticalCenter: parent.verticalCenter
                    ShapePath {
                        fillColor: AuroraTheme.colorOnBackground
                        strokeColor: "transparent"
                        startX: 8; startY: 0
                        PathLine { x: 0; y: 5 }
                        PathLine { x: 8; y: 10 }
                        PathLine { x: 8; y: 0 }
                    }
                }
            }
        }

        Rectangle {
            implicitWidth: AuroraConfig.playButtonSize
            implicitHeight: AuroraConfig.playButtonSize
            radius: width / 2
            color: AuroraTheme.colorPrimary
            opacity: AuroraState.connected ? 1 : 0.5

            HoverHandler { id: playHover }
            TapHandler {
                enabled: AuroraState.connected
                onTapped: AuroraState.togglePlaying()
            }

            Shape {
                visible: AuroraState.playbackState !== "Playing"
                anchors.centerIn: parent
                width: 12
                height: 14
                ShapePath {
                    fillColor: AuroraTheme.colorOnPrimary
                    strokeColor: "transparent"
                    startX: 0; startY: 0
                    PathLine { x: 12; y: 7 }
                    PathLine { x: 0; y: 14 }
                    PathLine { x: 0; y: 0 }
                }
            }

            Row {
                visible: AuroraState.playbackState === "Playing"
                anchors.centerIn: parent
                spacing: 3
                Rectangle { width: 4; height: 14; color: AuroraTheme.colorOnPrimary }
                Rectangle { width: 4; height: 14; color: AuroraTheme.colorOnPrimary }
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
                spacing: 1

                Shape {
                    width: 8
                    height: 10
                    anchors.verticalCenter: parent.verticalCenter
                    ShapePath {
                        fillColor: AuroraTheme.colorOnBackground
                        strokeColor: "transparent"
                        startX: 0; startY: 0
                        PathLine { x: 8; y: 5 }
                        PathLine { x: 0; y: 10 }
                        PathLine { x: 0; y: 0 }
                    }
                }

                Rectangle {
                    width: 2
                    height: 10
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
            font.pixelSize: parent.width * 0.62
            color: AuroraState.repeatMode !== "None" ? AuroraTheme.colorPrimary : AuroraTheme.colorOnBackground

            Behavior on color {
                ColorAnimation { duration: AuroraConfig.fastAnimation }
            }
        }

        Text {
            visible: AuroraState.repeatMode === "Track"
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: -2
            anchors.bottomMargin: -2
            text: "1"
            font.pixelSize: parent.width * 0.34
            font.bold: true
            color: AuroraTheme.colorPrimary
        }
    }
}
