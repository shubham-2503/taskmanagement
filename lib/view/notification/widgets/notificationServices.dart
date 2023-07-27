import 'dart:async';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices{
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  StreamController<RemoteMessage> messageStreamController = StreamController<RemoteMessage>.broadcast();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();
  Stream<RemoteMessage> get notificationStream => messageStreamController.stream;

  void requestNotification() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      print("User granted permmission");
    }else if(settings.authorizationStatus == AuthorizationStatus.provisional){
      print("User granted provisional permmission");
    }else{
      print("User denied  permmission");
    }
  }

  void initLocalnotification(BuildContext context,RemoteMessage message) async{
    final AndroidInitializationSettings androidInitalizationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitalizationSettings = DarwinInitializationSettings();

    var initalizationSetting = InitializationSettings(
      android: androidInitalizationSettings,
      iOS:iosInitalizationSettings,
    );

    await _flutterLocalNotificationPlugin.initialize(
        initalizationSetting,
        onDidReceiveNotificationResponse: (payload){
        }
    );
  }

  void firebaseinit(BuildContext context){
    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        print(message.notification!.title.toString());
        print(message.notification!.body.toString());
        print(message.data.toString());
        print(message.data["type"]);
        print(message.data["id"]);
      }

      // if(Platform.isAndroid){
      initLocalnotification(context, message);
      // }else {
      showNotification(message );
      // }
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      Random.secure().nextInt(10000).toString(),
      "High Importance Notification",
      importance: Importance.max,
    );

    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      channel.id.toString(),
      channel.name.toString(),
      channelDescription: "Your channel Description",
      importance: Importance.high,
      priority: Priority.high,
      ticker: "ticker",
    );

    DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );

    await _flutterLocalNotificationPlugin.show(
      0,
      message.notification!.title,
      message.notification!.body,
      notificationDetails,
      payload: 'Notification',
    );
  }


  Future<String?> getDeviceToken() async{
    String? token =await messaging.getToken() as String?;
    return token;
  }

  void isTokenRefresh() async{
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      print("refresh");
    });
  }

  Future<void> setupInteractMessage(BuildContext context) async{

    //When app is terminated
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if(initialMessage !=null){
      // handleMessage(context, initialMessage);
    }

    //When app is in background but opened and user taps
    //on the notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
    });
  }

// void handleMessage(BuildContext context, RemoteMessage message) {
//   if (message.data['type'] == 'msj') {
//     // Redirect to the NotificationScreen
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => NotificationPanel(
//         id: message.data['id'],
//       )),
//     );
//   }
// }
}