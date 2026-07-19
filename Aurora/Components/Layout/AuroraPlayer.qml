import QtQuick
import QtQuick.Layouts

import "../../Providers"
import "../../Core"
import "../"

Item {
    id: root

    Component.onCompleted: {
        AuroraPlayerProvider.initialize()
        AuroraAudioProvider.initialize()
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

    implicitWidth:
        expanded
            ? AuroraConfig.expandedWidth
            : hovered
                ? AuroraConfig.hoverWidth
                : AuroraConfig.compactWidth

    // AuroraConfig.expandedHeight (300) assumes a taller card layout
    // that doesn't exist yet - this row-based layout uses hoverHeight
    // for both hover and expanded until that's designed.
    implicitHeight:
        (expanded || hovered)
            ? AuroraConfig.hoverHeight
            : AuroraConfig.compactHeight

    Behavior on implicitWidth {
        NumberAnimation {
            duration: AuroraConfig.normalAnimation
            easing.type: Easing.OutCubic
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: AuroraConfig.normalAnimation
            easing.type: Easing.OutCubic
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

        Cover {
            Layout.alignment: Qt.AlignVCenter
        }

        Info {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            visible: root.hovered || root.expanded
        }

        Spectrum {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            visible: root.expanded
        }

        Controls {
            Layout.alignment: Qt.AlignVCenter
            visible: root.hovered || root.expanded
        }
    }
}
