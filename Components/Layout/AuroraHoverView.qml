/*
 * ╔══════════════════════════════════════════════════════════════╗
 * ║                      Aurora Player                          ║
 * ╚══════════════════════════════════════════════════════════════╝
 *
 * File        : AuroraHoverView.qml
 * Module      : Components/Layout
 * Component   : Hover View
 * Version     : 0.1.0-dev
 *
 * Description:
 * Cover, Info and Controls in a single row. The view exposes
 * `interactiveHovered` so AuroraPlayer can keep clicks on transport
 * controls separate from the widget-area expand gesture.
 */

import QtQuick
import QtQuick.Layouts
import "../../Core"
import "../"
import "../Media"

Item {
    id: root
    anchors.fill: parent

    property bool showSpectrum: false
    readonly property bool interactiveHovered: controls.hovered

    RowLayout {
        anchors.fill: parent
        anchors.margins: AuroraConfig.widgetPadding
        spacing: AuroraConfig.widgetSpacing

        AuroraCover {
            Layout.alignment: Qt.AlignVCenter
            size: Math.min(AuroraConfig.coverSize, root.height - (AuroraConfig.widgetPadding * 2))
        }

        AuroraInfo {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }

        AuroraBrowserBadge {
            Layout.alignment: Qt.AlignVCenter
        }

        AuroraSpectrum {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            visible: root.showSpectrum
        }

        AuroraControls {
            id: controls
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
