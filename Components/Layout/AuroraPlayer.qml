/*
 * ╔══════════════════════════════════════════════════════════════╗
 * ║                      Aurora Player                          ║
 * ╚══════════════════════════════════════════════════════════════╝
 *
 * File        : AuroraPlayer.qml
 * Module      : Components/Layout
 * Component   : Root Widget
 * Version     : 0.1.0-dev
 *
 * Description:
 * Root layout. Boots the Providers, tracks hover/tap/host-sizing
 * state, and hands the actual content off to whichever of
 * AuroraCompactView / AuroraHoverView / AuroraExpandedView fits
 * that state.
 */

import QtQuick

import "../../Providers"
import "../../Core"

Item {
    id: root

    property real hostWidth: 0
    property real hostHeight: 0
    readonly property bool hostSized: hostWidth > 0 && hostHeight > 0

    property bool hovered: false
    property bool expanded: false

    Component.onCompleted: {
        AuroraPlayerProvider.initialize()
        AuroraAudioProvider.initialize()
        AuroraThemeProvider.initialize()
        AuroraEqualizerProvider.initialize()
        AuroraPluginRegistry.discoverPlugins(root)
        AuroraState.widgetMode = mode
    }

    readonly property int mode:
        hostSized
            ? AuroraConfig.hover
            : expanded
                ? AuroraConfig.expanded
                : hovered
                    ? AuroraConfig.hover
                    : AuroraConfig.compact

    onModeChanged: AuroraState.widgetMode = mode

    implicitWidth: hostSized
        ? hostWidth
        : expanded
            ? AuroraConfig.expandedWidth
            : hovered
                ? AuroraConfig.hoverWidth
                : AuroraConfig.compactWidth

    implicitHeight: hostSized
        ? hostHeight
        : expanded
            ? AuroraConfig.expandedHeight
            : hovered
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
            } else {
                showTimer.stop()
                hideTimer.restart()
            }
        }
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: root.expanded = !root.expanded
    }

    Timer {
        id: showTimer
        interval: AuroraConfig.hoverDelay
        onTriggered: root.hovered = true
    }

    Timer {
        id: hideTimer
        interval: AuroraConfig.hideDelay
        onTriggered: root.hovered = false
    }

    Loader {
        id: viewLoader
        anchors.fill: parent
        asynchronous: true
        sourceComponent: {
            if (root.hostSized) return hoverWithSpectrum
            if (root.expanded) return expandedView
            if (root.hovered) return hoverView
            return compactView
        }
    }

    Component { id: compactView; AuroraCompactView {} }
    Component { id: hoverView; AuroraHoverView {} }
    Component { id: hoverWithSpectrum; AuroraHoverView { showSpectrum: true } }
    Component { id: expandedView; AuroraExpandedView {} }
}
