import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const String dbName = "data_remind.db";
final String tableRemind = 'remind';
final String columnId = '_id';
final String columnNoteId = 'note_id'; //笔记id
final String columnNotifyId = 'notify_id'; //提醒id，每次生成一个
final String columnTime = 'time'; //在创建笔记之时，多久执行此提醒
final String columnDone = 'done'; //是否已经提醒了

class Remind {
  int id;
  int noteId;
  int notifyId;
  int time;
  bool done;

  Remind({this.noteId, this.notifyId, this.time, this.done});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnNoteId: noteId,
      columnNotifyId: notifyId,
      columnTime: time,
      columnDone: done == true ? 1 : 0
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  Remind.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    noteId = map[columnNoteId];
    notifyId = map[columnNotifyId];
    time = map[columnTime];
    done = map[columnDone] == 1;
  }

  @override
  String toString() {
    return 'Remind{id: $id, noteId: $noteId, notifyId: $notifyId, time: $time, done: $done}';
  }
}

//Singleton
class RemindProvider {
  static final RemindProvider _singleton = new RemindProvider._internal();

  factory RemindProvider() {
    return _singleton;
  }

  RemindProvider._internal() {
    _open();
  }

  Database _db;

  Future _open({String name = dbName}) async {
    if (_db == null || !_db.isOpen) {
      var databasesPath = await getDatabasesPath();
      String path = join(databasesPath, name);
      _db = await openDatabase(path, version: 1,
          onCreate: (Database db, int version) async {
        await db.execute('''
create table $tableRemind ( 
  $columnId integer primary key autoincrement, 
  $columnNoteId integer not null,
  $columnNotifyId integer not null,
   $columnTime integer not null,
  $columnDone integer not null)
''');
      });
    }
  }

  Future<Remind> getRemind({int notifyId}) async {
    await _open();
    await _open();
    List<Map> maps = await _db.query(tableRemind,
        columns: [
          columnId,
          columnDone,
          columnNoteId,
          columnTime,
          columnNotifyId
        ],
        where: '$columnNotifyId = ?',
        whereArgs: [notifyId]);
    return Remind.fromMap(maps.first);
  }

  Future<Remind> insert(Remind remind) async {
    await _open();
    remind.id = await _db.insert(tableRemind, remind.toMap());
    return remind;
  }

  //列举笔记下面所有的提醒
  Future<List<Remind>> listRemind({int noteId, bool isDone}) async {
    await _open();
    List<Map> maps = await _db.query(tableRemind,
        columns: [
          columnId,
          columnDone,
          columnNoteId,
          columnTime,
          columnNotifyId
        ],
        where: '$columnNoteId = ? and $columnDone = ?',
        whereArgs: [noteId, isDone ? 1 : 0]);
    return maps.map((e) => Remind.fromMap(e)).toList();
  }

  //笔记下面所有的提醒
  Future deleteAllRemind({int noteId}) async {
    await _open();
    await _db
        .delete(tableRemind, where: '$columnNoteId=?', whereArgs: [noteId]);
  }

//该笔记是否已经完成提醒
  Future<bool> isNoteDone({int noteId}) async {
    await _open();
    List<Map> maps = await _db.query(tableRemind,
        columns: [
          columnId,
          columnDone,
          columnNoteId,
          columnTime,
          columnNotifyId
        ],
        where: '$columnNoteId = ? and $columnDone = 0',
        whereArgs: [noteId]);
    return maps == null || maps.length == 0;
  }

  //设置某条笔记的提醒已经完成
  Future setNotifyDone({int notifyId}) async {
    await _open();
    await _db.rawUpdate(
        'UPDATE $tableRemind SET $columnDone = 1 WHERE $columnNotifyId = ?',
        [notifyId]);
  }

  //拿到最大的提醒id，因为设置周期性提醒需要一个唯一的id
  Future<int> getMaxNotifyIdByNoteId({int noteId}) async {
    await _open();
    List<Map> maps = await _db.rawQuery(
        'SELECT max($columnNotifyId) FROM $tableRemind where $columnNoteId = $noteId');
    if (maps == null || maps.length == 0) {
      return 0;
    }
    return Sqflite.firstIntValue(maps) ?? 0;
  }

  //拿到最大的提醒id，因为设置周期性提醒需要一个唯一的id
  Future<int> getMaxNotifyId() async {
    await _open();
    List<Map> maps =
        await _db.rawQuery('SELECT max($columnNotifyId) FROM $tableRemind');
    if (maps == null || maps.length == 0) {
      return 0;
    }
    return Sqflite.firstIntValue(maps) ?? 0;
  }

  Future<int> delete(int id) async {
    await _open();
    return await _db
        .delete(tableRemind, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(Remind remind) async {
    await _open();
    return await _db.update(tableRemind, remind.toMap(),
        where: '$columnId = ?', whereArgs: [remind.id]);
  }

  Future close() async => _db.close();
}
