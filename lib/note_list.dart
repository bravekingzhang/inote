import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:inote/bloc/home_bloc.dart';
import 'package:inote/bloc/node_list_bloc.dart';
import 'package:inote/edtor/full_page.dart';
import 'package:inote/tool_tip_button.dart';
import 'package:inote/add_note.dart';
import 'package:inote/persistence/note_provider.dart';
import 'package:inote/utils/toast_utils.dart';

class NoteList extends StatelessWidget {
  const NoteList(
      {this.colorItems, this.noteListBloc, this.homeBloc, this.done});

  final List<Color> colorItems;
  final HomeBloc homeBloc;
  final NoteListBloc noteListBloc;
  final bool done;

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
                    homeBloc: homeBloc,
                  );
                }));
              },
            ),
          ),
          StreamBuilder(
            stream:
                done ? noteListBloc.noteListDone : noteListBloc.noteListGoing,
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
                        note: snapshot.data[index],
                        done: done,
                        bloc: noteListBloc,
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
  const NoteItemView(
      {this.index, this.lastItem, this.color, this.note, this.done, this.bloc});

  final int index;
  final bool lastItem;
  final Color color;
  final Note note;
  final bool done;
  final NoteListBloc bloc;

  @override
  Widget build(BuildContext context) {
    final Widget row = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context, rootNavigator: true)
            .push(CupertinoPageRoute<void>(
          title: note.title,
          builder: (BuildContext context) => FullPageEditorScreen(
                color: done ? Colors.grey : color,
                note: note,
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
                  color: done ? Colors.grey : color,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Text(
                    note.title.substring(0, 1).toUpperCase(),
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
                      Text(note.title),
                      const Padding(padding: EdgeInsets.only(top: 8.0)),
                    ],
                  ),
                ),
              ),
              !note.done
                  ? CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Icon(
                        CupertinoIcons.time,
                        color: CupertinoColors.activeBlue,
                        semanticLabel: 'going',
                      ),
                      onPressed: () {
                        bloc.onDone(note);
                        showToast("恭喜！已提前完成！");
                      },
                    )
                  : CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Icon(
                        Icons.done,
                        color: CupertinoColors.inactiveGray,
                        semanticLabel: 'done',
                      ),
                      onPressed: () {
                        bloc.onReDoing(note);
                        showToast("已重新开始复习！");
                      },
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
