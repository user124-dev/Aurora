/*
 * AuroraExpandedView.qml — expanded playback, audio and feature surfaces.
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
    // Which panel the container shows. Kept after panelMode goes back to ""
    // so the panel stays intact while the container collapses around it.
    property string shownPanel: "lyrics"

    // shownPanel is set before panelMode so the Loader never builds the
    // previously shown panel for a frame when switching.
    function togglePanel(mode) {
        if (root.panelMode === mode) {
            root.panelMode = ""
            return
        }
        root.shownPanel = mode
        root.panelMode = mode
    }
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
            visible: opacity > 0
            clip: true
            Layout.fillWidth: true
            Layout.preferredHeight: AuroraState.effectsWarning ? AuroraConfig.effectsWarningHeight : 0
            radius: height / 2
            color: AuroraTheme.colorContainer
            border.width: AuroraConfig.effectsWarningBorderWidth
            border.color: AuroraTheme.colorPrimary
            opacity: AuroraState.effectsWarning ? AuroraConfig.effectsWarningOpacity : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: AuroraConfig.smoothAnimation
                    easing.type: AuroraAnimations.standard
                }
            }

            Behavior on Layout.preferredHeight {
                NumberAnimation {
                    duration: AuroraConfig.smoothAnimation
                    easing.type: AuroraAnimations.standard
                }
            }

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
                TapHandler { onTapped: root.togglePanel("queue") }
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
                TapHandler { onTapped: root.togglePanel("lyrics") }
            }

            HoverHandler { id: panelToolbarHover }
        }

        // The panel keeps its full height inside a clipping container that
        // grows and shrinks. Animating the Loader's own height instead would
        // resize the panel every frame and squash its text. The Loader stays
        // active until the container has fully collapsed, so closing reveals
        // the panel going away rather than it vanishing first.
        Item {
            id: panelReveal
            Layout.fillWidth: true
            Layout.preferredHeight: root.panelMode !== "" ? AuroraConfig.featurePanelHeight : 0
            opacity: root.panelMode !== "" ? 1 : 0
            visible: height > 0 || opacity > 0
            clip: true

            Behavior on opacity {
                NumberAnimation {
                    duration: AuroraConfig.smoothAnimation
                    easing.type: AuroraAnimations.standard
                }
            }

            Behavior on Layout.preferredHeight {
                NumberAnimation {
                    duration: AuroraConfig.layoutAnimation
                    easing.type: AuroraAnimations.standard
                }
            }

            Loader {
                id: panelLoader
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: AuroraConfig.featurePanelHeight
                active: root.panelMode !== "" || panelReveal.height > 0
                asynchronous: false
                sourceComponent: root.shownPanel === "queue" ? queueComponent : lyricsComponent
            }
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
