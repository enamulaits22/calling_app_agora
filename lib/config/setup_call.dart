import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:calling_app/calling_screen.dart';
import 'package:calling_app/main.dart';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:flutter/material.dart';

// StreamController<int> event = StreamController<int>.broadcast();
void initiateCall() {
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

  ConnectycubeFlutterCallKit.instance.updateConfig(ringtone: 'basi_sur', icon: 'app_icon', color: '#07711e');
  
  ConnectycubeFlutterCallKit.showCallNotification(callEvent);
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
    log(':::::::::::::::::::::::::::::::::::::::::');
    log(navigatorKey.toString());
    // event.sink.add(1);
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
