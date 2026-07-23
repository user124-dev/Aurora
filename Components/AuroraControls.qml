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
 * Previous / play-pause / next. Calls AuroraState.previous() /
 * .togglePlaying() / .next() - never touches a Provider directly.
 *
 * Icons are hand-drawn with QtQuick.Shapes (core Qt) instead of a
 * host icon font, so this file has zero host imports. Swap these
 * for real icon assets under Assets/Icons/ whenever that's ready -
 * this was the fastest path to something that actually renders.
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import "../Core"

RowLayout {
    id: root
    spacing: 4

    // ------------------------------------------------------------
    // Previous
    // ------------------------------------------------------------
    Rectangle {
        implicitWidth: 26
        implicitHeight: 26
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

    // ------------------------------------------------------------
    // Play / Pause
    // ------------------------------------------------------------
    Rectangle {
        implicitWidth: 32
        implicitHeight: 32
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

    // ------------------------------------------------------------
    // Next
    // ------------------------------------------------------------
    Rectangle {
        implicitWidth: 26
        implicitHeight: 26
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
