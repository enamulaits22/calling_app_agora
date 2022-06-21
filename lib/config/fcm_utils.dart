
import 'dart:developer';
import 'dart:math' as math;

import 'package:calling_app/calling_screen.dart';
import 'package:calling_app/config/config.dart';
import 'package:calling_app/main.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/material.dart';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';

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

  ConnectycubeFlutterCallKit.onCallRejectedWhenTerminated = onCallRejectedWhenTerminated;
ConnectycubeFlutterCallKit.onCallAcceptedWhenTerminated = onCallAcceptedWhenTerminated;
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
    navigatorKey?.currentState?.push(MaterialPageRoute(builder: (_) => CallingScreen()));
  }

  Future<void> _onCallRejected(CallEvent callEvent) async {
    // the call was rejected
  }
  ConnectycubeFlutterCallKit.instance.init(
    onCallAccepted: _onCallAccepted,
    onCallRejected: _onCallRejected,
  );
}
Future<void> onCallAcceptedWhenTerminated(CallEvent event) async{
  
  print(
      '[PushNotificationsManager][onCallAcceptedWhenTerminated] callEvent: $event');

Future.delayed(Duration(seconds: 5,),(){
    
  navigatorKey?.currentState?.push(MaterialPageRoute(builder: (_) => CallingScreen()));
  });

  return sendPushAboutRejectFromKilledState({
    'PARAM_CALL_TYPE': event.callType,
    'PARAM_SESSION_ID': event.sessionId,
    'PARAM_CALLER_ID': event.callerId,
    'PARAM_CALLER_NAME': event.callerName,
    'PARAM_CALL_OPPONENTS': event.opponentsIds.join(','),
  }, event.callerId, event);
}



Future<void> onCallRejectedWhenTerminated(CallEvent callEvent) async {
  print(
      '[PushNotificationsManager][onCallRejectedWhenTerminated] callEvent: $callEvent');
  return sendPushAboutRejectFromKilledState({
    'PARAM_CALL_TYPE': callEvent.callType,
    'PARAM_SESSION_ID': callEvent.sessionId,
    'PARAM_CALLER_ID': callEvent.callerId,
    'PARAM_CALLER_NAME': callEvent.callerName,
    'PARAM_CALL_OPPONENTS': callEvent.opponentsIds.join(','),
  }, callEvent.callerId, callEvent);
}

Future<void> sendPushAboutRejectFromKilledState(
  Map<String, dynamic> parameters,
  int callerId,
  CallEvent callEvent
) async{
  CubeSettings.instance.applicationId = Config.APP_ID;
  CubeSettings.instance.onSessionRestore = () {
    return createSession(CubeUser(id: callerId));
  };
}
