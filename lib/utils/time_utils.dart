class TimeUtils {
  ///几分钟前
  static String ugcTime(int timeStamp) {
    int currentTimeStamp = new DateTime.now().millisecondsSinceEpoch ~/ 1000;
    DateTime format = new DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);

    int between = (currentTimeStamp - timeStamp); //8*60*60这个是为了处理时区问题
    int day = between ~/ (24 * 3600);

    int hour = (between % (24 * 3600) ~/ 3600);

    int minute = (between % 3600 ~/ 60);

    int second = between % 60;

    String result = "";

    if (day > 14) {
      result =
          "${format.year}-${format.month}-${format.day} ${format.hour < 10 ? "0${format.hour}" : format.hour}:${format.minute < 10 ? "0${format.minute}" : format.minute}";
    } else if (day <= 14 && day > 0) {
      result = "$day天前";
    } else if (hour > 0) {
      result = "${hour.toInt()}小时前";
    } else if (minute > 0) {
      result = "${minute.toInt()}分钟前";
    } else if (second > 0) {
      result = "${second.toInt()}秒前";
    } else {
      return "刚刚";
    }

    return result;
  }

  ///几天后
  static String timeToNow(int timeStamp) {
    int currentTimeStamp = new DateTime.now().millisecondsSinceEpoch ~/ 1000;

    int between = (timeStamp - currentTimeStamp); //8*60*60这个是为了处理时区问题

    int day = between ~/ (24 * 3600);

    int hour = (between % (24 * 3600) ~/ 3600);

    int minute = (between % 3600 ~/ 60);

    int second = between % 60;

    String result = "";

    if (day > 0) {
      result = "$day天后";
    } else if (hour > 0) {
      result = "$hour小时后";
    } else if (minute > 0) {
      result = "$minute分钟后";
    } else if (second > 0) {
      result = "$second秒后";
    } else {
      return "马上";
    }

    return result;
  }
}
