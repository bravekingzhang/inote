// Copyright (c) 2018, the Zefyr project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:inote/bloc/home_bloc.dart';
import 'package:inote/edtor/form_editor.dart';
import 'package:inote/bloc/node_list_bloc.dart';

class AddNote extends StatefulWidget {
  final NoteListBloc noteListBloc;
  final HomeBloc homeBloc;

  AddNote({this.noteListBloc, this.homeBloc});

  @override
  _AddNoteState createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(child: FormEmbeddedScreen(noteListBloc: widget.noteListBloc,homeBloc: widget.homeBloc,));
  }
}
