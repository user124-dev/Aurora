/*
 * ╔══════════════════════════════════════════════════════════════╗
 * ║                      Aurora Player                          ║
 * ╚══════════════════════════════════════════════════════════════╝
 *
 * File        : AuroraBackground.qml
 * Module      : Components/Layout
 * Component   : Widget Background
 * Version     : 0.1.0-dev
 *
 * Description:
 * The rounded panel behind everything else. A blurred, dimmed copy
 * of the current cover art sits behind the flat color when one is
 * available, so the widget reflects what's playing instead of
 * always looking the same regardless of track - the dimming
 * Rectangle on top keeps title/controls readable over busy art.
 * Falls back to the flat AuroraTheme color alone when nothing's
 * playing or no art has loaded yet. Reads AuroraState for the art,
 * AuroraTheme for color and AuroraConfig for shape/opacity - no
 * host imports. QtQuick.Effects is core Qt, not host-specific, so
 * the blur stays even outside "ii".
 */

import QtQuick
import QtQuick.Effects
import "../../Core"

Rectangle {
    id: panel
    radius: AuroraConfig.widgetRadius
    color: AuroraTheme.colorBackground
    border.width: 1
    border.color: AuroraTheme.colorOutline
    opacity: 0.98

    // Rounds the blurred art + dim overlay below to match panel's
    // radius - a plain `clip: true` only clips to the rectangular
    // bounds, not the rounded corners themselves.
    layer.enabled: true
    layer.effect: MultiEffect {
        maskEnabled: true
        maskSource: Rectangle {
            width: panel.width
            height: panel.height
            radius: panel.radius
        }
    }

    Image {
        id: backdrop
        anchors.fill: parent
        visible: AuroraState.connected && status === Image.Ready
        source: AuroraState.connected ? AuroraState.coverArt : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        opacity: AuroraConfig.backgroundArtOpacity

        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: 1.0
            blurMax: AuroraConfig.backgroundBlurRadius
        }
    }

    Rectangle {
        // Keeps foreground content legible over whatever the art
        // above happens to look like.
        anchors.fill: parent
        color: AuroraTheme.colorBackground
        opacity: AuroraConfig.backgroundDimOpacity
    }
}
