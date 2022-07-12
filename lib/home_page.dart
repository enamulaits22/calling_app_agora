// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer';

import 'package:calling_app/config/utils/sp_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:calling_app/calling_screen.dart';
import 'package:calling_app/services/setup_call_service.dart';
import 'package:calling_app/main.dart';
import 'package:calling_app/services/fcm_service.dart';

import 'config/config.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.userDocumentsId}) : super(key: key);

  final String userDocumentsId;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? fcmToken = '';
  String? fcmTitle = '';
  FCMService fcmService = FCMService();
  CollectionReference collectionStream = FirebaseFirestore.instance.collection('users');
  late String userEmail;

  @override
  void initState() {
    // getFirebaseToken();
    foregroundMode();
    getFcmToken();
    navigateToCallingPageFromBackground();
    super.initState();
  }

  void getFcmToken() async{
     userEmail = (await SharedPref.getValueFromShrprs(Config.userEmail,))!;

    ConnectycubeFlutterCallKit.getToken().then((token) {
      log('FCM Token: $token');
      setState(() {
        fcmToken = token;
      });
    });
  }

  void foregroundMode() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // RemoteNotification? notification = message.notification;
      // AndroidNotification? android = message.notification?.android;
      // if (notification != null && android != null) {
      //   initiateCall();
      // }
      log(':::::::::::::::::::::::::::Triggered from foreground');
      String userName = message.notification!.title!;
      initiateCall(userName);
    });
  }

  Future<void> navigateToCallingPageFromBackground() async {
    final status = await SharedPref.getValueFromShrprs(Config.callStatus);
    final callerName = await SharedPref.getValueFromShrprs(Config.callerName);
    log(status.toString());
    if (status.toString() == 'success') {
      Future.delayed(Duration(seconds: 0), () {
        navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => CallingScreen(userName: callerName!)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Call App'),
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: collectionStream.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              return ListView.builder(
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot = streamSnapshot.data!.docs[index];

                  final isSameUser = userEmail == documentSnapshot['email'];

                  return isSameUser ? SizedBox.shrink() : Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text(documentSnapshot['email']),
                      subtitle: Text(documentSnapshot['hasReceiverRejectedCall'].toString()),
                      onTap: () async {
                        final token = documentSnapshot['token'];
                        print('tokendfdf' + token);
                        print('documnetsId: ${streamSnapshot.data!.docs[index].id}');
                        
                        bool isRequestSuccessful = await fcmService.sendCallRequest(
                          fcmToken: '$token',
                          callerName: userEmail,
                        );

                        if (isRequestSuccessful) {
                          navigatorKey.currentState?.push(
                            MaterialPageRoute(
                              builder: (_) => CallingScreen(
                                documentsId: documentSnapshot.id,
                                userName: documentSnapshot['email'],
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
