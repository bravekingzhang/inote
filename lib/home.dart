import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inote/bloc/node_list_bloc.dart';
import 'package:inote/note_list.dart';

const List<Color> coolColors = <Color>[
  Color.fromARGB(255, 255, 59, 48),
  Color.fromARGB(255, 255, 149, 0),
  Color.fromARGB(255, 255, 204, 0),
  Color.fromARGB(255, 76, 217, 100),
  Color.fromARGB(255, 90, 200, 250),
  Color.fromARGB(255, 0, 122, 255),
  Color.fromARGB(255, 88, 86, 214),
  Color.fromARGB(255, 255, 45, 85),
];

class HomePage extends StatelessWidget {
  HomePage()
      : colorItems = List<Color>.generate(50, (int index) {
          return coolColors[math.Random().nextInt(coolColors.length)];
        });

  final List<Color> colorItems;

  @override
  Widget build(BuildContext context) {
    NoteListBloc noteListBloc = BlocProvider.of(context);
    return WillPopScope(
      // Prevent swipe popping of this page. Use explicit exit buttons only.
      onWillPop: () => Future<bool>.value(true),
      child: DefaultTextStyle(
        style: const TextStyle(
          fontFamily: '.SF UI Text',
          fontSize: 17.0,
          color: CupertinoColors.black,
        ),
        child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                title: Text('ing'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.done),
                title: Text('done'),
              ),
            ],
          ),
          tabBuilder: (BuildContext context, int index) {
            assert(index >= 0 && index <= 1);
            switch (index) {
              case 0:
                return CupertinoTabView(
                  //进行中
                  builder: (BuildContext context) {
                    return NoteList(
                      colorItems: colorItems,
                      noteListBloc: noteListBloc,
                      done: false,
                    );
                  },
                  defaultTitle: 'Notes',
                );
                break;
              case 1:
                return CupertinoTabView(
                  //已完成
                  builder: (BuildContext context) {
                    return NoteList(
                      colorItems: colorItems,
                      noteListBloc: noteListBloc,
                      done: true,
                    );
                  },
                  defaultTitle: 'Notes',
                );
                break;
            }
            return null;
          },
        ),
      ),
    );
  }
}
