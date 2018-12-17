import 'package:inote/persistence/remind_provider.dart';
import 'package:rxdart/subjects.dart';
import 'bloc_provider.dart';
import 'package:inote/persistence/note_provider.dart';
export 'bloc_provider.dart';

class NoteListBloc extends BlocBase {
  BehaviorSubject<List<Note>> _controllerDone = BehaviorSubject();
  BehaviorSubject<List<Note>> _controllerGoing = BehaviorSubject();

  List<Note> _listDone = List();
  List<Note> _listGoing = List();

  NoteProvider _noteProvider;

  RemindProvider _remindProvider;

  Stream<List<Note>> get noteListDone => _controllerDone.stream;

  Stream<List<Note>> get noteListGoing => _controllerGoing.stream;

  @override
  void dispose() {
    // TODO: implement dispose
    _controllerDone.close();
    _controllerGoing.close();
  }

  @override
  void initState() async {
    // TODO: implement initState
    _noteProvider = NoteProvider();
    _remindProvider = RemindProvider();
    _listDone = await _noteProvider.listNote(done: true);
    _listGoing = await _noteProvider.listNote(done: false);
    _controllerDone.sink.add(_listDone);
    _controllerGoing.sink.add(_listGoing);
  }

  ///添加
  Future<Note> onNoteAdd({String title, String content}) async {
    Note note = Note(
        title: title,
        content: content,
        time: new DateTime.now().millisecondsSinceEpoch ~/ 1000,
        done: false);
    note= await _noteProvider.insert(note);
    _listGoing.insert(0, note);
    _controllerGoing.sink.add(_listGoing);
    return note;
  }

  ///主动使得note完成
  Future onDone(Note note) async {
    note.done = true;
    _noteProvider.update(note);
    _listDone.add(note);
    _controllerDone.sink.add(_listDone);
    for (var value in _listGoing) {
      if (value.id == note.id) {
        _listGoing.remove(value);
        break;
      }
    }
    _controllerGoing.sink.add(_listGoing);
  }

  ///主动使得重新开始note
  void onReDoing(Note note) {
    note.done = false;
    _noteProvider.update(note);
    _listGoing.insert(0, note);
    _controllerGoing.sink.add(_listGoing);
    for (var value in _listGoing) {
      if (value.id == note.id) {
        _listDone.remove(value);
        break;
      }
    }
    _controllerDone.sink.add(_listDone);
  }
}
