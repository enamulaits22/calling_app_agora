import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:calling_app/calling_screen.dart';
import 'package:calling_app/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:callkeep/callkeep.dart';
import 'package:uuid/uuid.dart';

import 'helper/call_kepp_fcm_helper.dart';

/// For fcm background message handler.

final FlutterCallkeep callKeep = FlutterCallkeep();
/*
{
    "uuid": "xxxxx-xxxxx-xxxxx-xxxxx",
    "caller_id": "+8618612345678",
    "caller_name": "hello",
    "caller_id_type": "number",
    "has_video": false,

    "extra": {
        "foo": "bar",
        "key": "value",
    }
}
*/


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      debugShowCheckedModeBanner: false,
      home: CallKeepHomePage(),
    );
  }
}

class CallKeepHomePage extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class Call {
  Call(this.number);

  String number;
  bool held = false;
  bool muted = false;
}

class _MyAppState extends State<CallKeepHomePage> {
  Map<String, Call> calls = {};

  String newUUID() => Uuid().v4();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  void iOS_Permission() {
    _firebaseMessaging.requestPermission(sound: true, badge: true, alert: true);
  }

  void removeCall(String callUUID) {
    setState(() {
      calls.remove(callUUID);
    });
  }

  void setCallHeld(String callUUID, bool held) {
    setState(() {
      calls[callUUID]?.held = held;
    });
  }

  void setCallMuted(String callUUID, bool muted) {
    setState(() {
      calls[callUUID]?.muted = muted;
    });
  }

  Future<void> hangup(String callUUID) async {
    callKeep.endCall(callUUID);
    removeCall(callUUID);
  }

  Future<void> setOnHold(String callUUID, bool held) async {
    callKeep.setOnHold(callUUID, held);
    final String? handle = calls[callUUID]?.number;
    print('[setOnHold: $held] $callUUID, number: $handle');
    setCallHeld(callUUID, held);
  }

  Future<void> setMutedCall(String callUUID, bool muted) async {
    callKeep.setMutedCall(callUUID, muted);
    final String? handle = calls[callUUID]?.number;
    print('[setMutedCall: $muted] $callUUID, number: $handle');
    setCallMuted(callUUID, muted);
  }

  Future<void> updateDisplay(String callUUID) async {
    final String? number = calls[callUUID]?.number;
    // Workaround because Android doesn't display well displayName, se we have to switch ...
    if (isIOS) {
      callKeep.updateDisplay(callUUID,
          displayName: 'New Name', handle: number ?? '');
    } else {
      callKeep.updateDisplay(callUUID,
          displayName: number ?? '', handle: 'New Name');
    }

    print('[updateDisplay: $number] $callUUID');
  }


  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      //if (isIOS) iOS_Permission();
      //  _firebaseMessaging.requestNotificationPermissions();

      _firebaseMessaging.getToken().then((token) {
        print('[FCM] token => $token');
      });

      FirebaseMessaging.onMessage.listen(
        ((RemoteMessage message) {
          print('onMessage: $message');

          showCallKeepDisplay(callKeep, message);
        }),
      );
    }
  }

  Widget buildCallingWidgets() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: calls.entries
            .map((MapEntry<String, Call> item) =>
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Text('number: ${item.value.number}'),
                  Text('uuid: ${item.key}'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton(
                        onPressed: () async {
                          setOnHold(item.key, !item.value.held);
                        },
                        child: Text(item.value.held ? 'Unhold' : 'Hold'),
                      ),
                      RaisedButton(
                        onPressed: () async {
                          updateDisplay(item.key);
                        },
                        child: const Text('Display'),
                      ),
                      RaisedButton(
                        onPressed: () async {
                          setMutedCall(item.key, !item.value.muted);
                        },
                        child: Text(item.value.muted ? 'Unmute' : 'Mute'),
                      ),
                      RaisedButton(
                        onPressed: () async {
                          hangup(item.key);
                        },
                        child: const Text('Hangup'),
                      ),
                    ],
                  )
                ]))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              RaisedButton(
                onPressed: () async {
                },
                child: const Text('Display incoming call now'),
              ),
              RaisedButton(
                onPressed: () async {
                },
                child: const Text('Display incoming call now in 3s'),
              ),
              buildCallingWidgets()
            ],
          ),
        ),
      ),
    );
  }
}
