import QtQuick
import Quickshell

// Aurora's standalone runtime entrypoint.
// The widget itself remains reusable: this file only provides a window
// so `qs -c Aurora` has something visible to render.
ShellRoot {
    PanelWindow {
        id: window

        anchors {
            top: true
            right: true
        }

        margins {
            top: 24
            right: 24
        }

        color: "transparent"
        implicitWidth: aurora.implicitWidth
        implicitHeight: aurora.implicitHeight

        AuroraPlayer {
            id: aurora
            anchors.fill: parent
        }
    }
}
