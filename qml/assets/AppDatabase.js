function dbInit()
{
    var db = LocalStorage.openDatabaseSync("NotesApp_DB", "", "Database for storing user notes", 1000000)
    try {
        db.transaction(function (tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS notes_table (id INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, time TEXT, note_text TEXT NOT NULL)')
        })
    } catch (err) {
        console.log("Error creating table in database: " + err)
    };
}

function dbGetHandle()
{
    try {
        var db = LocalStorage.openDatabaseSync("NotesApp_DB", "", "Database for storing user notes", 1000000)
    } catch (err) {
        console.log("Error opening database: " + err)
    }
    return db
}

function dbInsert(noteDate, noteTime, noteText)
{
    var db = dbGetHandle()
    var rowid = 0;
    db.transaction(function (tx) {
        tx.executeSql('INSERT INTO notes_table(date, time, note_text) VALUES(?, ?, ?)', [noteDate, noteTime, noteText])
        var result = tx.executeSql('SELECT last_insert_rowid()')
        rowid = result.insertId
    })
    return rowid;
}

function updateNote(id, noteDate, noteTime, noteText) {
    var db = dbGetHandle()
    db.transaction(function (tx) {
        tx.executeSql("UPDATE notes_table SET date = ?, time = ?, note_text = ? WHERE id = ?", [noteDate, noteTime, noteText, id]);
    });
}

function deleteNote(id) {
    var db = dbGetHandle()
    db.transaction(function (tx) {
        tx.executeSql("DELETE FROM notes_table WHERE id = ?", [id]);
    });
}

function getNote(id, callback) {
    var db = dbGetHandle()
    db.readTransaction(function (tx) {
        var result = tx.executeSql("SELECT * FROM notes_table WHERE id = ?", [id]);
        callback(result.rows.item(0));
    });
}

function dbReadAll()
{
    var db = dbGetHandle()
    db.transaction(function (tx) {
        var results = tx.executeSql('SELECT * FROM notes_table order by id desc')
        for (var i = 0; i < results.rows.length; i++) {

            var noteItem = results.rows.item(i)

            var noteData = {
                "id": noteItem.id.toString(10),
                "date_text": noteItem.date,
                "time_text": noteItem.time,
                "note_text": noteItem.note_text
            }

            listModel.append(noteData)
        }
    })
}
