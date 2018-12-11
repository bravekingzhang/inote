import 'dart:convert';
import 'package:inote/persistence/note_provider.dart';
import 'package:flutter/material.dart';
import 'package:zefyr/zefyr.dart';
import 'package:quill_delta/quill_delta.dart';
import 'dart:math' as math;

class FullPageEditorScreen extends StatefulWidget {
  final Note note;
  final Color color;

  @override
  _FullPageEditorScreenState createState() => new _FullPageEditorScreenState();

  FullPageEditorScreen({this.note, this.color});
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
        elevation: 1.0,
        backgroundColor: Colors.grey.shade200,
        iconTheme: IconThemeData(color: Colors.blueAccent),
        brightness: Brightness.light,
        title: Text(
          widget.note.title,
          style: Theme.of(context).textTheme.title,
        ),
      ),
      body: ZefyrScaffold(
        child: ZefyrTheme(
          data: theme,
          child: Container(
            decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(),
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, widget.color])),
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
