/*
 * AuroraExpandedView.qml
 *
 * Expanded presentation for playback, spectrum, effects and Aurora's
 * session/lyrics feature surfaces.
 */
import QtQuick
import QtQuick.Layouts
import "../../Core"
import "../"
import "../Media"

Item {
    id: root
    anchors.fill: parent

    property string panelMode: ""
    readonly property bool interactiveHovered:
        switcher.hovered || controls.hovered || equalizerSwitcher.hovered ||
        panelLoader.item?.hovered || panelToolbarHover.hovered

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: AuroraConfig.expandedPadding
        spacing: AuroraConfig.expandedSpacing

        AuroraPlayerSwitcher {
            id: switcher
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
            Layout.preferredHeight: visible ? AuroraConfig.effectsWarningHeight : 0
            radius: height / 2
            color: AuroraTheme.colorContainer
            border.width: AuroraConfig.effectsWarningBorderWidth
            border.color: AuroraTheme.colorPrimary
            opacity: AuroraConfig.effectsWarningOpacity

            Text {
                anchors.fill: parent
                anchors.leftMargin: AuroraConfig.effectsWarningPadding
                anchors.rightMargin: AuroraConfig.effectsWarningPadding
                verticalAlignment: Text.AlignVCenter
                text: "EasyEffects activo: Aurora está gestionando un preset de audio."
                elide: Text.ElideRight
                font.pixelSize: AuroraTheme.fontSizeSmall
                font.family: AuroraTheme.fontFamily
                color: AuroraTheme.colorOnBackground
            }
        }

        AuroraEqualizerSwitcher {
            id: equalizerSwitcher
            Layout.fillWidth: true
        }

        Row {
            Layout.fillWidth: true
            spacing: AuroraConfig.switcherChipSpacing

            Rectangle {
                implicitWidth: 86
                implicitHeight: AuroraConfig.featureChipHeight
                radius: height / 2
                color: root.panelMode === "queue" ? AuroraTheme.colorPrimary : AuroraTheme.colorContainer

                Text {
                    anchors.centerIn: parent
                    text: "Queue"
                    font.pixelSize: AuroraTheme.fontSizeSmall
                    font.family: AuroraTheme.fontFamily
                    color: root.panelMode === "queue" ? AuroraTheme.colorOnPrimary : AuroraTheme.colorOnBackground
                }
                TapHandler { onTapped: root.panelMode = root.panelMode === "queue" ? "" : "queue" }
            }

            Rectangle {
                implicitWidth: 86
                implicitHeight: AuroraConfig.featureChipHeight
                radius: height / 2
                color: root.panelMode === "lyrics" ? AuroraTheme.colorPrimary : AuroraTheme.colorContainer

                Text {
                    anchors.centerIn: parent
                    text: "Lyrics"
                    font.pixelSize: AuroraTheme.fontSizeSmall
                    font.family: AuroraTheme.fontFamily
                    color: root.panelMode === "lyrics" ? AuroraTheme.colorOnPrimary : AuroraTheme.colorOnBackground
                }
                TapHandler { onTapped: root.panelMode = root.panelMode === "lyrics" ? "" : "lyrics" }
            }

            HoverHandler { id: panelToolbarHover }
        }

        Loader {
            id: panelLoader
            Layout.fillWidth: true
            Layout.preferredHeight: AuroraConfig.featurePanelHeight
            active: root.panelMode !== ""
            asynchronous: false
            sourceComponent: root.panelMode === "queue" ? queueComponent : lyricsComponent
        }

        AuroraSpectrum {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: AuroraConfig.expandedSpectrumHeight
        }

        AuroraControls {
            id: controls
            Layout.alignment: Qt.AlignHCenter
        }
    }

    Component { id: queueComponent; AuroraSessionPanel {} }
    Component { id: lyricsComponent; AuroraLyricsPanel {} }
}
