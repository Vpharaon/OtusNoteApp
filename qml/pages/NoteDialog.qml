import QtQuick 2.0
import Sailfish.Silica 1.0
import QtQuick.LocalStorage 2.0
import "../assets/AppDatabase.js" as DB

Dialog {

    property string note_id

    property string noteText
    property string dateText
    property string timeText

    onAccepted: {
        dateText = dateButton.value
        timeText = timeButton.value
        noteText = noteArea.text
    }

    canAccept: noteArea.text.length > 0
    onAcceptBlocked: {
        noteArea.text.length === 0
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        VerticalScrollDecorator {}

        Column {
            id: column
            width: parent.width

            DialogHeader {
                acceptText: "Сохранить"
                cancelText: "Отменить"
            }

            ValueButton {
                id: dateButton
                property date selectedDate

                function openDateDialog() {
                    var dateDialog = pageStack.animatorPush("Sailfish.Silica.DatePickerDialog", {
                                                                "date": selectedDate
                                                            });
                    dateDialog.pageCompleted.connect(function (page) {
                        page.accepted.connect(function () {
                            selectedDate = page.date;
                            value = Qt.formatDate(selectedDate, "ddd d MMMM yyyy");
                        });
                    });
                }

                label: "Дата"
                value: Qt.formatDate(new Date(), "ddd d MMMM yyyy")
                width: parent.width
                onClicked: openDateDialog()
            }

            ValueButton {
                id: timeButton
                property int selectedHour
                property int selectedMinute

                function openTimeDialog() {
                    var timeDialog = pageStack.animatorPush("Sailfish.Silica.TimePickerDialog", {
                                                                "hourMode": DateTime.TwentyFourHours,
                                                                "hour": selectedHour,
                                                                "minute": selectedMinute
                                                            });
                    timeDialog.pageCompleted.connect(function (page) {
                        page.accepted.connect(function () {
                            selectedHour = page.hour;
                            selectedMinute = page.minute;
                            var timeValue = timeButton.timeButtonValue()
                            timeButton.value = timeValue
                        });
                    });
                }

                function timeButtonValue() {
                    var time = new Date(0, 0, 0, selectedHour, selectedMinute, 0);
                    var type = Formatter.TimeValueTwentyFourHours;
                    return Format.formatDate(time, type);
                }

                label: "Время"
                value: timeButtonValue()
                width: parent.width
                onClicked: openTimeDialog()
            }

            TextArea {
                id: noteArea
                placeholderText: "Текст заметки"
                label: "Текст заметки"
            }
        }
    }

    Component.onCompleted: {
        if(note_id) {
            DB.getNote(note_id, function(note){
                dateButton.selectedDate = Date.fromLocaleDateString(Qt.locale(), note.date, "ddd d MMMM yyyy")
                dateButton.value = note.date
                var timeText = note.time
                var split = timeText.split(":")
                timeButton.selectedHour = split[0]
                timeButton.selectedMinute = split[1]
                var timeValue = timeButton.timeButtonValue()
                timeButton.value = timeValue
                noteArea.text = note.note_text
            })
        }
    }
}
