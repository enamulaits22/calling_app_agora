import 'dart:async';
import 'dart:developer';

import 'package:callkeep/callkeep.dart';
import 'package:connectycube_sdk/connectycube_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../call_keep_flutter.dart';
import '../calling_screen.dart';
import '../main.dart';


bool _callKeepInited = false;

void showCallKeepDisplay(FlutterCallkeep callKeep, RemoteMessage message) {

  callKeep.on(CallKeepDidDisplayIncomingCall(), didDisplayIncomingCall);
  callKeep.on(CallKeepPerformAnswerCallAction(), answerCall);
  callKeep.on(CallKeepDidPerformDTMFAction(), didPerformDTMFAction);
  callKeep.on(CallKeepDidReceiveStartCallAction(), didReceiveStartCallAction);
  callKeep.on(CallKeepPerformEndCallAction(), endCall);
  callKeep.on(CallKeepPushKitToken(), onPushKitToken);

  callKeep.setup(null, <String, dynamic>{
    'ios': {
      'appName': 'CallKeepDemo',
    },
    'android': {
      'alertTitle': 'Permissions required',
      'alertDescription':
          'This application needs to access your phone accounts',
      'cancelButton': 'Cancel',
      'okButton': 'ok',
      'foregroundService': {
        'channelId': 'com.company.my',
        'channelName': 'Foreground service for my app',
        'notificationTitle': 'My app is running on background',
        'notificationIcon': 'Path to the resource icon of the notification',
      },
    },
  });

  if (message.data.isNotEmpty) {
    // Handle data message

    var payload = message.data;
    var callerId = payload['caller_id'] as String;
    var callerName = payload['caller_name'] as String;
    var uuid = payload['uuid'] as String;
    var hasVideo = payload['has_video'] == "true";
    final callUUID = uuid;

    callKeep.displayIncomingCall(callUUID, callerId,
        localizedCallerName: callerName, hasVideo: hasVideo);
    log('hurra: ${callerName}');
  }
}


void onPushKitToken(CallKeepPushKitToken event) {
  print('[onPushKitToken] token => ${event.token}');
}

Future<void> didPerformDTMFAction(CallKeepDidPerformDTMFAction event) async {
  print('[didPerformDTMFAction] ${event.callUUID}, digits: ${event.digits}');
}

Future<void> endCall(CallKeepPerformEndCallAction event) async {
  log('endCall: ${event.callUUID}');
  callKeep.endCall(event.callUUID!);
}


Future<void> didReceiveStartCallAction(
    CallKeepDidReceiveStartCallAction event) async {
  if (event.handle == null) {
    // @TODO: sometime we receive `didReceiveStartCallAction` with handle` undefined`
    return;
  }
  final String callUUID = event.callUUID ?? 'newUUID()';
  print('[didReceiveStartCallAction] $callUUID, number: ${event.handle}');

  callKeep.startCall(callUUID, event.handle ?? '', event.handle ?? '');

  Timer(const Duration(seconds: 1), () {
    print('[setCurrentCallActive] $callUUID, number: ${event.handle}');
    callKeep.setCurrentCallActive(callUUID);
  });
}

Future<void> answerCall(CallKeepPerformAnswerCallAction event) async {

  final String? callUUID = event.callUUID;
  log('[answerCall] $callUUID, number: ');

  callKeep.endCall(callUUID!);

  Timer(const Duration(seconds: 1), () {
    log('[setCurrentCallActive] $callUUID, number: ');
    //callKeep.setCurrentCallActive(callUUID!);

    navigatorKey.currentState
        ?.push(MaterialPageRoute(builder: (context) => CallingScreen()));
  });
}

void didDisplayIncomingCall(CallKeepDidDisplayIncomingCall event) {
  var callUUID = event.callUUID;
  var number = event.handle;
  print('[displayIncomingCall] $callUUID number: $number');

}

Future<dynamic>? myBackgroundMessageHandler(Map<String, dynamic> message) {
  print('backgroundMessage: message => ${message.toString()}');
  var payload = message['data'];
  var callerId = payload['caller_id'] as String;
  var callerName = payload['caller_name'] as String;
  var uuid = payload['uuid'] as String;
  var hasVideo = payload['has_video'] == "true";

  final callUUID = uuid;
  callKeep.on(CallKeepPerformAnswerCallAction(),
          (CallKeepPerformAnswerCallAction event) {
        print(
            'backgroundMessage: CallKeepPerformAnswerCallAction ${event.callUUID}');
        Timer(const Duration(seconds: 1), () {
          print(
              '[setCurrentCallActive] $callUUID, callerId: $callerId, callerName: $callerName');
          callKeep.setCurrentCallActive(callUUID);
        });
        //_callKeep.endCall(event.callUUID);
      });

  callKeep.on(CallKeepPerformEndCallAction(),
          (CallKeepPerformEndCallAction event) {
        print('backgroundMessage: CallKeepPerformEndCallAction ${event.callUUID}');
      });

  print('backgroundMessage: displayIncomingCall ($callerId)');
  callKeep.displayIncomingCall(callUUID, callerId,
      localizedCallerName: callerName, hasVideo: hasVideo);
  callKeep.backToForeground();
  /*

  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
    print('notification => ${notification.toString()}');
  }

  // Or do other work.
  */
  return null;
}
