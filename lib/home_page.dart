import 'package:calling_app/config/fcm_utils.dart';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({ Key? key }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? fcmToken = '';
  String? fcmTitle = '';

  @override
  void initState() {
    getFirebaseToken();
    foregroundMode();
    backgroundMode();
    initializeConnectyCube();
    super.initState();
  }

  void initializeConnectyCube() {
    ConnectycubeFlutterCallKit.getToken().then((token) {
      log('::::::::::::::::::::::::::::::::Token: $token');
      // use received token for subscription on push notifications on your server
    });

    ConnectycubeFlutterCallKit.onTokenRefreshed = (token) {
      log('::::::::::::::::::::::::::::::::Refresh Token: $token');
      // use refreshed token for resubscription on your server
    };
  }

  Future<void> getFirebaseToken() async {
    fcmToken = await FirebaseMessaging.instance.getToken();
    log('Token: $fcmToken');
  }

  void foregroundMode() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        log(notification.title!);
        log(message.from!);
        setState(() {
          fcmTitle = notification.title;
        });
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
              color: Colors.blue,
              playSound: true,
              icon: '@mipmap/ic_launcher',
            ),
          ));
        initiateCall();
      }
    });
  }

  //works when app is in background mode and user taps on the notification
  void backgroundMode() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        log(notification.body!);
        setState(() {
          fcmTitle = notification.title;
        });
        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text(notification.title!),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(notification.body!)],
                ),
              ),
            );
          });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Call App'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => CallingScreen()),
            // );
          },
          child: Text('Call'),
        ),
      ),
    );
  }
}