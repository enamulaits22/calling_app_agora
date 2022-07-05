import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:calling_app/calling_screen.dart';
import 'package:calling_app/config/utils/sp_utils.dart';
import 'package:calling_app/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

math.Random random = math.Random();

CallEvent callEvent = CallEvent(
  sessionId: random.nextInt(100).toString(),
  callType: 1, // {0 :: Audio call}; {1 :: Video Call}
  callerId: 9644,
  callerName: 'Caller Name',
  opponentsIds: {1},
  userInfo: {'customParameter1': 'value1'},
);
void initiateCall() {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  controlCall();
  //ConnectycubeFlutterCallKit.instance.updateConfig(ringtone: 'basi_sur', icon: 'app_icon', color: '#07711e');
  
  ConnectycubeFlutterCallKit.showCallNotification(callEvent);
  ConnectycubeFlutterCallKit.reportCallEnded(sessionId: callEvent.sessionId);

  final User? _firebaseUser = FirebaseAuth.instance.currentUser;

  users.doc(_firebaseUser!.uid).snapshots().listen((event) {
    if (event.data() != null) {
      final e = event.data() as Map<String, dynamic>;
      print('sdsd sdsd: ${e['hasCallerEndCall']}');
      if (e['hasCallerEndCall'] == 'true') {

      }
    }
  });

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
    final service = FlutterBackgroundService();
    SharedPref.setCallStatus('reset');

    await Firebase.initializeApp().then((value){
      CollectionReference users = FirebaseFirestore.instance.collection('users');

      final User? _firebaseUser = FirebaseAuth.instance.currentUser;
      users
          .doc('${_firebaseUser!.uid}')
          .update({
        'hasReceiverRejectedCall': 'true'
      })
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error"));
    });

    service.invoke("stopService"); //:::::::::::::::::::::::::::stopped background service
  }
  
  ConnectycubeFlutterCallKit.instance.init(
    onCallAccepted: _onCallAccepted,
    onCallRejected: _onCallRejected,
  );
}
