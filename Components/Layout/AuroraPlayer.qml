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
 * Root layout. Boots the Providers, then sizes itself one of two
 * ways:
 *
 *   - hostWidth/hostHeight set  -> use exactly that (the host
 *     environment is telling Aurora how much space it gets, e.g. a
 *     bar with a big media slot).
 *   - left unset                -> manage size itself via
 *     hover/tap between Compact/Hover/Expanded, like a normal
 *     self-contained widget.
 */

import QtQuick
import QtQuick.Layouts

import "../../Providers"
import "../../Core"
import "../"

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

    // AuroraConfig.expandedHeight (300) assumes a taller card layout
    // that doesn't exist yet - this row-based layout uses hoverHeight
    // for both hover and expanded until that's designed.
    implicitHeight: hostSized
        ? hostHeight
        : (expanded || hovered)
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

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 10

        AuroraCover {
            Layout.alignment: Qt.AlignVCenter
            // Never ask for more height than this row actually has.
            size: Math.min(AuroraConfig.coverSize, root.implicitHeight - 16)
        }

        AuroraInfo {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            visible: root.hostSized || root.hovered || root.expanded
        }

        AuroraSpectrum {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            visible: root.hostSized || root.expanded
        }

        AuroraControls {
            Layout.alignment: Qt.AlignVCenter
            visible: root.hostSized || root.hovered || root.expanded
        }
    }
}
