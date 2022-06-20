import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:math';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:connectycube_sdk/connectycube_calls.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
  playSound: true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void initiateCall() {
    Random random = Random();
    CallEvent callEvent = CallEvent(
      sessionId: random.nextInt(100).toString(),
      callType: CallType.AUDIO_CALL,
      callerId: 9644,
      callerName: 'Enamul',
      opponentsIds: {1},
      userInfo: {'customParameter1': 'value1'},
    );
    ConnectycubeFlutterCallKit.instance.updateConfig(ringtone: 'basi_sur', icon: 'app_icon', color: '#07711e');
    
    ConnectycubeFlutterCallKit.showCallNotification(callEvent);
  }