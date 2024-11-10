import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../assets/AppDatabase.js" as DB

Page {
    objectName: "mainPage"
    allowedOrientations: Orientation.All

    SilicaListView {
        id: notesListView
        header: PageHeader {
            objectName: "pageHeader"
            title: qsTr("Заметки")
        }
        quickScroll: true
        anchors.fill: parent
        model: ListModel { id: listModel }

        delegate: ListItem {
            id: listItem
            menu: contextMenu
            contentHeight: Theme.itemSizeMedium
            ListView.onRemove: animateRemoval(listItem)

            Label {
                id: notesLabel
                x: Theme.horizontalPageMargin
                text: model.note_text
            }

            Label {
                x: Theme.horizontalPageMargin
                anchors.top: notesLabel.bottom
                text: model.date_text + " " + model.time_text
                font.pixelSize: Theme.fontSizeExtraSmall
            }

            function updateNote() {
                var noteId = model.id
                var dialog = pageStack.push(Qt.resolvedUrl("NoteDialog.qml"), {
                                                "note_id": model.id
                                            })
                dialog.accepted.connect(function () {
                    DB.updateNote(dialog.note_id, dialog.dateText, dialog.timeText, dialog.noteText)
                    DB.getNote(noteId, function(note){
                        var noteData = {
                            "id": note.id.toString(10),
                            "date_text": note.date,
                            "time_text": note.time,
                            "note_text": note.note_text
                        }
                        listModel.set(model.index, noteData)
                    }
                    )
                })
            }

            function removeNote() {
                remorseDelete(function() {
                    var noteId = model.id
                    listModel.remove(index)
                    DB.deleteNote(noteId)
                }, 2000)
            }


            Component {
                id: contextMenu
                ContextMenu {
                    MenuItem {
                        text: "Редактировать"
                        onClicked: updateNote()
                    }
                    MenuItem {
                        text: "Удалить"
                        onClicked: removeNote()
                    }
                }
            }
        }

        VerticalScrollDecorator { }

        PullDownMenu {
            MenuItem {
                text: "Добавить заметку"
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("NoteDialog.qml"))
                    dialog.accepted.connect(function () {
                        var noteId = DB.dbInsert(dialog.dateText, dialog.timeText, dialog.noteText)
                        DB.getNote(noteId, function(note){
                            var noteData = {
                                "id": note.id.toString(10),
                                "date_text": note.date,
                                "time_text": note.time,
                                "note_text": note.note_text
                            }
                            listModel.insert(0, noteData)
                        }
                        )
                    })
                }
            }
        }

        Component.onCompleted: {
            DB.dbInit()
            DB.dbReadAll()
        }
    }
}
