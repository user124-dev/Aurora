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
 * The rounded panel behind everything else. Reads AuroraTheme for
 * color and AuroraConfig for shape - no host imports.
 */

import QtQuick
import "../../Core"

Rectangle {
    radius: AuroraConfig.widgetRadius
    color: AuroraTheme.colorBackground
    border.width: 1
    border.color: AuroraTheme.colorOutline
    opacity: 0.98
}
