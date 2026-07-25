/*
 * ╔══════════════════════════════════════════════════════════════╗
 * ║                      Aurora Player                          ║
 * ╚══════════════════════════════════════════════════════════════╝
 *
 * File        : AuroraExpandedView.qml
 * Module      : Components/Layout
 * Component   : Expanded View
 * Version     : 0.1.0-dev
 *
 * Description:
 * The tall card AuroraConfig.expandedWidth/expandedHeight (520x300)
 * were always sized for but never had a layout of their own -
 * "expanded" used to just mean "AuroraHoverView's row, plus
 * Spectrum, squeezed into the same 72px strip." This gives it real
 * room: Cover and Info sit on top, Spectrum takes whatever height
 * is left over (it's the one thing Aurora's philosophy calls out as
 * the actual point of the widget - real-time, not decorative), and
 * Controls anchor the bottom, centered.
 */

import QtQuick
import QtQuick.Layouts
import "../../Core"
import "../"

Item {
    id: root
    anchors.fill: parent

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: AuroraConfig.expandedPadding
        spacing: AuroraConfig.expandedSpacing

        RowLayout {
            Layout.fillWidth: true
            spacing: AuroraConfig.expandedSpacing

            AuroraCover {
                Layout.alignment: Qt.AlignVCenter
                size: AuroraConfig.expandedCoverSize
            }

            AuroraInfo {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
            }
        }

        AuroraSpectrum {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: AuroraConfig.expandedSpectrumHeight
        }

        AuroraControls {
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
