import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ToolTipButton extends StatelessWidget {
  const ToolTipButton({this.message, this.text, this.callback});

  final String message;
  final String text;
  final VoidCallback callback;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      child: Tooltip(
        message: message,
        child: Text(text),
        excludeFromSemantics: true,
      ),
      onPressed: callback,
    );
  }
}
