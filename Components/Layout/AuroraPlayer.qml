/*
 * AuroraPlayer.qml — root widget compositor.
 * AuroraState.widgetMode is the single source of truth for Compact / Hover /
 * Expanded; child interactive regions opt out of mode-changing taps.
 */
import QtQuick
import "../../Providers"
import "../../Core"
import "../../Session"

Item {
    id: root

    property real hostWidth: 0
    property real hostHeight: 0
    readonly property bool hostSized: hostWidth > 0 && hostHeight > 0
    readonly property bool interactiveHovered: viewLoader.item?.interactiveHovered ?? false

    Component.onCompleted: {
        AuroraPlayerProvider.initialize()
        AuroraAudioProvider.initialize()
        AuroraPipewireProvider.initialize()
        AuroraThemeProvider.initialize()
        AuroraEqualizerProvider.initialize()
        AuroraLyricsProvider.initialize()
        AuroraSessionQueue.syncState()
        AuroraPluginRegistry.discoverPlugins(root)

        if (AuroraState.widgetMode < AuroraConfig.compact ||
            AuroraState.widgetMode > AuroraConfig.expanded)
            AuroraState.widgetMode = AuroraConfig.compact
    }

    readonly property int mode:
        hostSized ? AuroraConfig.hover : AuroraState.widgetMode

    implicitWidth: hostSized
        ? hostWidth
        : mode === AuroraConfig.expanded
            ? AuroraConfig.expandedWidth
            : mode === AuroraConfig.hover
                ? AuroraConfig.hoverWidth
                : AuroraConfig.compactWidth

    implicitHeight: hostSized
        ? hostHeight
        : mode === AuroraConfig.expanded
            ? AuroraConfig.expandedHeight
            : mode === AuroraConfig.hover
                ? AuroraConfig.hoverHeight
                : AuroraConfig.compactHeight

    Behavior on implicitWidth {
        NumberAnimation {
            duration: AuroraConfig.normalAnimation
            easing.type: AuroraAnimations.standard
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: AuroraConfig.normalAnimation
            easing.type: AuroraAnimations.standard
        }
    }

    AuroraBackground {
        anchors.fill: parent
        z: -1
    }

    HoverHandler {
        id: hoverHandler
        onHoveredChanged: {
            if (hoverHandler.hovered) {
                hideTimer.stop()
                showTimer.restart()
                return
            }
            showTimer.stop()
            hideTimer.restart()
        }
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        enabled: !root.hostSized && !root.interactiveHovered
        onTapped: {
            if (AuroraState.widgetMode === AuroraConfig.hover)
                AuroraState.widgetMode = AuroraConfig.expanded
            else if (AuroraState.widgetMode === AuroraConfig.expanded)
                AuroraState.widgetMode = AuroraConfig.hover
        }
    }

    Timer {
        id: showTimer
        interval: AuroraConfig.hoverDelay
        onTriggered: {
            if (AuroraState.widgetMode === AuroraConfig.compact)
                AuroraState.widgetMode = AuroraConfig.hover
        }
    }

    Timer {
        id: hideTimer
        interval: AuroraConfig.hideDelay
        onTriggered: {
            if (AuroraState.widgetMode === AuroraConfig.hover)
                AuroraState.widgetMode = AuroraConfig.compact
        }
    }

    Loader {
        id: viewLoader
        anchors.fill: parent
        asynchronous: false
        sourceComponent: {
            if (root.hostSized) return hoverWithSpectrum
            if (AuroraState.widgetMode === AuroraConfig.expanded) return expandedView
            if (AuroraState.widgetMode === AuroraConfig.hover) return hoverView
            return compactView
        }
    }

    Component { id: compactView; AuroraCompactView {} }
    Component { id: hoverView; AuroraHoverView {} }
    Component { id: hoverWithSpectrum; AuroraHoverView { showSpectrum: true } }
    Component { id: expandedView; AuroraExpandedView {} }
}
