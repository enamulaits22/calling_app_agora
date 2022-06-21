import 'package:calling_app/calling_screen.dart';
import 'package:calling_app/config/fcm_utils.dart';
import 'package:calling_app/helper/devices.dart';
import 'package:calling_app/main.dart';
import 'package:calling_app/services/fcm_service.dart';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({ Key? key }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? fcmToken = '';
  String? fcmTitle = '';
  FCMService fcmService = FCMService();

  @override
  void initState() {
    // getFirebaseToken();
    foregroundMode();
    initializeConnectyCube();
    super.initState();
  }

  void initializeConnectyCube() {
    ConnectycubeFlutterCallKit.getToken().then((token) {
      log('FCM Token: $token');
      setState(() {
        fcmToken = token;
      });
      });
  }

  void foregroundMode() async{
    final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    var initialMessage = await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        initiateCall();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Call App'),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: ListOfDevices.fcmList.length,
          itemBuilder: (context, index) {
            final token = ListOfDevices.fcmList[index]['token'].toString();
            return Center(
              child: token == fcmToken ? Container() : ElevatedButton(
                onPressed: () async {
                  log('tokendfdf' + token);
                  bool isRequestSuccessful = await fcmService.sendCallRequest('$token');
                  if (isRequestSuccessful) {
                    navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => CallingScreen()));
                  }
                },
                child: Text(ListOfDevices.fcmList[index]['name'].toString()),
              ),
            );
          },
        ),
      )
    );
  }

  void _handleMessage(RemoteMessage initialMessage) {
    log('calling remote message');
  }
}