import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:inote/bloc/home_bloc.dart';
import 'package:inote/bloc/node_list_bloc.dart';
import 'package:inote/note_list_done.dart';
import 'package:inote/about.dart';
import 'package:url_launcher/url_launcher.dart';


class Mine extends StatefulWidget {
  final List<Color> colorItems;
  final HomeBloc homeBloc;
  final NoteListBloc noteListBloc;

  const Mine({this.colorItems, this.homeBloc, this.noteListBloc});

  @override
  _MineState createState() => _MineState();
}

class _MineState extends State<Mine> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            largeTitle: Text("Setting"),
          ),
          SliverPadding(
            padding: MediaQuery.of(context)
                .removePadding(
                  removeTop: true,
                  removeLeft: true,
                  removeRight: true,
                )
                .padding,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ListTile(
                  title: Text("已完成"),
                  onTap: () {
                    Navigator.of(context, rootNavigator: true)
                        .push(MaterialPageRoute(builder: (context) {
                      return NoteListDone(
                        colorItems: widget.colorItems,
                        noteListBloc: widget.noteListBloc,
                        homeBloc: widget.homeBloc,
                        done: true,
                      );
                    }));
                  },
                  trailing: Icon(Icons.chevron_right),
                ),
                Divider(),
                ListTile(
                  title: Text("关于"),
                  onTap: () {
                    Navigator.of(context,rootNavigator: true)
                        .push(MaterialPageRoute(builder: (context) {
                      return About();
                    }));
                  },
                  trailing: Icon(Icons.chevron_right),
                ),
                Divider(),
                Center(
                    child: InkWell(
                      child: Text("隐私条例",style:Theme.of(context).textTheme.caption.copyWith(color: Colors.blue),),
                      onTap: (){
                        _launchURL();
                      },
                )),
              ]),
            ),
          )
        ],
      ),
    );
  }
  _launchURL() async {
    const url = 'https://flippedwords.com/colleague/agreement_inote.html';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
