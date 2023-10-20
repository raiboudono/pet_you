import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:math' as math;
// import 'dart:typed_data';

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> init() async {
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('cat'),
    ),
    /*フォアグラウンドでの、通知 UI またはアクションをタップした時の処理
     */
    onDidReceiveNotificationResponse: (NotificationResponse res) {
      print(res.notificationResponseType);
      print(res.id);
      print(res.actionId);
      print(res.input);
      print(res.payload);
    },
    /* バックグラウンドでの、通知 UI またはアクションをタップした時の処理 */
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation("Asia/Tokyo"));
}

/*VMのコード削減に巻き込まれないようアノテーション */
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  if (notificationResponse.id == 0 && notificationResponse.actionId == 'id_0') {
    /* todo: おそらくバックグラウンドの1つとして pending がある
    リピートやスケジュールの場合 pending になるので、作動する
    しかし普通の通知などは通知して終了のため場合でないので作動しない
    */

    print('リピート通知を止めました');
    flutterLocalNotificationsPlugin.cancel(notificationResponse.id!);
  }
}

class LocalNotification {
  // minute で通知可能か validate
  tz.TZDateTime? getReminderTime(int minute, DateTime startTime) {
    final now = DateTime.now();
    final subtractedTime = startTime.subtract(Duration(minutes: minute));

    if (now.isBefore(subtractedTime)) {
      return tz.TZDateTime.from(subtractedTime, tz.local);
    }
    return null;
  }

  // 普通の通知
  Future<void> showNotificationWithActions() async {
    /*todo: チャネルとは通知ごとに ON OFF ができる項目のことなので分けておいた方がよい*/
    const androidNotificationDetails = AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      // importance: Importance.max,
      color: Colors.blueAccent,
      actions: [
        AndroidNotificationAction(
          'id_1',
          'Action 1',
          titleColor: Colors.blue,
          showsUserInterface: true,
        ),
      ],
    );

    await flutterLocalNotificationsPlugin
        // 上書きを防ぐため通知ごとにユニークなidにする
        .show(1, 'title', 'hello raian!',
            const NotificationDetails(android: androidNotificationDetails),
            payload: 'タップした時にアプリ側に渡される値');
  }

// スケジュール通知
  Future<void> schedule(tz.TZDateTime tzDateTime, int id,
      {required bool dayOfWeekAndTime}) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      '事前通知',
      '',
      tzDateTime,
      // 通知後も同一曜日同一時刻に定期通知 (pending が残り続ける)
      payload: tzDateTime.toIso8601String(),
      matchDateTimeComponents:
          dayOfWeekAndTime ? DateTimeComponents.dayOfWeekAndTime : null,

      // tz.TZDateTime.now(tz.local).add(Duration(minutes: minutes)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your channel id', '繰り返し',
          // ongoing: true,  //タップしても通知を表示し続ける
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // RepeatInterval (繰り返し)
  Future<void> repeatNotification() async {
    const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
            'repeating channel id', 'repeating channel name',
            channelDescription: 'repeating description',
            subText: '繰り返し',
            importance: Importance.max,
            actions: [
          AndroidNotificationAction(
            'id_0',
            '通知を止める',
          )
        ]));

    await flutterLocalNotificationsPlugin.periodicallyShow(
        0,
        '',
        '',
        //  (毎分、毎時間、毎日、毎週)
        RepeatInterval.everyMinute,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'repeat');
  }

  /*予約状態 (pending)確認 */
  Future<List<PendingNotificationRequest>>
      getPendingNotificationRequests() async {
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    return pendingNotificationRequests;
  }

  Future<int> getCreateId() async {
    final id = math.Random().nextInt(100000) + 100000;
    final requests = await getPendingNotificationRequests();
    final isCreated = requests.map((e) => e.id).contains(id);
    if (isCreated) {
      return await getCreateId();
    }
    return id;
  }

  // キャンセル (pending を破棄)
  Future<void> cancelNotifications(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // キャンセルオール id 指定不要でキャンセル
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
