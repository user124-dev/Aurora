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
 * is playing. Fades in whenever `source` changes (new track, or the
 * first art arriving after start-up) instead of popping in - the
 * fallback stays visible underneath until the fade finishes, so a
 * cover swap always reads as one continuous transition rather than
 * a flash of the placeholder. Depends only on AuroraState (data),
 * AuroraConfig (size/radius) and AuroraTheme (color) - no Providers,
 * no host imports. QtQuick.Effects is core Qt, not host-specific, so
 * the rounding stays even outside "ii".
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
        border.width: AuroraConfig.coverBorderWidth
        border.color: AuroraTheme.colorOutline
        // Stays visible through the fade, not just while there's no
        // art at all - otherwise it would vanish the instant a new
        // source starts loading, before the fade-in has anything to
        // fade in over.
        visible: !AuroraState.connected || art.opacity < 1

        Text {
            anchors.centerIn: parent
            text: "\u266A"
            color: AuroraTheme.colorMuted
            font.pixelSize: Math.min(root.size * AuroraConfig.coverFallbackIconRatio, AuroraTheme.fontSizeHuge)
        }
    }

    Image {
        id: art
        anchors.fill: parent
        // Stays in the tree (rather than toggling visible on status)
        // so the opacity Behavior below has something to animate -
        // an item that's only ever added once already-opaque can't
        // fade in.
        visible: AuroraState.connected
        source: AuroraState.connected ? AuroraState.coverArt : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        smooth: true

        opacity: status === Image.Ready ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: AuroraConfig.normalAnimation
                easing.type: AuroraAnimations.standard
            }
        }

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
