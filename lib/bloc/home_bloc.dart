import 'package:flutter/material.dart';
import 'package:inote/bloc/bloc_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:inote/note_detail.dart';
import 'package:inote/persistence/remind_provider.dart';

class HomeBloc extends BlocBase {
  final BuildContext _buildContext;

  RemindProvider _remindProvider;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  HomeBloc(this._buildContext);

  @override
  void dispose() {
    // TODO: implement dispose
  }

  @override
  void initState() {
    // TODO: implement initState
    _initNotification();
    _remindProvider = RemindProvider();
  }

  Future _initNotification() async {
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  ///艾宾浩斯遗忘周期提醒
  Future showNotifyPeriodically({int noteId, String title, String body}) async {
    int initRemindId = await _remindProvider.getMaxNotifyId();

    //todo  周期提醒，这个周期
    List<Remind> list = List();
    initRemindId++;
    list.add(
        Remind(noteId: noteId, notifyId: initRemindId, time: 10, done: false));
    initRemindId++;
    list.add(
        Remind(noteId: noteId, notifyId: initRemindId, time: 20, done: false));
    initRemindId++;
    list.add(
        Remind(noteId: noteId, notifyId: initRemindId, time: 30, done: false));
    initRemindId++;
    list.add(
        Remind(noteId: noteId, notifyId: initRemindId, time: 40, done: false));
    initRemindId++;
    list.add(
        Remind(noteId: noteId, notifyId: initRemindId, time: 50, done: false));

    for (var remind in list) {
      remind = await _remindProvider.insert(remind);
      print('插入提醒成功,$remind');
      var scheduledNotificationDateTime =
          new DateTime.now().add(new Duration(seconds: remind.time));
      var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
          '404', 'inote remind', 'it is time for you to remind your note now');
      var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
      NotificationDetails platformChannelSpecifics = new NotificationDetails(
          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.schedule(remind.notifyId, title,
          body, scheduledNotificationDateTime, platformChannelSpecifics);
    }
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    await Navigator.push(
      _buildContext,
      new MaterialPageRoute(builder: (context) => new NoteDetail()),
    );
  }
}
