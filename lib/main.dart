import 'package:calling_app/config/connectycube_call_kit.dart';
import 'package:calling_app/home_page.dart';
import 'package:connectycube_sdk/connectycube_calls.dart';
// import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(MyApp());
}

/// Top level function to handle incoming messages when the app is in the background
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  initiateConnectycubeCallKit();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(willGoToVideoCallPage: false,),
    );
  }
}