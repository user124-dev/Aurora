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
 * Expanded presentation with player switching, track information,
 * spectrum, controls, and a non-blocking warning when Aurora has
 * actively loaded an EasyEffects preset.
 */

import QtQuick
import QtQuick.Layouts
import "../../Core"
import "../"
import "../Media"

Item {
    id: root
    anchors.fill: parent

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: AuroraConfig.expandedPadding
        spacing: AuroraConfig.expandedSpacing

        AuroraPlayerSwitcher {
            Layout.fillWidth: true
        }

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

            AuroraBrowserBadge {
                Layout.alignment: Qt.AlignVCenter
            }
        }

        Rectangle {
            visible: AuroraState.effectsWarning
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 30 : 0
            radius: height / 2
            color: AuroraTheme.colorContainer
            border.width: 1
            border.color: AuroraTheme.colorPrimary
            opacity: 0.92

            Text {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                verticalAlignment: Text.AlignVCenter
                text: "EasyEffects activo: Aurora está gestionando un preset de audio."
                elide: Text.ElideRight
                font.pixelSize: AuroraTheme.fontSizeSmall
                font.family: AuroraTheme.fontFamily
                color: AuroraTheme.colorOnBackground
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
