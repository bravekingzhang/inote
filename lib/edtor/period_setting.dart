import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:inote/persistence/note_provider.dart';
import 'package:inote/bloc/node_list_bloc.dart';
import 'package:inote/bloc/home_bloc.dart';

//记忆曲线设置
class PeriodSetting extends StatefulWidget {
  final Note note;
  final HomeBloc homeBloc;
  final NoteListBloc noteListBloc;

  const PeriodSetting({Key key, this.note, this.homeBloc, this.noteListBloc})
      : super(key: key);

  @override
  _PeriodSettingState createState() => _PeriodSettingState();
}

class _PeriodSettingState extends State<PeriodSetting> {
  double _kPickerSheetHeight = 216.0;

  List<PeriodSettingStr> scheduleList = List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initSchedule();
  }

  void _initSchedule() {
    scheduleList
        .add(PeriodSettingStr(index: 1, title: "第一次提醒", schedule: 20 * 60));
    scheduleList
        .add(PeriodSettingStr(index: 2, title: "第二次提醒", schedule: 1 * 60 * 60));
    scheduleList
        .add(PeriodSettingStr(index: 3, title: "第三次提醒", schedule: 9 * 60 * 60));
    scheduleList.add(
        PeriodSettingStr(index: 4, title: "第四次提醒", schedule: 1 * 24 * 60 * 60));
    scheduleList.add(
        PeriodSettingStr(index: 5, title: "第五次提醒", schedule: 2 * 24 * 60 * 60));
    scheduleList.add(
        PeriodSettingStr(index: 6, title: "第六次提醒", schedule: 6 * 24 * 60 * 60));
    scheduleList.add(PeriodSettingStr(
        index: 7, title: "第七次提醒", schedule: 31 * 24 * 60 * 60));
  }

  Widget _buildBottomPicker(Widget picker) {
    return Container(
      height: _kPickerSheetHeight,
      padding: const EdgeInsets.only(top: 6.0),
      color: CupertinoColors.white,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: CupertinoColors.black,
          fontSize: 22.0,
        ),
        child: GestureDetector(
          // Blocks taps from propagating to the modal sheet and popping.
          onTap: () {},
          child: SafeArea(
            top: false,
            child: picker,
          ),
        ),
      ),
    );
  }

  Widget _buildMenu(List<Widget> children) {
    return Container(
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFBCBBC1), width: 0.0),
          bottom: BorderSide(color: Color(0xFFBCBBC1), width: 0.0),
        ),
      ),
      height: 44.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SafeArea(
          top: false,
          bottom: false,
          child: DefaultTextStyle(
            style: const TextStyle(
              letterSpacing: -0.24,
              fontSize: 17.0,
              color: CupertinoColors.black,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: children,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateAndTimePicker(PeriodSettingStr per) {
    return GestureDetector(
      onTap: () {
        showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) {
            return _buildBottomPicker(
              CupertinoDatePicker(
                mode: CupertinoDatePickerMode.dateAndTime,
                initialDateTime: DateTime.fromMillisecondsSinceEpoch(
                    new DateTime.now().millisecondsSinceEpoch +
                        per.schedule * 1000),
                onDateTimeChanged: (DateTime newDateTime) {
                  _scheduleChange(
                      per.index,
                      (newDateTime.millisecondsSinceEpoch -
                              DateTime.now().millisecondsSinceEpoch) ~/
                          1000);
                },
              ),
            );
          },
        );
      },
      child: _buildMenu(
        <Widget>[
          Text(per.title),
          Text(
            DateFormat.yMMMd().add_jm().format(
                DateTime.fromMillisecondsSinceEpoch(
                    new DateTime.now().millisecondsSinceEpoch +
                        per.schedule * 1000)),
            style: const TextStyle(color: CupertinoColors.inactiveGray),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记忆曲线设置'),
        actions: <Widget>[
          new FlatButton(
              onPressed: _save,
              child: Text(
                'Done',
                style: TextStyle(color: Colors.blueAccent),
              ))
        ],
      ),
      body: DefaultTextStyle(
        style: const TextStyle(
          fontFamily: '.SF UI Text',
          fontSize: 17.0,
          color: CupertinoColors.black,
        ),
        child: DecoratedBox(
          decoration: const BoxDecoration(color: Color(0xFFEFEFF4)),
          child: ListView(
            children: scheduleList.map(_buildDateAndTimePicker).toList(),
          ),
        ),
      ),
    );
  }

  Future _save() async {
    Note note = await widget.noteListBloc
        .onNoteAdd(title: widget.note.title, content: widget.note.content);
    Navigator.of(context).pop();
    print('插入笔记成功$note');
    widget.homeBloc.showNotifyPeriodically(note: note,);
  }

  void _scheduleChange(int index, int period) {
    for (var value in scheduleList) {
      if (value.index == index) {
        value.schedule = period;
        break;
      }
    }
    setState(() {
      scheduleList = scheduleList;
    });
  }
}

class PeriodSettingStr {
  int index;
  String title;
  int schedule;

  PeriodSettingStr({this.index, this.title, this.schedule});
}
