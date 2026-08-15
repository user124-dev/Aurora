import QtQuick
import QtQuick.Layouts
import "../Core"
import "../Session"

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
            spacing: 6

            RowLayout {
                Layout.fillWidth: true

                Text {
                    Layout.fillWidth: true
                    text: "SESSION · " + (AuroraState.sessionSource || "No source")
                    font.pixelSize: AuroraTheme.fontSizeSmall
                    font.family: AuroraTheme.fontFamily
                    color: AuroraTheme.colorOnBackground
                    elide: Text.ElideRight
                }

                Text {
                    text: AuroraState.sessionQueue.length + " queued"
                    font.pixelSize: AuroraTheme.fontSizeSmall
                    font.family: AuroraTheme.fontFamily
                    color: AuroraTheme.colorMuted
                }

                Rectangle {
                    implicitWidth: 56
                    implicitHeight: 22
                    radius: 11
                    color: AuroraTheme.colorPrimary

                    Text {
                        anchors.centerIn: parent
                        text: "Add"
                        font.pixelSize: AuroraTheme.fontSizeSmall
                        font.family: AuroraTheme.fontFamily
                        color: AuroraTheme.colorOnPrimary
                    }

                    TapHandler { onTapped: AuroraSessionQueue.addCurrent() }
                }

                Rectangle {
                    implicitWidth: 56
                    implicitHeight: 22
                    radius: 11
                    color: AuroraTheme.colorBackground

                    Text {
                        anchors.centerIn: parent
                        text: "Clear"
                        font.pixelSize: AuroraTheme.fontSizeSmall
                        font.family: AuroraTheme.fontFamily
                        color: AuroraTheme.colorOnBackground
                    }

                    TapHandler { onTapped: AuroraSessionQueue.clearQueue() }
                }
            }

            Flickable {
                id: queueView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                contentWidth: width
                contentHeight: queueColumn.implicitHeight

                Column {
                    id: queueColumn
                    width: queueView.width
                    spacing: 4

                    Repeater {
                        model: AuroraState.sessionQueue

                        Rectangle {
                            width: queueColumn.width
                            height: 28
                            radius: 8
                            color: index === 0 ? AuroraTheme.colorPrimary : AuroraTheme.colorBackground

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 4
                                spacing: 6

                                Text {
                                    Layout.fillWidth: true
                                    text: (index + 1) + "  " + (modelData.title || "Untitled")
                                    font.pixelSize: AuroraTheme.fontSizeSmall
                                    font.family: AuroraTheme.fontFamily
                                    color: index === 0 ? AuroraTheme.colorOnPrimary : AuroraTheme.colorOnBackground
                                    elide: Text.ElideRight
                                }

                                Rectangle {
                                    implicitWidth: 42
                                    implicitHeight: 20
                                    radius: 10
                                    color: index === 0 ? AuroraTheme.colorOnPrimary : AuroraTheme.colorContainer
                                    opacity: 0.9

                                    Text {
                                        anchors.centerIn: parent
                                        text: "Play"
                                        font.pixelSize: AuroraTheme.fontSizeSmall
                                        font.family: AuroraTheme.fontFamily
                                        color: index === 0 ? AuroraTheme.colorPrimary : AuroraTheme.colorOnBackground
                                    }

                                    TapHandler { onTapped: AuroraSessionQueue.playQueuedItem(index) }
                                }

                                Text {
                                    text: "×"
                                    font.pixelSize: AuroraTheme.fontSizeSmall
                                    color: index === 0 ? AuroraTheme.colorOnPrimary : AuroraTheme.colorMuted

                                    TapHandler { onTapped: AuroraSessionQueue.remove(index) }
                                }
                            }
                        }
                    }

                    Text {
                        visible: AuroraState.sessionQueue.length === 0
                        width: queueColumn.width
                        text: "No hay elementos en la cola. Añade la pista actual."
                        font.pixelSize: AuroraTheme.fontSizeSmall
                        font.family: AuroraTheme.fontFamily
                        color: AuroraTheme.colorMuted
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: AuroraState.sessionPlaybackMessage
                visible: text.length > 0
                font.pixelSize: AuroraTheme.fontSizeSmall
                font.family: AuroraTheme.fontFamily
                color: AuroraTheme.colorMuted
                elide: Text.ElideRight
            }
        }
    }
}
