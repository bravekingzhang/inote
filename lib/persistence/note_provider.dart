import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const String dbName = "data_note.db";
final String tableNote = 'node';
final String columnId = '_id';
final String columnTitle = 'title';
final String columnContent = 'content';
final String columnTime = "time";
final String columnDone = 'done';

class Note {
  int id;
  String title;
  String content;
  int time;
  bool done;

  Note({this.title, this.content, this.time, this.done});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnTitle: title,
      columnContent: content,
      columnTime: time,
      columnDone: done == true ? 1 : 0
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  Note.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    title = map[columnTitle];
    content = map[columnContent];
    time = map[columnTime];
    done = map[columnDone] == 1;
  }
}

class NoteProvider {
  Database _db;

  Future _open({String name = dbName}) async {
    if (_db == null || !_db.isOpen) {
      var databasesPath = await getDatabasesPath();
      String path = join(databasesPath, name);
      _db = await openDatabase(path, version: 1,
          onCreate: (Database db, int version) async {
        await db.execute('''
create table $tableNote ( 
  $columnId integer primary key autoincrement, 
  $columnTitle text not null,
  $columnContent text not null,
   $columnTime integer not null,
  $columnDone integer not null)
''');
      });
    }
  }

  Future<Note> insert(Note note) async {
    await _open();
    note.id = await _db.insert(tableNote, note.toMap());
    return note;
  }

  Future<List<Note>> listNote() async {
    await _open();
    List<Map> maps = await _db.query(tableNote, columns: [
      columnId,
      columnDone,
      columnTitle,
      columnTime,
      columnContent
    ]);
    return maps.map((e) => Note.fromMap(e)).toList();
  }

  Future<Note> getNote(int id) async {
    await _open();
    List<Map> maps = await _db.query(tableNote,
        columns: [columnId, columnDone, columnTitle],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return Note.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    await _open();
    return await _db.delete(tableNote, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(Note note) async {
    await _open();
    return await _db.update(tableNote, note.toMap(),
        where: '$columnId = ?', whereArgs: [note.id]);
  }

  Future close() async => _db.close();
}
