import 'package:rxdart/subjects.dart';
import 'bloc_provider.dart';
import 'package:inote/persistence/note_provider.dart';
export 'bloc_provider.dart';

class NoteListBloc extends BlocBase {
  BehaviorSubject<List<Note>> _behaviorSubject = BehaviorSubject();

  List<Note> _list = List();

  NoteProvider _noteProvider;

  Stream<List<Note>> get noteList => _behaviorSubject.stream;

  @override
  void dispose() {
    // TODO: implement dispose
    _behaviorSubject.close();
  }

  @override
  void initState() async {
    // TODO: implement initState
    _noteProvider = NoteProvider();
    _list = await _noteProvider.listNote();
    _behaviorSubject.sink.add(_list);
  }

  Future<Note> onNoteAdd({String title, String content}) async {
    Note note = Note(
        title: title,
        content: content,
        time: new DateTime.now().millisecondsSinceEpoch ~/ 1000,
        done: false);
    _noteProvider.insert(note);
    _list.insert(0, note);
    _behaviorSubject.sink.add(_list);
    return note;
  }
}
