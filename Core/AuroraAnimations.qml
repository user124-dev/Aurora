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
 * Together they replace bare easing calls scattered across components
 * with one named vocabulary.
 */

pragma Singleton

import QtQuick
import Quickshell

// Quickshell's Singleton is the canonical root type for pragma Singleton.
// Using it here prevents the singleton from resolving as an incomplete
// QtObject when imported from another Aurora directory.
Singleton {
    // Default for size/position changes - the widget resizing
    // between Compact/Hover/Expanded, progress bar fills.
    readonly property int standard: Easing.OutCubic

    // A touch of overshoot - reserved for moments that should feel
    // like a deliberate gesture rather than a passive resize.
    readonly property int emphasized: Easing.OutBack

    // Spectrum bars and anything ticking on a fixed timer.
    readonly property int linear: Easing.Linear
}
