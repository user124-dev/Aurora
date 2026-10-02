import QtQuick
import Quickshell
import Quickshell.Io
import "./Core"
import "./Components/Layout"

// Aurora's standalone runtime entrypoint.
// The widget itself remains reusable: this file only provides a window
// so `qs -c Aurora` has something visible to render, and owns the one
// thing that only a window can do: being moved.
ShellRoot {
    PanelWindow {
        id: window

        // Where the user wants the window: its distance from the top and
        // right screen edges, i.e. from the two anchors below. Kept apart
        // from margins because margins are clamped to whatever size the
        // window currently has - an expanded widget near an edge is pushed
        // back on screen, then returns to this spot when it shrinks again.
        property real desiredTop: AuroraConfig.windowDefaultMarginTop
        property real desiredRight: AuroraConfig.windowDefaultMarginRight

        anchors {
            top: true
            right: true
        }

        margins {
            top: AuroraConfig.windowDefaultMarginTop
            right: AuroraConfig.windowDefaultMarginRight
        }

        color: "transparent"
        implicitWidth: aurora.implicitWidth
        implicitHeight: aurora.implicitHeight

        function clampToRange(value, max) {
            return Math.max(0, Math.min(Math.max(0, max), value))
        }

        // Only this window's own screen is considered: dragging onto
        // another monitor is not supported (a layer-shell surface belongs
        // to one output).
        function applyMargins() {
            if (!window.screen)
                return

            window.margins.top = Math.round(window.clampToRange(window.desiredTop, window.screen.height - window.height))
            window.margins.right = Math.round(window.clampToRange(window.desiredRight, window.screen.width - window.width))
        }

        // dx/dy is how far the pointer sits from where it grabbed the
        // widget (see the DragHandler in AuroraPlayer). Moving right means
        // a smaller right margin, hence the sign. `desired*` is clamped
        // itself so pushing against an edge never stores slack that the
        // user would have to drag back through.
        function moveBy(dx, dy) {
            if (!window.screen)
                return

            window.desiredTop = window.clampToRange(window.desiredTop + Math.round(dy), window.screen.height - window.height)
            window.desiredRight = window.clampToRange(window.desiredRight - Math.round(dx), window.screen.width - window.width)
            window.applyMargins()
        }

        onWidthChanged: window.applyMargins()
        onHeightChanged: window.applyMargins()

        AuroraPlayer {
            id: aurora
            anchors.fill: parent
        }

        // AuroraPlayer reports pointer offsets through AuroraState and never
        // sees this window. Embedded elsewhere, nothing listens - which is
        // the intent: a host owns its own layout.
        Connections {
            target: AuroraState

            function onWidgetDragOffset(dx, dy) {
                window.moveBy(dx, dy)
            }

            // Saved once per drag, not per pixel moved.
            function onWidgetDragFinished() {
                positionAdapter.marginTop = window.desiredTop
                positionAdapter.marginRight = window.desiredRight
            }
        }

        // Remembers the dragged position across restarts. Same FileView +
        // JsonAdapter + Quickshell.statePath() mechanism AuroraPlayerProvider
        // uses for aurora-last-source.json - a second small file, not a new
        // persistence system. The window first appears at the default spot
        // and moves to the saved one when the file arrives; the fade-in
        // in AuroraPlayer covers that first frame.
        FileView {
            id: positionFile
            path: Quickshell.statePath("aurora-window-position.json")
            printErrors: false
            onAdapterUpdated: writeAdapter()

            onLoaded: {
                if (isFinite(positionAdapter.marginTop))
                    window.desiredTop = positionAdapter.marginTop
                if (isFinite(positionAdapter.marginRight))
                    window.desiredRight = positionAdapter.marginRight
                window.applyMargins()
            }

            onLoadFailed: {
                // Expected on first run: nothing dragged yet, so the default
                // corner declared above stays.
            }

            JsonAdapter {
                id: positionAdapter
                property real marginTop: AuroraConfig.windowDefaultMarginTop
                property real marginRight: AuroraConfig.windowDefaultMarginRight
            }
        }

        Component.onCompleted: positionFile.reload()
    }
}
