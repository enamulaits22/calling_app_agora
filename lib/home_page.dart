import 'package:calling_app/calling_screen.dart';
import 'package:calling_app/config/fcm_utils.dart';
import 'package:calling_app/helper/devices.dart';
import 'package:calling_app/main.dart';
import 'package:calling_app/services/fcm_service.dart';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:connectycube_sdk/connectycube_core.dart';
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
    getFirebaseToken();
    foregroundMode();
    initializeConnectyCube();
    super.initState();
  }

  void initializeConnectyCube() {
    ConnectycubeFlutterCallKit.getToken().then((token) {
      log('::::::::::::::::::::::::::::::::Token: $token');
      setState(() {
        fcmToken = token;
      });
      // use received token for subscription on push notifications on your server
    });

    ConnectycubeFlutterCallKit.onTokenRefreshed = (token) {
      log('::::::::::::::::::::::::::::::::Refresh Token: $token');
      // use refreshed token for resubscription on your server
    };

    ConnectycubeFlutterCallKit.instance.init(
      onCallAccepted: _onCallAccepted,
      onCallRejected: _onCallRejected,
    );
  }

  Future<void> _onCallAccepted(CallEvent callEvent) async {
    navigatorKey?.currentState
        ?.push(MaterialPageRoute(builder: (_) => CallingScreen()));
  }

  Future<void> _onCallRejected(CallEvent callEvent) async {
    // the call was rejected
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
                return Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      final token = ListOfDevices.fcmList[index]['token']
                          .toString();
                      log('tokendfdf' + token);
                      bool isRequestSuccessful = await fcmService
                          .sendCallRequest('$token');
                      if (isRequestSuccessful) {
                        navigatorKey?.currentState?.push(MaterialPageRoute(
                            builder: (_) => CallingScreen()));
                        }
                        },
                    child: Text(
                        ListOfDevices.fcmList[index]['name'].toString()),
                  ),
                );
              }),
        )
    );
  }
}
