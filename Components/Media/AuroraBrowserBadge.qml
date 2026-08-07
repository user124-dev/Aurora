/*
 * ╔══════════════════════════════════════════════════════════════╗
 * ║                      Aurora Player                          ║
 * ╚══════════════════════════════════════════════════════════════╝
 *
 * File        : AuroraBrowserBadge.qml
 * Module      : Components/Media
 * Component   : Browser Badge
 * Version     : 0.1.0-dev
 *
 * Description:
 * The visual half of the plugin loop PLUGINS.md flagged as pending -
 * "conectarlo a un componente visual... queda pendiente para cuando
 * haya un caso real que lo pida." A small pill that appears next to
 * AuroraInfo whenever AuroraState.plugins.browserDetector says the
 * source on screen looks like a browser.
 *
 * Reads only AuroraState (like every other visual component) -
 * never imports Examples/Plugins/AuroraBrowserDetectorPlugin.qml or
 * Core/AuroraPluginRegistry directly, and has no idea either one
 * exists. If the plugin was never loaded (no AuroraConfig.pluginPaths
 * configured), plugins.browserDetector is simply undefined and this
 * renders nothing - same graceful-absence pattern AuroraSpectrum
 * already uses for a missing cava, or AuroraCover for missing art.
 *
 * Lives in Components/Media/ rather than Components/ - this is the
 * first thing to use that reserved-but-empty folder (see
 * DECISIONS.md -> "Abierto/Pendiente"): unlike AuroraCover/Info/
 * Controls/Spectrum, it has intimate knowledge of one specific
 * plugin's data shape rather than being fully plugin-agnostic, so it
 * doesn't quite belong alongside them.
 */

import QtQuick
import "../../Core"

Rectangle {
    id: root

    readonly property var browserData: AuroraState.plugins.browserDetector
    readonly property bool active: root.browserData?.isBrowserPlaying ?? false

    visible: root.active
    implicitWidth: root.active ? (label.implicitWidth + AuroraConfig.switcherChipPadding * 2) : 0
    implicitHeight: AuroraConfig.switcherChipHeight
    radius: height / 2
    color: AuroraTheme.colorContainer

    Text {
        id: label
        anchors.centerIn: parent
        text: root.browserData?.browserName || "Browser"
        font.pixelSize: AuroraTheme.fontSizeSmall
        font.family: AuroraTheme.fontFamily
        color: AuroraTheme.colorOnBackground
    }
}
