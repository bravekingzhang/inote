import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

//关于页
class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("关于"),
        ),
        child: SafeArea(
          child: ListView(
            children: <Widget>[
              Center(
                child: Text(
                  "MemNote",
                  style: Theme.of(context).textTheme.headline,
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    text: TextSpan(
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                              text: "MemNote",
                              style: Theme.of(context).textTheme.title),
                          TextSpan(text: "是一款基于艾宾浩斯遗忘曲线设计的辅助记忆的软件，旨在提升您的工作效率。\n"),
                          TextSpan(text: "\n"),
                          TextSpan(
                              text: "已有功能\n",
                              style: Theme.of(context).textTheme.subtitle),
                          TextSpan(text: "\n"),
                          TextSpan(text: "1、增加一条复习笔记。\n"),
                          TextSpan(text: "2、可以查看进行中的，已完成的项目。\n"),
                          TextSpan(text: "3、可也手动强制完成进行中的，也可以把已完成的重新加入到进行中。\n"),
                          TextSpan(text: "4、周期提醒，提醒周期默认按照艾宾浩斯曲线。\n"),
                          TextSpan(text: "5、复习完毕自动加入到已经完成中。\n"),
                          TextSpan(text: "6、支持自定义提醒时间设置。\n"),
                          TextSpan(text: "7、右滑列表项删除一条复习笔记，注意，该操作不可撤销。\n"),
                          TextSpan(text: "\n"),
                          TextSpan(
                              text: "数据隐私\n",
                              style: Theme.of(context).textTheme.subtitle),
                          TextSpan(text: "\n"),
                          TextSpan(
                              text:
                                  "1、目前您的笔记数据完全存储在本地，无任何网络交互，您可以方式使用而不必担心信息泄露。\n"),
                          TextSpan(
                              text:
                                  "2、你可在列表项中右滑删除一条复习笔记，注意，删除后将永久删除，无法找回，请谨慎操作。\n"),
                        ]),
                  ),
                ),
              ),
              Center(
                child: Text(
                  "版本：V1.0.0",
                  style: Theme.of(context).textTheme.subtitle,
                ),
              ),
            ],
          ),
        ));
  }
}
