/*
 * AuroraPlayer.qml — root widget compositor.
 * AuroraState.widgetMode is the single source of truth for Compact / Hover /
 * Expanded; child interactive regions opt out of mode-changing taps.
 */
import QtQuick
import "../../Providers"
import "../../Core"
import "../../Session"

Item {
    id: root

    property real hostWidth: 0
    property real hostHeight: 0
    readonly property bool hostSized: hostWidth > 0 && hostHeight > 0
    readonly property bool interactiveHovered: viewLoader.item?.interactiveHovered ?? false
    readonly property bool dragging: dragHandler.active

    // mode/hostSized change handlers can fire during construction, before
    // viewLoader exists; view transitions only start once this is set.
    property bool viewReady: false

    // The widget fades in on load instead of popping into existence.
    NumberAnimation on opacity {
        from: 0
        to: 1
        duration: AuroraConfig.smoothAnimation
        easing.type: AuroraAnimations.standard
    }

    Component.onCompleted: {
        AuroraPlayerProvider.initialize()
        AuroraAudioProvider.initialize()
        AuroraPipewireProvider.initialize()
        AuroraThemeProvider.initialize()
        AuroraEqualizerProvider.initialize()
        AuroraLyricsProvider.initialize()
        AuroraWallpaperProvider.initialize()
        AuroraSessionQueue.syncState()
        AuroraPluginRegistry.discoverPlugins(root)

        if (AuroraState.widgetMode < AuroraConfig.compact ||
            AuroraState.widgetMode > AuroraConfig.expanded)
            AuroraState.widgetMode = AuroraConfig.compact

        // First view is set directly: only later mode changes cross-fade.
        viewLoader.sourceComponent = root.currentViewComponent()
        root.viewReady = true
    }

    readonly property int mode:
        hostSized ? AuroraConfig.hover : AuroraState.widgetMode

    implicitWidth: hostSized
        ? hostWidth
        : mode === AuroraConfig.expanded
            ? AuroraConfig.expandedWidth
            : mode === AuroraConfig.hover
                ? AuroraConfig.hoverWidth
                : AuroraConfig.compactWidth

    implicitHeight: hostSized
        ? hostHeight
        : mode === AuroraConfig.expanded
            ? AuroraConfig.expandedHeight
            : mode === AuroraConfig.hover
                ? AuroraConfig.hoverHeight
                : AuroraConfig.compactHeight

    Behavior on implicitWidth {
        NumberAnimation {
            duration: AuroraConfig.layoutAnimation
            easing.type: AuroraAnimations.standard
        }
    }

    Behavior on implicitHeight {
        NumberAnimation {
            duration: AuroraConfig.layoutAnimation
            easing.type: AuroraAnimations.standard
        }
    }

    AuroraBackground {
        anchors.fill: parent
        z: 0
    }

    HoverHandler {
        id: hoverHandler
        onHoveredChanged: {
            // A drag keeps the pointer on the widget by construction, and
            // the timers are stopped for its duration - see dragHandler.
            if (root.dragging)
                return

            if (hoverHandler.hovered) {
                hideTimer.stop()
                showTimer.restart()
                return
            }
            showTimer.stop()
            hideTimer.restart()
        }
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        enabled: !root.hostSized && !root.interactiveHovered
        onTapped: {
            if (AuroraState.widgetMode === AuroraConfig.hover)
                AuroraState.widgetMode = AuroraConfig.expanded
            else if (AuroraState.widgetMode === AuroraConfig.expanded)
                AuroraState.widgetMode = AuroraConfig.hover
        }
    }

    // Free positioning. Works in Compact and, deliberately, in Hover too:
    // pointing at Compact opens Hover after hoverDelay (150 ms), so a drag
    // that only worked in Compact would be nearly impossible to start.
    // Expanded stays fixed (lyrics, queue and seek all need the pointer).
    //
    // This only reports how far the pointer is from where it grabbed the
    // widget; whoever owns the window applies it (see shell.qml). Because
    // the window follows the pointer, that offset shrinks back to zero as
    // it catches up, so it is applied as a correction, not accumulated.
    //
    // grabPermissions is restricted on purpose: DragHandler's default can
    // take a press over from an Item, which would turn a drag on the seek
    // bar into a window move. Buttons are unaffected - a drag beyond the
    // threshold cancels their tap, so moving the widget never triggers
    // playback controls.
    DragHandler {
        id: dragHandler
        target: null
        acceptedButtons: Qt.LeftButton
        grabPermissions: PointerHandler.ApprovesTakeOverByAnything
        enabled: AuroraConfig.widgetDragEnabled && !root.hostSized && root.mode !== AuroraConfig.expanded

        onTranslationChanged: {
            if (dragHandler.active)
                AuroraState.widgetDragOffset(dragHandler.translation.x, dragHandler.translation.y)
        }

        onActiveChanged: {
            if (dragHandler.active) {
                // No mode change mid-drag: a size change would move the
                // point the user is holding.
                showTimer.stop()
                hideTimer.stop()
                return
            }

            AuroraState.widgetDragFinished()
            if (!hoverHandler.hovered)
                hideTimer.restart()
        }
    }

    Timer {
        id: showTimer
        interval: AuroraConfig.hoverDelay
        onTriggered: {
            if (!root.dragging && AuroraState.widgetMode === AuroraConfig.compact)
                AuroraState.widgetMode = AuroraConfig.hover
        }
    }

    Timer {
        id: hideTimer
        interval: AuroraConfig.hideDelay
        onTriggered: {
            if (!root.dragging && AuroraState.widgetMode === AuroraConfig.hover)
                AuroraState.widgetMode = AuroraConfig.compact
        }
    }

    function currentViewComponent() {
        if (root.hostSized) return hoverWithSpectrum
        if (AuroraState.widgetMode === AuroraConfig.expanded) return expandedView
        if (AuroraState.widgetMode === AuroraConfig.hover) return hoverView
        return compactView
    }

    // Loader swaps its content instantly, so a Behavior on opacity could
    // never show a fade (the old item is gone in the same tick). Instead:
    // fade out, swap while invisible, fade in. The script re-reads the
    // wanted view at swap time, so rapid mode changes always land on the
    // latest one. The size Behaviors above run alongside.
    SequentialAnimation {
        id: viewTransition

        NumberAnimation {
            target: viewLoader
            property: "opacity"
            to: 0
            duration: AuroraConfig.crossfadeAnimation
            easing.type: AuroraAnimations.standard
        }
        ScriptAction {
            script: { viewLoader.sourceComponent = root.currentViewComponent() }
        }
        NumberAnimation {
            target: viewLoader
            property: "opacity"
            to: 1
            duration: AuroraConfig.crossfadeAnimation
            easing.type: AuroraAnimations.standard
        }
    }

    onModeChanged: root.requestViewTransition()
    onHostSizedChanged: root.requestViewTransition()

    function requestViewTransition() {
        if (root.viewReady && root.currentViewComponent() !== viewLoader.sourceComponent)
            viewTransition.restart()
    }

    Loader {
        id: viewLoader
        anchors.fill: parent
        z: 1
        asynchronous: false
    }

    Component { id: compactView; AuroraCompactView {} }
    Component { id: hoverView; AuroraHoverView {} }
    Component { id: hoverWithSpectrum; AuroraHoverView { showSpectrum: true } }
    Component { id: expandedView; AuroraExpandedView {} }
}
