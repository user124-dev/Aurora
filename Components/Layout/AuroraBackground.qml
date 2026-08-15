/*
 * AuroraBackground.qml — visual surface behind the widget content.
 * Uses current MPRIS cover art when available and a deterministic theme
 * surface otherwise. No host-specific imports.
 */
import QtQuick
import QtQuick.Effects
import "../../Core"

Rectangle {
    id: panel
    radius: AuroraConfig.widgetRadius
    color: AuroraTheme.colorBackground
    border.width: AuroraConfig.backgroundBorderWidth
    border.color: AuroraTheme.colorOutline
    opacity: AuroraConfig.backgroundPanelOpacity
    z: 0

    layer.enabled: true
    layer.effect: MultiEffect {
        maskEnabled: true
        maskSource: Rectangle {
            width: panel.width
            height: panel.height
            radius: panel.radius
        }
    }

    Image {
        id: backdrop
        anchors.fill: parent
        visible: AuroraState.connected && status === Image.Ready
        source: AuroraState.connected ? AuroraState.coverArt : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        opacity: AuroraConfig.backgroundArtOpacity

        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blur: AuroraConfig.backgroundBlurStrength
            blurMax: AuroraConfig.backgroundBlurRadius
        }
    }

    Rectangle {
        anchors.fill: parent
        color: AuroraTheme.colorBackground
        opacity: AuroraConfig.backgroundDimOpacity
    }
}
