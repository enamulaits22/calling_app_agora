import 'dart:async';
import 'dart:developer';

import 'package:calling_app/models/contact_model.dart';
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

class _MyHomePageState extends State<MyHomePage>
    with AutomaticKeepAliveClientMixin {
  String? fcmToken = '';
  String? fcmTitle = '';
  FCMService fcmService = FCMService();
  CollectionReference collectionStream =
      FirebaseFirestore.instance.collection('users');
  late String userPhoneNo;
  String callerName = '';
  String callerImage = '';
  String callType = '';
  String currentUserName = '';
  String currentUserPhoto = '';
  bool isDisableCallingButton = false;
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

  void getUserInitialData() {
    collectionStream
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .listen((event) {
      if (event.exists) {
        currentUserName = event['userName'];
        currentUserPhoto = event['profilePicture'];
      }
    });
  }

  void getFcmToken() async {
    userPhoneNo =
        (await SharedPref.getValueFromShrprs(Config.userPhoneNumber))!;

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
    final callerImageSp =
        await SharedPref.getValueFromShrprs(Config.callerImage);
    final callTypeSp = await SharedPref.getValueFromShrprs(Config.callType);
    log(status.toString());
    if (status.toString() == 'success') {
      Future.delayed(Duration(seconds: 0), () {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
              builder: (_) => CallingScreen(
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
        contacts[index].phones!.map((data) {
          // log('==============$index: $name');
          var phoneNumber = '+88' +
              data.value!
                  .replaceAll("+88", "")
                  .replaceAll(
                    "-",
                    "",
                  )
                  .replaceAll(" ", "");
          log('++++++++++++++++++${contacts[index].displayName!}::: $phoneNumber');
          setState(() {
            contactsList
                .add(ContactModel(name: name, phoneNumber: phoneNumber));
            isLoading = false;
          });
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
                      final DocumentSnapshot documentSnapshot =
                          streamSnapshot.data!.docs[index];
                      // log(documentSnapshot.data().toString());

                      final isSameUser =
                          userPhoneNo == documentSnapshot['phoneNumber'];
                      final hasNumberSaved = contactsList.any((element) =>
                          element.phoneNumber
                              .contains(documentSnapshot['phoneNumber']));
                      final contaclListIndex = contactsList.indexWhere(
                          (element) =>
                              element.phoneNumber ==
                              documentSnapshot['phoneNumber']);
                      // log(contaclListIndex.toString());
                      // String userName = contactsList[contaclListIndex].name;
                      return (isSameUser || !hasNumberSaved)
                          ? SizedBox.shrink()
                          : Card(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: ListTile(
                                minLeadingWidth: 10,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                visualDensity:
                                    VisualDensity(horizontal: -4, vertical: -4),
                                // title: Text(documentSnapshot['userName']),
                                title:
                                    Text(contactsList[contaclListIndex].name),
                                subtitle: Text(documentSnapshot['phoneNumber']),
                                leading: ClipOval(
                                  child: SizedBox.fromSize(
                                    size: Size.fromRadius(22), // Image radius
                                    child: Image.network(
                                        documentSnapshot['profilePicture'],
                                        fit: BoxFit.cover),
                                  ),
                                ),
                                trailing: SizedBox(
                                  width: 100,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: !isDisableCallingButton
                                            ? () async {
                                                await handleCall(
                                                  documentSnapshot,
                                                  'video',
                                                  contactsList[contaclListIndex]
                                                      .name,
                                                  isReceiverInCall:
                                                      documentSnapshot[
                                                          'isReceiverInCall'],
                                                );
                                              }
                                            : null,
                                        icon: Icon(
                                          Icons.videocam,
                                          color: Colors.green,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: !isDisableCallingButton
                                            ? () async {
                                                await handleCall(
                                                  documentSnapshot,
                                                  'audio',
                                                  contactsList[contaclListIndex]
                                                      .name,
                                                  isReceiverInCall:
                                                      documentSnapshot[
                                                          'isReceiverInCall'],
                                                );
                                              }
                                            : null,
                                        icon: Icon(
                                          Icons.phone,
                                          color: Colors.green,
                                        ),
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

  Future<void> handleCall(DocumentSnapshot<Object?> documentSnapshot,
      String callType, String calledUserName,
      {required String isReceiverInCall}) async {
    if (isReceiverInCall == 'true') {
      showReceiverIsAnotherCallToast(calledUserName);
    } else {
      final token = documentSnapshot['token'];
      print('tokendfdf' + token);

      setState(() {
        isDisableCallingButton = true;
      });

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

      Future.delayed(Duration(seconds: 1), (){
        setState(() {
          isDisableCallingButton = false;
        });
      });
    }
  }

  void showReceiverIsAnotherCallToast(
      String calledUserName) {
    final snackBar = SnackBar(
      content: Text('$calledUserName is in another call'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
