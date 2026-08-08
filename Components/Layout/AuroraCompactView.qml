/*
 * ╔══════════════════════════════════════════════════════════════╗
 * ║                      Aurora Player                          ║
 * ╚══════════════════════════════════════════════════════════════╝
 *
 * File        : AuroraCompactView.qml
 * Module      : Components/Layout
 * Component   : Compact View
 * Version     : 0.1.0-dev
 *
 * Description:
 * The smallest state - cover art only, clamped to whatever square
 * fits inside the widget's compact footprint. No Info, Spectrum or
 * Controls; there isn't room for them to mean anything at this
 * size. AuroraPlayer swaps this in via Loader when neither hovered
 * nor expanded.
 */

import QtQuick
import "../../Core"
import "../"

Item {
    id: root
    anchors.fill: parent

    AuroraCover {
        anchors.centerIn: parent
        size: Math.min(root.width, root.height) - (AuroraConfig.widgetPadding * 2)
    }
}
