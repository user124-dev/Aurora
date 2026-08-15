/*
 * AuroraTheme.qml — runtime visual contract.
 * Components consume this object; AuroraThemeProvider is the only writer.
 */
pragma Singleton

import QtQuick

QtObject {
    property color colorBackground: "#0e1319"
    property color colorOnBackground: "#efe7dc"
    property color colorContainer: "#1b222b"
    property color colorMuted: "#9aa3ad"
    property color colorPrimary: "#efe3d8"
    property color colorOnPrimary: "#171310"
    property color colorOutline: "#39434f"

    property string fontFamily: "sans-serif"
    property int fontSizeSmall: 11
    property int fontSizeNormal: 13
    property int fontSizeLarge: 15
    property int fontSizeHuge: 22
}
