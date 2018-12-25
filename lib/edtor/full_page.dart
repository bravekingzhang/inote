import 'dart:convert';
import 'package:inote/persistence/note_provider.dart';
import 'package:flutter/material.dart';
import 'package:zefyr/zefyr.dart';
import 'package:quill_delta/quill_delta.dart';
import 'dart:math' as math;
import 'package:inote/bloc/node_list_bloc.dart';
import 'package:inote/bloc/home_bloc.dart';
import 'package:inote/utils/toast_utils.dart';

class FullPageEditorScreen extends StatefulWidget {
  final Note note;
  final NoteListBloc noteListBloc;
  final HomeBloc homeBloc;

  @override
  _FullPageEditorScreenState createState() => new _FullPageEditorScreenState();

  FullPageEditorScreen({this.note, this.noteListBloc,this.homeBloc});
}

class _FullPageEditorScreenState extends State<FullPageEditorScreen> {
  ZefyrController _controller;
  final FocusNode _focusNode = new FocusNode();
  bool _editing = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = ZefyrController(NotusDocument.fromDelta(
        Delta.fromJson(json.decode(widget.note.content))));
  }

  @override
  Widget build(BuildContext context) {
    final theme = new ZefyrThemeData(
      toolbarTheme: ZefyrToolbarTheme.fallback(context).copyWith(
        color: Colors.grey.shade800,
        toggleColor: Colors.grey.shade900,
        iconColor: Colors.white,
        disabledIconColor: Colors.grey.shade500,
      ),
    );

    final done = _editing
        ? [
            new FlatButton(
                onPressed: _stopEditing,
                child: Text(
                  'DONE',
                  style: TextStyle(color: Colors.blueAccent),
                ))
          ]
        : [
            new FlatButton(
                onPressed: _startEditing,
                child: Text(
                  'EDIT',
                  style: TextStyle(color: Colors.blueAccent),
                ))
          ];
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        elevation: 0.1,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.blueAccent),
        brightness: Brightness.light,
        title: Text(
          widget.note.title,
          style: Theme.of(context).textTheme.title,
        ),
        actions: <Widget>[
          FlatButton(
              onPressed: _delete,
              child: Text(
                '删除',
                style: TextStyle(color: Colors.blueAccent),
              ))
        ],
      ),
      body: ZefyrScaffold(
        child: ZefyrTheme(
          data: theme,
          child: Container(
            padding: EdgeInsets.all(10.0),
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.deepOrangeAccent]),
//              image: DecorationImage(
//                  image: Image.asset("images/editor1.jpg").image,
//                  fit: BoxFit.fill),
            ),
            child: ZefyrEditor(
              controller: _controller,
              focusNode: _focusNode,
              enabled: _editing,
              imageDelegate: new CustomImageDelegate(),
            ),
          ),
        ),
      ),
    );
  }

  void _startEditing() {
    setState(() {
      _editing = true;
    });
  }

  void _delete() async {
    await widget.noteListBloc.deleteNote(widget.note);
    await widget.homeBloc.setNoteFinished(note: widget.note);
    showToast('已删除[${widget.note.title}]');
    Navigator.of(context).pop();
  }

  void _stopEditing() {
    setState(() {
      _editing = false;
    });
  }
}

/// Custom image delegate used by this example to load image from application
/// assets.
///
/// Default image delegate only supports [FileImage]s.
class CustomImageDelegate extends ZefyrDefaultImageDelegate {
  @override
  Widget buildImage(BuildContext context, String imageSource) {
    // We use custom "asset" scheme to distinguish asset images from other files.
    if (imageSource.startsWith('asset://')) {
      final asset = new AssetImage(imageSource.replaceFirst('asset://', ''));
      return new Image(image: asset);
    } else {
      return super.buildImage(context, imageSource);
    }
  }
}
