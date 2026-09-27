/*
 * AuroraBackground.qml — visual surface behind the widget content.
 * Uses current MPRIS cover art when available and a deterministic theme
 * surface otherwise. No host-specific imports.
 *
 * The core path intentionally avoids QtQuick.Effects. Background art is
 * therefore an optional rectangular visual layer rather than a rendering
 * dependency for the rounded panel surface.
 */
import QtQuick
import "../../Core"

Rectangle {
    id: panel
    radius: AuroraConfig.widgetRadius
    color: AuroraTheme.colorBackground
    border.width: AuroraConfig.backgroundBorderWidth
    border.color: AuroraTheme.colorOutline
    opacity: AuroraConfig.backgroundPanelOpacity
    z: 0

    Image {
        id: backdrop
        anchors.fill: parent
        visible: AuroraState.connected && status === Image.Ready
        source: AuroraState.connected ? AuroraState.coverArt : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        opacity: AuroraConfig.backgroundArtOpacity

    }

    Rectangle {
        anchors.fill: parent
        color: AuroraTheme.colorBackground
        opacity: AuroraConfig.backgroundDimOpacity
    }
}
