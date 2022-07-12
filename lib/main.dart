import 'package:calling_app/config/utils/sp_utils.dart';
import 'package:calling_app/home_page.dart';
import 'package:calling_app/pages/authentication/login_page.dart';
import 'package:calling_app/services/setup_call_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

import 'dart:async';

import 'config/config.dart';
import 'services/setup_background_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  await initializeBackgroundService();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

/// Top level function to handle incoming call when the app is in the background
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  String? callerName = message.notification!.title;
  final service = FlutterBackgroundService();
  service.startService(); //:::::::::::::::::::::::::::starting background service
  SharedPref.saveValueToShaprf(Config.callStatus, 'success');
  SharedPref.saveValueToShaprf(Config.callerName, callerName!);
  initiateCall(callerName);

  await Firebase.initializeApp().then((value){
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    users.doc('d0Wj8uWrL1fvwos7umA55sfWxET2').get().then((value){
      final e = value.data() as Map<String, dynamic>;
      print('sdsd: ${e['email']}');
    });
  });

}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final service = FlutterBackgroundService();
  final User? _firebaseUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    service.invoke("stopService"); //:::::::::::::::::::::::::::stopped background service
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _firebaseUser?.uid != null
        ? MyHomePage(userDocumentsId: _firebaseUser!.uid)
        : AuthenticationPage(),
    );
  }
}
