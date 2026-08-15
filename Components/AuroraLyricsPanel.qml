import QtQuick
import QtQuick.Layouts
import "../Core"
import "../Providers"

Item {
    id: root
    property bool hovered: false
    implicitHeight: 118

    HoverHandler {
        onHoveredChanged: root.hovered = hovered
    }

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: AuroraTheme.colorContainer
        opacity: 0.92

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 5

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: AuroraState.title || "Lyrics"
                    font.pixelSize: AuroraTheme.fontSizeSmall
                    font.family: AuroraTheme.fontFamily
                    color: AuroraTheme.colorOnBackground
                    elide: Text.ElideRight
                }

                Text {
                    text: AuroraState.lyricsLoading ? "Loading…" : AuroraState.lyricsStatus
                    font.pixelSize: AuroraTheme.fontSizeSmall
                    font.family: AuroraTheme.fontFamily
                    color: AuroraTheme.colorMuted
                }
            }

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                contentWidth: width
                contentHeight: lyricsColumn.implicitHeight
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: lyricsColumn
                    width: parent.width
                    spacing: 3

                    Repeater {
                        model: AuroraState.lyricsLines

                        Text {
                            width: lyricsColumn.width
                            text: modelData.text || " "
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.Wrap
                            font.pixelSize: index === AuroraState.lyricsCurrentLine
                                ? AuroraTheme.fontSizeNormal
                                : AuroraTheme.fontSizeSmall
                            font.family: AuroraTheme.fontFamily
                            color: index === AuroraState.lyricsCurrentLine
                                ? AuroraTheme.colorPrimary
                                : AuroraTheme.colorOnBackground
                            opacity: index === AuroraState.lyricsCurrentLine ? 1 : 0.72
                        }
                    }

                    Text {
                        visible: AuroraState.lyricsLines.length === 0 && AuroraState.lyricsPlain.length > 0
                        width: lyricsColumn.width
                        text: AuroraState.lyricsPlain
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                        font.pixelSize: AuroraTheme.fontSizeSmall
                        font.family: AuroraTheme.fontFamily
                        color: AuroraTheme.colorOnBackground
                    }

                    Text {
                        visible: !AuroraState.lyricsLoading &&
                                 AuroraState.lyricsLines.length === 0 &&
                                 AuroraState.lyricsPlain.length === 0
                        width: lyricsColumn.width
                        text: "No hay letra disponible para esta pista."
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: AuroraTheme.fontSizeSmall
                        font.family: AuroraTheme.fontFamily
                        color: AuroraTheme.colorMuted
                    }
                }
            }
        }
    }
}
