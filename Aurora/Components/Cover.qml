import QtQuick
import QtQuick.Effects
import qs.modules.common
import qs.modules.common.widgets
import "../Core"

Item {
    id: root

    // Passed down by AuroraPlayer.qml so the art never asks for
    // more room than the row actually has.
    property real size: AuroraConfig.coverSize

    implicitWidth: size
    implicitHeight: size

    Rectangle {
        id: fallback
        anchors.fill: parent
        radius: AuroraConfig.coverRadius
        color: Appearance.colors.colLayer1
        border.width: 1
        border.color: Appearance.colors.colOutline
        visible: !art.visible

        MaterialSymbol {
            anchors.centerIn: parent
            iconSize: Math.min(root.size * 0.4, Appearance.font.pixelSize.huge)
            text: "music_note"
            color: Appearance.colors.colSubtext
        }
    }

    Image {
        id: art
        anchors.fill: parent
        visible: AuroraState.connected && status === Image.Ready
        source: AuroraState.connected ? AuroraState.coverArt : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        smooth: true

        layer.enabled: true
        layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: Rectangle {
                width: art.width
                height: art.height
                radius: AuroraConfig.coverRadius
            }
        }
    }
}
