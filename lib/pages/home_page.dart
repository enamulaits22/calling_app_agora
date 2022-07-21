// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:calling_app/config/utils/sp_utils.dart';
import 'package:calling_app/main.dart';
import 'package:calling_app/pages/calling_screen.dart';
import 'package:calling_app/services/fcm_service.dart';
import 'package:calling_app/services/setup_call_service.dart';

import '../config/config.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? fcmToken = '';
  String? fcmTitle = '';
  FCMService fcmService = FCMService();
  CollectionReference collectionStream = FirebaseFirestore.instance.collection('users');
  late String userPhoneNo;
  String callerName = '';
  String callerImage = '';
  String callType = '';
  String currentUserName = '';
  String currentUserPhoto = '';
  List<ContactModel> contactsList = [];
  bool isLoading = true;

  @override
  void initState() {
    // getFirebaseToken();
    foregroundMode();
    getFcmToken();
    getUserInitialData();
    navigateToCallingPageFromBackground();
    getAndFilterContactList();
    super.initState();
  }

  Future<void> getUserInitialData() async {
    collectionStream.doc(FirebaseAuth.instance.currentUser!.uid).snapshots().listen((event) {
      currentUserName = event['userName'];
      currentUserPhoto = event['profilePicture'];
    });
  }

  void getFcmToken() async{
     userPhoneNo = (await SharedPref.getValueFromShrprs(Config.userPhoneNumber))!;

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
      callerName = message.notification!.title!;
      callType = message.data['call_type'];
      callerImage = message.data['caller_image'];
      initiateCall(callerName, callType, callerImage);
    });
  }

  Future<void> navigateToCallingPageFromBackground() async {
    final status = await SharedPref.getValueFromShrprs(Config.callStatus);
    final callerNameSp = await SharedPref.getValueFromShrprs(Config.callerName);
    final callerImageSp = await SharedPref.getValueFromShrprs(Config.callerImage);
    final callTypeSp = await SharedPref.getValueFromShrprs(Config.callType);
    log(status.toString());
    if (status.toString() == 'success') {
      Future.delayed(Duration(seconds: 0), () {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => CallingScreen(
            userName: callerNameSp!,
            userPhoto: callerImageSp!,
            callType: callTypeSp!,
          )),
        );
      });
    }
  }

  Future<void> getAndFilterContactList() async {
    await [Permission.contacts].request();
    List<Contact> contacts = await ContactsService.getContacts();
    log('::::::::::::::::::::::::::::::Total Contacts Found: ${contacts.length}');
    for (int index = 0; index < contacts.length; index++) {
      if (contacts[index].phones!.isNotEmpty) {
        String name = contacts[index].displayName!;
        contacts[index].phones!.map((e) {
          log(e.value!);
        });
        contacts[index].phones!.map((data) {
          // log('==============$index: $name');
          var phoneNumber = '+88' + data.value!.replaceAll("+88", "").replaceAll("-", "", ).replaceAll(" ", "");
          log('++++++++++++++++++${contacts[index].displayName!}::: $phoneNumber');
          setState(() {
            contactsList.add(ContactModel(name: name, phoneNumber: phoneNumber));
            isLoading = false;
          });
          return data;
        }).toList();
        // String number = contacts[index].phones![0].value!;
        // var phoneNumber = '+88' + number.replaceAll("+88", "").replaceAll("-", "", ).replaceAll(" ", "");
        // log('::::::::::::::::::::::::::::::$phoneNumber');
        // setState(() {
        //   contactsList.add(ContactModel(name: name, phoneNumber: phoneNumber));
        //   isLoading = false;
        // });
      }      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Call App'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: collectionStream.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
              shrinkWrap: true,
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot = streamSnapshot.data!.docs[index];
                // log(documentSnapshot.data().toString());

                final isSameUser = userPhoneNo == documentSnapshot['phoneNumber'];
                final hasNumberSaved = contactsList.any((element) => element.phoneNumber.contains(documentSnapshot['phoneNumber']));
                final contaclListIndex = contactsList.indexWhere((element) => element.phoneNumber == documentSnapshot['phoneNumber']);
                // log(contaclListIndex.toString());
                String userName = contactsList[contaclListIndex].name;
                return (isSameUser || !hasNumberSaved) ? SizedBox.shrink() : Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    minLeadingWidth : 10,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                    // title: Text(documentSnapshot['userName']),
                    title: Text(userName),
                    subtitle: Text(documentSnapshot['phoneNumber']),
                    leading: ClipOval(
                      child: SizedBox.fromSize(
                        size: Size.fromRadius(22), // Image radius
                        child: Image.network(documentSnapshot['profilePicture'], fit: BoxFit.cover),
                      ),
                    ),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              await handleCall(documentSnapshot, 'video', userName);
                            },
                            icon: Icon(Icons.videocam, color: Colors.green,),
                          ),
                          IconButton(
                            onPressed: () async {
                              await handleCall(documentSnapshot, 'audio', userName);
                            },
                            icon: Icon(Icons.phone, color: Colors.green,),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<void> handleCall(DocumentSnapshot<Object?> documentSnapshot, String callType, String calledUserName) async {
    final token = documentSnapshot['token'];
    print('tokendfdf' + token);

    bool isRequestSuccessful = await fcmService.sendCallRequest(
      fcmToken: '$token',
      callerName: currentUserName,
      callerImage: currentUserPhoto,
      callType: callType,
    );
    
    if (isRequestSuccessful) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => CallingScreen(
            documentsId: documentSnapshot.id,
            // userName: documentSnapshot['userName'],
            userName: calledUserName,
            userPhoto: documentSnapshot['profilePicture'],
            callType: callType,
          ),
        ),
      );
    }
  }
}


class ContactModel {
  String name;
  String phoneNumber;
  ContactModel({
    required this.name,
    required this.phoneNumber,
  });
}
