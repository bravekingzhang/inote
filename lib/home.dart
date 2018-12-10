import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inote/persistence/note_provider.dart';
import 'package:inote/tool_tip_button.dart';
import 'package:inote/note_detail.dart';
import 'package:inote/add_note.dart';
import 'package:inote/bloc/node_list_bloc.dart';

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

const List<String> coolColorNames = <String>[
  'Sarcoline',
  'Coquelicot',
  'Smaragdine',
  'Mikado',
  'Glaucous',
  'Wenge',
  'Fulvous',
  'Xanadu',
  'Falu',
  'Eburnean',
  'Amaranth',
  'Australien',
  'Banan',
  'Falu',
  'Gingerline',
  'Incarnadine',
  'Labrador',
  'Nattier',
  'Pervenche',
  'Sinoper',
  'Verditer',
  'Watchet',
  'Zaffre',
];

const int _kChildCount = 50;

class HomePage extends StatelessWidget {
  HomePage()
      : colorItems = List<Color>.generate(50, (int index) {
          return coolColors[math.Random().nextInt(coolColors.length)];
        }),
        colorNameItems = List<String>.generate(50, (int index) {
          return coolColorNames[math.Random().nextInt(coolColorNames.length)];
        });

  final List<Color> colorItems;
  final List<String> colorNameItems;

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
                  builder: (BuildContext context) {
                    return NoteList(
                      colorItems: colorItems,
                      colorNameItems: colorNameItems,
                      noteListBloc: noteListBloc,
                    );
                  },
                  defaultTitle: 'Notes',
                );
                break;
              case 1:
                return CupertinoTabView(
                  builder: (BuildContext context) => CupertinoPageScaffold(
                          child: Center(
                        child: Text("page2"),
                      )),
                  defaultTitle: 'Support Chat',
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

class NoteList extends StatelessWidget {
  const NoteList({this.colorItems, this.colorNameItems, this.noteListBloc});

  final List<Color> colorItems;
  final List<String> colorNameItems;
  final NoteListBloc noteListBloc;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
//        semanticChildCount: _kChildCount,
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            trailing: ToolTipButton(
              message: "add new note",
              text: "Add",
              callback: () {
                Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (context) {
                  return AddNote(
                    noteListBloc: noteListBloc,
                  );
                }));
              },
            ),
          ),
          StreamBuilder(
            stream: noteListBloc.noteList,
            builder:
                (BuildContext context, AsyncSnapshot<List<Note>> snapshot) {
              return SliverPadding(
                // Top media padding consumed by CupertinoSliverNavigationBar.
                // Left/Right media padding consumed by Tab1RowItem.
                padding: MediaQuery.of(context)
                    .removePadding(
                      removeTop: true,
                      removeLeft: true,
                      removeRight: true,
                    )
                    .padding,
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return NoteItemView(
                        index: index,
                        lastItem: index == snapshot.data.length - 1,
                        color: colorItems[index],
                        title: snapshot.data[index].title,
                      );
                    },
                    childCount: snapshot.data?.length ?? 0,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class NoteItemView extends StatelessWidget {
  const NoteItemView({this.index, this.lastItem, this.color, this.title});

  final int index;
  final bool lastItem;
  final Color color;
  final String title;

  @override
  Widget build(BuildContext context) {
    final Widget row = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute<void>(
          title: title,
          builder: (BuildContext context) => NoteDetail(
                color: color,
                colorName: title,
                index: index,
              ),
        ));
      },
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(
              left: 16.0, top: 8.0, bottom: 8.0, right: 8.0),
          child: Row(
            children: <Widget>[
              Container(
                height: 40.0,
                width: 40.0,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Text(
                    title.substring(0, 1).toUpperCase(),
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(title),
                      const Padding(padding: EdgeInsets.only(top: 8.0)),
                    ],
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(
                  CupertinoIcons.time,
                  color: CupertinoColors.activeBlue,
                  semanticLabel: 'going',
                ),
                onPressed: () {},
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(
                  Icons.done,
                  color: CupertinoColors.activeBlue,
                  semanticLabel: 'done',
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );

    if (lastItem) {
      return row;
    }

    return Column(
      children: <Widget>[
        row,
        Container(
          height: 1.0,
          color: const Color(0xFFD9D9D9),
        ),
      ],
    );
  }
}
