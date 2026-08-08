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
 * Cover, Info and Controls in a single row - the widget's resting
 * "something is playing" state, shown on hover or whenever the host
 * gives Aurora a fixed slot (hostSized). AuroraBrowserBadge sits next
 * to Info and renders at zero size unless a browser-detecting plugin
 * is loaded and active. Spectrum is opt-in via showSpectrum: hostSized
 * widgets get it (there's no separate Expanded gesture available to a
 * host-embedded widget), the floating hover popup doesn't - that's
 * what tapping into AuroraExpandedView is for instead.
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
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
