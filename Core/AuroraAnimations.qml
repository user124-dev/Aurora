/*
 * ╔══════════════════════════════════════════════════════════════╗
 * ║                      Aurora Player                          ║
 * ╚══════════════════════════════════════════════════════════════╝
 *
 * File        : AuroraAnimations.qml
 * Module      : Core
 * Component   : Motion Tokens
 * Version     : 0.1.0-dev
 *
 * Description:
 * Named easing curves - the counterpart to the duration constants
 * already in AuroraConfig (fastAnimation/normalAnimation/slowAnimation).
 * Together they replace bare `easing.type: Easing.OutCubic` calls
 * scattered across components with one named vocabulary.
 *
 * Usage:
 *   Behavior on x {
 *       NumberAnimation {
 *           duration: AuroraConfig.normalAnimation
 *           easing.type: AuroraAnimations.standard
 *       }
 *   }
 *
 * Philosophy:
 * Same as AuroraConfig - no magic numbers, nothing inline that
 * should have a name.
 */

pragma Singleton

import QtQuick

QtObject {

    // Default for size/position changes - the widget resizing
    // between Compact/Hover/Expanded, progress bar fills.
    readonly property int standard: Easing.OutCubic

    // A touch of overshoot - reserved for moments that should feel
    // like a deliberate gesture rather than a passive resize (e.g.
    // a future "pinned" state confirmation). Not used yet.
    readonly property int emphasized: Easing.OutBack

    // Spectrum bars and anything ticking on a fixed timer, where a
    // curve would look out of place against a steady beat.
    readonly property int linear: Easing.Linear
}
