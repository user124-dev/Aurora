import QtQuick
import QtQuick.Layouts
import "../Core"
import "../Session"

Item {
    id: root
    property bool hovered: false
    property string listMode: "queue"
    implicitHeight: AuroraConfig.featurePanelHeight

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
                    text: "SESSION · " + (AuroraState.sessionSource || "No source")
                    font.pixelSize: AuroraTheme.fontSizeSmall
                    font.family: AuroraTheme.fontFamily
                    color: AuroraTheme.colorOnBackground
                    elide: Text.ElideRight
                }

                Rectangle {
                    implicitWidth: 64
                    implicitHeight: 22
                    radius: 11
                    color: root.listMode === "queue" ? AuroraTheme.colorPrimary : AuroraTheme.colorBackground
                    Text {
                        anchors.centerIn: parent
                        text: "Queue " + AuroraState.sessionQueue.length
                        font.pixelSize: AuroraTheme.fontSizeSmall
                        font.family: AuroraTheme.fontFamily
                        color: root.listMode === "queue" ? AuroraTheme.colorOnPrimary : AuroraTheme.colorOnBackground
                    }
                    TapHandler { onTapped: root.listMode = "queue" }
                }

                Rectangle {
                    implicitWidth: 72
                    implicitHeight: 22
                    radius: 11
                    color: root.listMode === "history" ? AuroraTheme.colorPrimary : AuroraTheme.colorBackground
                    Text {
                        anchors.centerIn: parent
                        text: "History " + AuroraState.sessionHistory.length
                        font.pixelSize: AuroraTheme.fontSizeSmall
                        font.family: AuroraTheme.fontFamily
                        color: root.listMode === "history" ? AuroraTheme.colorOnPrimary : AuroraTheme.colorOnBackground
                    }
                    TapHandler { onTapped: root.listMode = "history" }
                }

                Rectangle {
                    implicitWidth: 50
                    implicitHeight: 22
                    radius: 11
                    color: AuroraTheme.colorContainer
                    Text {
                        anchors.centerIn: parent
                        text: "Add"
                        font.pixelSize: AuroraTheme.fontSizeSmall
                        font.family: AuroraTheme.fontFamily
                        color: AuroraTheme.colorOnBackground
                    }
                    TapHandler { onTapped: AuroraSessionQueue.addCurrent() }
                }

                Rectangle {
                    implicitWidth: 50
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
                    TapHandler {
                        onTapped: {
                            if (root.listMode === "queue")
                                AuroraSessionQueue.clearQueue()
                        }
                    }
                }
            }

            Flickable {
                id: sessionView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                contentWidth: width
                contentHeight: sessionColumn.implicitHeight

                Column {
                    id: sessionColumn
                    width: sessionView.width
                    spacing: 4

                    Repeater {
                        model: root.listMode === "queue"
                            ? AuroraState.sessionQueue
                            : AuroraState.sessionHistory

                        Rectangle {
                            width: sessionColumn.width
                            height: 27
                            radius: 8
                            color: root.listMode === "queue" && index === 0
                                ? AuroraTheme.colorPrimary
                                : AuroraTheme.colorBackground

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 5
                                spacing: 6

                                Text {
                                    Layout.fillWidth: true
                                    text: (index + 1) + "  " + (modelData.title || "Untitled")
                                    font.pixelSize: AuroraTheme.fontSizeSmall
                                    font.family: AuroraTheme.fontFamily
                                    color: root.listMode === "queue" && index === 0
                                        ? AuroraTheme.colorOnPrimary
                                        : AuroraTheme.colorOnBackground
                                    elide: Text.ElideRight
                                }

                                Text {
                                    visible: root.listMode === "history"
                                    text: modelData.artist || ""
                                    font.pixelSize: AuroraTheme.fontSizeSmall
                                    font.family: AuroraTheme.fontFamily
                                    color: AuroraTheme.colorMuted
                                    elide: Text.ElideRight
                                }

                                Rectangle {
                                    visible: root.listMode === "queue"
                                    implicitWidth: 42
                                    implicitHeight: 20
                                    radius: 10
                                    color: index === 0 ? AuroraTheme.colorOnPrimary : AuroraTheme.colorContainer

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
                                    visible: root.listMode === "queue"
                                    text: "×"
                                    font.pixelSize: AuroraTheme.fontSizeSmall
                                    color: index === 0 ? AuroraTheme.colorOnPrimary : AuroraTheme.colorMuted
                                    TapHandler { onTapped: AuroraSessionQueue.remove(index) }
                                }
                            }
                        }
                    }

                    Text {
                        visible: (root.listMode === "queue" ? AuroraState.sessionQueue : AuroraState.sessionHistory).length === 0
                        width: sessionColumn.width
                        text: root.listMode === "queue"
                            ? "No hay elementos en la cola. Añade la pista actual."
                            : "Todavía no hay historial para esta fuente."
                        font.pixelSize: AuroraTheme.fontSizeSmall
                        font.family: AuroraTheme.fontFamily
                        color: AuroraTheme.colorMuted
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: AuroraState.sessionPlaybackMessage
                visible: root.listMode === "queue" && text.length > 0
                font.pixelSize: AuroraTheme.fontSizeSmall
                font.family: AuroraTheme.fontFamily
                color: AuroraTheme.colorMuted
                elide: Text.ElideRight
            }
        }
    }
}
