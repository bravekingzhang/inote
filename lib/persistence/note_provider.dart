import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:inote/persistence/remind_provider.dart';

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
  double progress;
  bool done;

  Note({this.title, this.content, this.progress = 1.0, this.time, this.done});

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

  @override
  String toString() {
    return 'Note{id: $id, title: $title, content: $content, time: $time, done: $done}';
  }
}

//Singleton
class NoteProvider {
  static final NoteProvider _singleton = new NoteProvider._internal();

  factory NoteProvider() {
    return _singleton;
  }

  NoteProvider._internal() {
    _open();
    _remindProvider = RemindProvider();
  }

  RemindProvider _remindProvider;
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

  Future<List<Note>> listNote({bool done}) async {
    await _open();
    List<Map> maps = await _db.query(tableNote,
        columns: [columnId, columnDone, columnTitle, columnTime, columnContent],
        where: '$columnDone = ?',
        whereArgs: [done ? 1 : 0]);
    List<Note> noteList = maps.map((e) => Note.fromMap(e)).toList();
    if (done) {
      for (var value in noteList) {
        value.progress = 1.0;
      }
    } else {
      for (var value in noteList) {
        value.progress = await _remindProvider.progress(noteId: value.id);
      }
    }
    return noteList;
  }

  Future<Note> getNote(int id) async {
    await _open();
    List<Map> maps = await _db.query(tableNote,
        columns: [columnId, columnDone, columnTitle, columnTime, columnContent],
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
