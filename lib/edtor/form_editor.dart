import 'package:flutter/material.dart';

import 'package:inote/persistence/note_provider.dart';
import 'package:zefyr/zefyr.dart';

import 'package:inote/edtor/full_page.dart';
import 'dart:convert';
import 'package:inote/bloc/node_list_bloc.dart';
import 'package:inote/bloc/home_bloc.dart';
import 'package:inote/edtor/period_setting.dart';

class FormEmbeddedScreen extends StatefulWidget {
  final NoteListBloc noteListBloc;
  final HomeBloc homeBloc;

  @override
  _FormEmbeddedScreenState createState() => _FormEmbeddedScreenState();

  FormEmbeddedScreen({this.noteListBloc, this.homeBloc});
}

class _FormEmbeddedScreenState extends State<FormEmbeddedScreen> {
  final ZefyrController _controller = ZefyrController(NotusDocument());
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _focusNode = new FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final form = Column(mainAxisSize: MainAxisSize.max, children: <Widget>[
      SizedBox(
        height: 15.0,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: TextField(
            controller: _titleController,
            decoration: InputDecoration(
                border: UnderlineInputBorder(), labelText: '标题')),
      ),
//      Padding(
//        padding: const EdgeInsets.symmetric(horizontal: 15.0),
//        child: TextField(
//            decoration: InputDecoration(
//                border: UnderlineInputBorder(), labelText: '类别',enabled: false,)),
//      ),
      Expanded(
        child: buildEditor(),
      ),
    ]);
    return Scaffold(
      appBar: AppBar(
        elevation: 1.0,
        backgroundColor: Colors.grey.shade200,
        iconTheme: IconThemeData(color: Colors.blueAccent),
        brightness: Brightness.light,
        title: Text(
          "新建记忆",
          style: Theme.of(context).textTheme.title,
        ),
        actions: <Widget>[
          new FlatButton(
              onPressed: _save,
              child: Text(
                '下一步',
                style: TextStyle(color: Colors.blueAccent),
              ))
        ],
      ),
      resizeToAvoidBottomPadding: true,
      body: ZefyrScaffold(
        child: form,
      ),
    );
  }

  Widget buildEditor() {
    final theme = new ZefyrThemeData(
      toolbarTheme: ZefyrToolbarTheme.fallback(context).copyWith(
        color: Colors.grey.shade800,
        toggleColor: Colors.grey.shade900,
        iconColor: Colors.white,
        disabledIconColor: Colors.grey.shade500,
      ),
    );

    return Container(
      decoration: BoxDecoration(
          border: Border(),
          color: Colors.blueAccent,
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.deepOrangeAccent]),
//          image: DecorationImage(image: Image.asset("images/editor1.jpg").image,fit: BoxFit.fill),
          borderRadius: BorderRadius.circular(3.0)),
      child: ZefyrTheme(
        data: theme,
        child: ZefyrEditor(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: false,
          imageDelegate: new CustomImageDelegate(),
          physics: ClampingScrollPhysics(),
          enabled: true,
        ),
      ),
    );
  }

  void _save() async {
    Note note = Note(
        title: _titleController.text,
        content: jsonEncode(_controller.document.toJson()));
    bool result =
        await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return PeriodSetting(
                note: note,
                homeBloc: widget.homeBloc,
                noteListBloc: widget.noteListBloc,
              );
            })) ??
            false;
    if (result) {
      //成功添加之后，退出编辑页面
      Navigator.of(context).pop();
    }
  }
}
