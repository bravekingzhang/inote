import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:inote/bloc/home_bloc.dart';
import 'package:inote/bloc/node_list_bloc.dart';
import 'package:inote/edtor/full_page.dart';
import 'package:inote/edtor/period_setting.dart';
import 'package:inote/tool_tip_button.dart';
import 'package:inote/add_note.dart';
import 'package:inote/persistence/note_provider.dart';
import 'package:inote/utils/toast_utils.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class NoteList extends StatefulWidget {
  const NoteList({
    this.colorItems,
    this.noteListBloc,
    this.homeBloc,
    this.done,
  });

  final List<Color> colorItems;
  final HomeBloc homeBloc;
  final NoteListBloc noteListBloc;
  final bool done;

  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  SlidableController slidableController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    slidableController = SlidableController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
//        semanticChildCount: _kChildCount,
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            trailing: ToolTipButton(
              message: "add new note",
              text: "添加",
              callback: () {
                Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (context) {
                  return AddNote(
                    noteListBloc: widget.noteListBloc,
                    homeBloc: widget.homeBloc,
                  );
                }));
              },
            ),
          ),
          StreamBuilder(
            stream: widget.done
                ? widget.noteListBloc.noteListDone
                : widget.noteListBloc.noteListGoing,
            builder:
                (BuildContext context, AsyncSnapshot<List<Note>> snapshot) {
              if (!snapshot.hasData) {
                return _buildWaitingForData(context);
              } else {
                int length = snapshot.data?.length ?? 0;
                return buildListData(context, length, snapshot);
              }
            },
          ),
        ],
      ),
    );
  }

  SliverPadding buildListData(
      BuildContext context, int length, AsyncSnapshot<List<Note>> snapshot) {
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
      sliver: length != 0
          ? SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Slidable.builder(
                      controller: slidableController,
                      key: Key(index.toString()),
                      child: NoteItemView(
                        index: index,
                        lastItem: index == snapshot.data.length - 1,
                        color: widget.colorItems[index],
                        note: snapshot.data[index],
                        done: widget.done,
                        noteListBloc: widget.noteListBloc,
                        homeBloc: widget.homeBloc,
                      ),
                      delegate: SlidableDrawerDelegate(),
                      secondaryActionDelegate: new SlideActionBuilderDelegate(
                          actionCount: 2,
                          builder: (context, actionIndex, animation, renderingMode) {
                            if (actionIndex == 0) {
                              return new IconSlideAction(
                                caption: widget.done?'重新开始':'提前完成',
                                color:
                                    renderingMode == SlidableRenderingMode.slide
                                        ? Colors.grey.shade200
                                            .withOpacity(animation.value)
                                        : Colors.grey.shade200,
                                icon: widget.done?Icons.redo:Icons.done,
                                onTap: () async {
                                  Note note = snapshot.data[index];
                                  if (!widget.done) {
                                    //设置笔记标志位为完成
                                    _setNoteDone(note, context);
                                  } else {
                                    //重新开始笔记
                                    await _setNoteReMem(context, note);
                                  }
                                },
                              );
                            } else {
                              return new IconSlideAction(
                                caption: '删除',
                                color: renderingMode ==
                                        SlidableRenderingMode.slide
                                    ? Colors.red.withOpacity(animation.value)
                                    : Colors.red,
                                icon: Icons.delete,
                                onTap: ()  async{
                                  Note note = snapshot.data[index];
                                  _deleteNote(note, context);
                                }
                              );
                            }
                          }));
                },
                childCount: snapshot.data?.length ?? 0,
              ),
            )
          : _buildNoData(),
    );
  }

  Future _setNoteReMem(BuildContext context, Note note) async {
    bool result =
        await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return PeriodSetting(
                note: note,
                homeBloc: widget.homeBloc,
                noteListBloc: widget.noteListBloc,
                isRedo: true,
              );
            })) ??
            false;
    if (result) {
      showToast("已重新开始复习！");
    }
  }


  void _deleteNote(Note note, BuildContext context) {
    //清除笔记待提醒事件
    widget.homeBloc.setNoteFinished(note: note);
    widget.noteListBloc.deleteNote(note);
    _showSnackBar(context, '已删除[${note.title}]');
  }

  void _setNoteDone(Note note, BuildContext context) {
    widget.noteListBloc.onDone(note);
    //清除笔记待提醒事件
    widget.homeBloc.setNoteFinished(note: note);
    //                        showToast("恭喜！已提前完成！");
    _showSnackBar(context, '已提前完成[${note.title}]');
  }

  void _showSnackBar(BuildContext context, String text) {
    print("_showSnackBar");
    Scaffold.of(context).showSnackBar(SnackBar(content: new Text(text)));
  }

  SliverFillViewport _buildNoData() {
    return SliverFillViewport(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset("images/no_content.jpg"),
              SizedBox(
                height: 8.0,
              ),
              Text(
                !widget.done ? "还没有笔记，赶紧点右上角添加一个吧~" : "还没有已完成的笔记，加油哦~",
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
        );
      }, childCount: 1),
    );
  }

  SliverPadding _buildWaitingForData(BuildContext context) {
    return SliverPadding(
      padding: MediaQuery.of(context)
          .removePadding(
            removeTop: true,
            removeLeft: true,
            removeRight: true,
          )
          .padding,
      sliver: SliverFillViewport(
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
          return CupertinoActivityIndicator();
        }, childCount: 1),
      ),
    );
  }
}

class NoteItemView extends StatelessWidget {
  const NoteItemView(
      {this.index,
      this.lastItem,
      this.color,
      this.note,
      this.done,
      this.noteListBloc,
      this.homeBloc});

  final int index;
  final bool lastItem;
  final Color color;
  final Note note;
  final bool done;
  final NoteListBloc noteListBloc;
  final HomeBloc homeBloc;

  @override
  Widget build(BuildContext context) {
    final Widget row = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context, rootNavigator: true)
            .push(CupertinoPageRoute<void>(
          title: note.title,
          builder: (BuildContext context) => FullPageEditorScreen(
                note: note,
            homeBloc: homeBloc,
            noteListBloc: noteListBloc,
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
                  color: done ? Colors.green : color,
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
                      Container(
                        child: LinearPercentIndicator(
                          width: MediaQuery.of(context).size.width * 0.7,
                          lineHeight: 18.0,
                          center: Text(
                            "当前进度${(note.progress * 100).toStringAsFixed(1)}%",
                            style: TextStyle(fontSize: 10.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 1.0, horizontal: 5.0),
                          percent: note.progress,
                          backgroundColor: Colors.grey,
                          progressColor: done ? Colors.green : color,
                        ),
                      )
                    ],
                  ),
                ),
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
