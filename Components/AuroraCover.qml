/*
 * ╔══════════════════════════════════════════════════════════════╗
 * ║                      Aurora Player                          ║
 * ╚══════════════════════════════════════════════════════════════╝
 *
 * File        : AuroraCover.qml
 * Module      : Components
 * Component   : Cover Art
 * Version     : 0.1.0-dev
 *
 * Description:
 * Rounded album art with a fallback while loading or when nothing
 * is playing. Depends only on AuroraState (data), AuroraConfig
 * (size/radius) and AuroraTheme (color) - no Providers, no host
 * imports. QtQuick.Effects is core Qt, not host-specific, so the
 * rounding stays even outside "ii".
 */

import QtQuick
import QtQuick.Effects
import "../Core"

Item {
    id: root

    // Set by AuroraPlayer.qml so art never asks for more room
    // than the row it's in actually has.
    property real size: AuroraConfig.coverSize

    implicitWidth: size
    implicitHeight: size

    Rectangle {
        id: fallback
        anchors.fill: parent
        radius: AuroraConfig.coverRadius
        color: AuroraTheme.colorBackground
        border.width: 1
        border.color: AuroraTheme.colorOutline
        visible: !art.visible

        Text {
            anchors.centerIn: parent
            text: "\u266A"
            color: AuroraTheme.colorMuted
            font.pixelSize: Math.min(root.size * 0.4, AuroraTheme.fontSizeHuge)
        }
    }

    Image {
        id: art
        anchors.fill: parent
        visible: AuroraState.connected && status === Image.Ready
        source: AuroraState.connected ? AuroraState.coverArt : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        smooth: true

        layer.enabled: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: Rectangle {
                width: art.width
                height: art.height
                radius: AuroraConfig.coverRadius
            }
        }
    }
}
