import 'package:connectivity/connectivity.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_quiz_app/screens/quiz_page.dart';

class LocalNotificationService{
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void Initialize(BuildContext context){
    final InitializationSettings initializationSettings =
        InitializationSettings(android: AndroidInitializationSettings("@mipmap/ic_launcher"));

    _notificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (String? payload) async{
        if(payload != null){
          // Navigator.pushNamed(context, '/payload',
          //     arguments: MessageArguments(message, true));
        }
    });
  }

  static void display(RemoteMessage message){
    final id = DateTime.now().millisecondsSinceEpoch ~/1000;
    final NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails("gdprquizchannel", "gdprquizchannel",
          "This is a channel for GDPR Quiz",
      importance: Importance.max, priority: Priority.high)
    );
    _notificationsPlugin.show(id, message.notification!.title, message.notification!.body,
        notificationDetails, payload: message.data["route"]);
  }
}