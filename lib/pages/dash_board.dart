import 'dart:io';

import 'package:calling_app/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../phone_auth/phone_auth_dashboard.dart';
import '../services/authentication.dart';
import '../widgets/custom_text_button.dart';
import '../widgets/image_picker_dialog.dart';

/*Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text('You are now logged in as ${widget.uid}'),
              SizedBox(
                height: 15.0,
              ),
              ElevatedButton(
                child: Text('Logout'),
                onPressed: () {
                  FirebaseAuth.instance.signOut().then((action) {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PhoneAuthForm()));
                  }).catchError((e) {
                    print(e);
                  });
                },
              ),
            ],
          ),*/

class DashboardPage extends StatefulWidget {
  String? uid;

  DashboardPage({this.uid});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String updatedImage = '';
  bool isNameTapped = false;
  bool isLoading = false;
  final _nameController = TextEditingController();
  String userProfilePicture = '';
  String userProfileName = '';

  @override
  void initState() {
    this.widget.uid = '';
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      setState(() {
        this.widget.uid = FirebaseAuth.instance.currentUser?.uid;
      });
    }
    checkUserHasProfilePicture();
    super.initState();
  }

  checkUserHasProfilePicture() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .listen((event) {
      setState(() {
        userProfilePicture = event['profilePicture'];
        userProfileName = event['userName'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Stack(
                    children: [
                      updatedImage == ''
                          ? CircleAvatar(
                        backgroundColor: Color(0XFFe6f9ff),
                        radius: 60.0,
                        child: CircleAvatar(
                          radius: 55,
                          backgroundImage: NetworkImage(userProfilePicture
                              .isNotEmpty
                              ? userProfilePicture
                              : 'https://raw.githubusercontent.com/enamulhaque028/ecommerce_app/master/assets/images/upload.png'),
                        ),
                      )
                          : CircleAvatar(
                        backgroundColor: const Color(0XFFe6f9ff),
                        radius: 60.0,
                        child: CircleAvatar(
                          radius: 55,
                          backgroundImage: FileImage(File(updatedImage)),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 0,
                        child: InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext ctx) {
                                return ImagePickerDialog(
                                  updatePhoto: (imagePath) {
                                    setState(() {
                                      updatedImage = imagePath;
                                    });
                                  },
                                );
                              },
                            );
                          },
                          child: Image.network(
                            'https://raw.githubusercontent.com/enamulhaque028/ecommerce_app/master/assets/images/edit.png',
                            fit: BoxFit.cover,
                            height: 30,
                            // width: size.width,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Name'),
                  subtitle: !isNameTapped
                      ? Text(userProfileName.isNotEmpty
                      ? userProfileName
                      : 'ABC DEF')
                      : TextFormField(
                    controller: _nameController,
                  ),
                  trailing: InkWell(
                      onTap: () {
                        setState(() {
                          isNameTapped = true;
                        });
                      },
                      child: Icon(Icons.edit, color: Colors.blue)),
                ),
                ListTile(
                  leading: Icon(Icons.phone),
                  title: Text('Phone'),
                  subtitle:
                  Text('${FirebaseAuth.instance.currentUser?.phoneNumber}'),
                ),
                SizedBox(
                  height: 50,
                ),
                !isLoading
                    ? CustomTextButton(
                  title: 'submit',
                  onTapBtn: () async {
                    if (_nameController.text.isNotEmpty) {
                      setState(() {
                        isLoading = true;
                      });

                      final ref = FirebaseStorage.instance
                          .ref('profileImage')
                          .child(updatedImage);
                      final uploadTask = ref.putFile(File(updatedImage));

                      final snapShot = await uploadTask.whenComplete(() {});

                    final url =  await snapShot.ref.getDownloadURL();

                      setState(() {
                        isLoading = false;
                      });

                      Authentication().addUser(
                          userName: userProfileName.isNotEmpty
                              ? userProfileName
                              : _nameController.text,
                          profilePicture: url);

                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) =>
                              MyHomePage(
                                  userDocumentsId: FirebaseAuth.instance
                                      .currentUser!.uid)), (route) => false);

                    }
                  },
                )
                    : Center(
                  child: CircularProgressIndicator(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
