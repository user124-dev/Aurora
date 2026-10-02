/*
 * AuroraBackground.qml — visual surface behind the widget content.
 * Draws one of two backdrops over the theme surface, depending on
 * AuroraConfig.themeMode: the current MPRIS cover art (default) or the
 * desktop wallpaper (themeWallpaper). No host-specific imports.
 *
 * The core path intentionally avoids QtQuick.Effects. Both backdrops are
 * therefore plain rectangular image layers under a theme-colored dim
 * layer, never a rendering dependency for the rounded panel surface.
 *
 * Wallpaper mode never leaves the widget with an empty background: the
 * wallpaper only takes over once it has been found (AuroraState) AND
 * decoded, otherwise the cover-art surface stays. Backdrops cross-fade
 * instead of swapping, so a mode, theme or cover change is never a pop.
 */
import QtQuick
import "../../Core"

Rectangle {
    id: panel

    readonly property bool wallpaperRequested:
        AuroraConfig.themeMode === AuroraConfig.themeWallpaper && AuroraState.wallpaperAvailable
    readonly property bool wallpaperActive: panel.wallpaperRequested && wallpaper.status === Image.Ready
    readonly property bool coverActive:
        !panel.wallpaperActive && AuroraState.connected && backdrop.status === Image.Ready

    radius: AuroraConfig.widgetRadius
    color: AuroraTheme.colorBackground
    border.width: AuroraConfig.backgroundBorderWidth
    border.color: AuroraTheme.colorOutline
    opacity: AuroraConfig.backgroundPanelOpacity
    z: 0

    Behavior on color {
        ColorAnimation {
            duration: AuroraConfig.smoothAnimation
            easing.type: AuroraAnimations.standard
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: AuroraConfig.smoothAnimation
            easing.type: AuroraAnimations.standard
        }
    }

    Image {
        id: backdrop
        anchors.fill: parent
        source: AuroraState.connected ? AuroraState.coverArt : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        opacity: panel.coverActive ? AuroraConfig.backgroundArtOpacity : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: AuroraConfig.smoothAnimation
                easing.type: AuroraAnimations.standard
            }
        }
    }

    Image {
        id: wallpaper
        anchors.fill: parent
        // Not bound to the source outside wallpaper mode, so the (large)
        // image is neither decoded nor held while nobody can see it.
        source: panel.wallpaperRequested ? AuroraState.wallpaperSource : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        sourceSize.width: AuroraConfig.wallpaperDecodeWidth
        opacity: panel.wallpaperActive ? AuroraConfig.wallpaperOpacity : 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: AuroraConfig.smoothAnimation
                easing.type: AuroraAnimations.standard
            }
        }
    }

    // Contrast layer: keeps text and controls legible over whatever image
    // sits underneath. Stronger over a wallpaper, which is far busier than
    // a cover crop. Rounded like the panel so its corners never poke out.
    Rectangle {
        anchors.fill: parent
        radius: panel.radius
        color: AuroraTheme.colorBackground
        opacity: panel.wallpaperActive ? AuroraConfig.wallpaperDimOpacity : AuroraConfig.backgroundDimOpacity

        Behavior on opacity {
            NumberAnimation {
                duration: AuroraConfig.smoothAnimation
                easing.type: AuroraAnimations.standard
            }
        }
    }
}
