import 'dart:async';
import 'dart:math' as math;
import 'package:calling_app/calling_screen.dart';
import 'package:calling_app/main.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

StreamController<int> event = StreamController();

void initiateConnectycubeCallKit() {
  controlCall();
  math.Random random = math.Random();
  CallEvent callEvent = CallEvent(
    sessionId: random.nextInt(100).toString(),
    callType: 1, // {0 :: Audio call}; {1 :: Video Call}
    callerId: 9644,
    callerName: 'Caller Name',
    opponentsIds: {1},
    userInfo: {'customParameter1': 'value1'},
  );

  //ConnectycubeFlutterCallKit.instance.updateConfig(ringtone: 'basi_sur', icon: 'app_icon', color: '#07711e');
  
  ConnectycubeFlutterCallKit.showCallNotification(callEvent);
}

Future<void> initiateFirebase() async {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  var initialMessage = await _firebaseMessaging.getInitialMessage();

  if (initialMessage != null) {

    log('calling remote message');
  }
}

void controlCall() {
  Future<void> _onCallAccepted(CallEvent callEvent) async {
    // bool res = await DeviceApps.openApp('com.example.calling_app');
    // print(res.toString());

    // if (res) {
    //   Future.delayed(Duration(seconds: 2), (){
    //     navigatorKey?.currentState?.push(MaterialPageRoute(builder: (_) => CallingScreen()));
    //   });
    // }
    log('hurra:'+navigatorKey.currentState.toString());

    navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => CallingScreen()));
  }

  Future<void> _onCallRejected(CallEvent callEvent) async {
    // the call was rejected
  }
  
  ConnectycubeFlutterCallKit.instance.init(
    onCallAccepted: _onCallAccepted,
    onCallRejected: _onCallRejected,
  );
}

Future<void> onCallAcceptedWhenTerminated(CallEvent callEvent) async{
  event.sink.add(1);
  navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => CallingScreen()));
  log(callEvent.callerName);
}
