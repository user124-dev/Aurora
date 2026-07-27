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
 * that state - this file no longer lays out Cover/Info/Spectrum/
 * Controls itself, it only decides which of those three to load.
 * Sizes itself one of two ways:
 *
 *   - hostWidth/hostHeight set  -> use exactly that (the host
 *     environment is telling Aurora how much space it gets, e.g. a
 *     bar with a big media slot). Content-wise this behaves like
 *     AuroraHoverView with the spectrum turned on, since a host slot
 *     has no separate "expanded" gesture of its own.
 *   - left unset                -> manage size itself via
 *     hover/tap between Compact/Hover/Expanded, like a normal
 *     self-contained widget.
 */

import QtQuick

import "../../Providers"
import "../../Core"

Item {
    id: root

    // Set these from outside to let the host dictate size instead
    // (e.g. hostWidth: Appearance.sizes.mediaControlsWidth). Leave
    // both at 0 and Aurora sizes itself via hover/expand.
    property real hostWidth: 0
    property real hostHeight: 0
    readonly property bool hostSized: hostWidth > 0 && hostHeight > 0

    Component.onCompleted: {
        AuroraPlayerProvider.initialize()
        AuroraAudioProvider.initialize()
        AuroraThemeProvider.initialize()
        AuroraPluginRegistry.loadConfiguredPlugins(root)
        AuroraState.widgetMode = mode
    }

    property bool hovered: false
    property bool expanded: false

    // Keeps AuroraState.widgetMode as the single source of truth,
    // even though the interaction itself lives in local booleans.
    readonly property int mode:
        expanded
            ? AuroraConfig.Expanded
            : hovered
                ? AuroraConfig.Hover
                : AuroraConfig.Compact

    onModeChanged: AuroraState.widgetMode = mode

    implicitWidth: hostSized
        ? hostWidth
        : expanded
            ? AuroraConfig.expandedWidth
            : hovered
                ? AuroraConfig.hoverWidth
                : AuroraConfig.compactWidth

    // Now uses expandedHeight for real - AuroraExpandedView gives
    // that height an actual layout to fill, instead of AuroraPlayer
    // falling back to hoverHeight for both hover and expanded.
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

    // ------------------------------------------------------------
    // MARK: Content
    // One of these three is alive at a time - the Loader tears down
    // whichever view isn't current instead of keeping all three (and
    // their Cover/Info/Spectrum/Controls instances) around at once.
    // ------------------------------------------------------------

    Loader {
        anchors.fill: parent
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
