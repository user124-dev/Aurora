import QtQuick
import QtQuick.Layouts

import "./Providers"
import "./Core"
Item {
    id: root
    Component.onCompleted: {
        AuroraPlayerProvider.initialize()
    }
    property bool hovered: false
    property bool expanded: false

    readonly property int compactWidth: 42
    readonly property int hoverWidth: 180
    readonly property int expandedWidth: 430

    implicitWidth:
        expanded
            ? expandedWidth
            : hovered
                ? hoverWidth
                : compactWidth

    implicitHeight: 52

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 180
            easing.type: Easing.OutCubic
        }
    }

    AuroraBackground {
        anchors.fill: parent
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 10

        AuroraCover {
            Layout.alignment: Qt.AlignVCenter
        }

        AuroraInfo {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }

        AuroraSpectrum {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }

        AuroraControls {
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
