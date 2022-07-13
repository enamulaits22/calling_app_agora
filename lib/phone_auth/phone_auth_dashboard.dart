import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
/*
class PhoneAuthPage extends StatefulWidget {
  PhoneAuthPage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _PhoneAuthPageState createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  late String phoneNo;
  String? uid;
  late String smsCode;
  late String verificationId;
  FirebaseAuth _auth = FirebaseAuth.instance;

  Scaffold homePage() {
    if (_auth.currentUser?.uid != null) {
      setState(() {
        uid = _auth.currentUser?.uid;
      });
    }

    return Scaffold(body: DashboardPage(uid: uid));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Phone Login'),
        ),
        body: _auth.currentUser?.uid != null
            ? homePage()
            : Center(
                child: Container(
                    padding: EdgeInsets.all(25.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextField(
                          keyboardType: TextInputType.phone,
                          decoration:
                              InputDecoration(hintText: 'Enter Phone number'),
                          onChanged: (value) {
                            this.phoneNo = value;
                          },
                        ),
                        SizedBox(height: 10.0),
                        ElevatedButton(
                          onPressed: () => verifyPhone(),
                          child: Text('Verify'),
                        )
                      ],
                    )),
              ));
  }

  Future<void> verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    }; // this will auto click the verification button

    final smsCodeSent = (String verId, [int? forceCodeResend]) {
      this.verificationId = verId;
      smsCodeDialog(context).then((value) {
        print("Signed In");
      });
    };

    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential user) {
      print('verified');
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException expection) {
      print(expection.message);
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: this.phoneNo,
        timeout: const Duration(seconds: 5),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: smsCodeSent,
        codeAutoRetrievalTimeout: autoRetrieve);
  }

  Future<void> smsCodeDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Enter sms Code'),
            content: TextField(
              onChanged: (value) {
                this.smsCode = value;
              },
            ),
            contentPadding: EdgeInsets.all(10.0),
            actions: <Widget>[
              new TextButton(
                child: Text('Done'),
                onPressed: () {
                  if (_auth.currentUser != null) {
                    print("User is not null");
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DashboardPage(uid: _auth.currentUser?.uid)),
                    );
                  } else {
                    print("User is null");
                    Navigator.of(context).pop();
                    signIn();
                  }
                },
              )
            ],
          );
        });
  }

  signIn() async {
    final AuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.signInWithCredential(credential).then((user) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DashboardPage(uid: user.user?.uid)),
      );
    }).catchError((e) {
      print(e);
    });
  }
}*/

class DashboardPage extends StatefulWidget {
  String? uid;
  DashboardPage({this.uid});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  getUid() {}

  @override
  void initState() {
    this.widget.uid = '';
    if (FirebaseAuth.instance.currentUser?.uid != null) {
      setState(() {
        this.widget.uid = FirebaseAuth.instance.currentUser?.uid;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Center(
      child: Container(
        child: new Column(
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
        ),
      ),
    ));
  }
}

class PhoneAuthForm extends StatefulWidget {
  const PhoneAuthForm({Key? key}) : super(key: key);

  @override
  _PhoneAuthFormState createState() => _PhoneAuthFormState();
}

class _PhoneAuthFormState extends State<PhoneAuthForm> {
  var otpController = TextEditingController();
  var numController = TextEditingController();
  var isLoading = false;

  FirebaseAuth auth = FirebaseAuth.instance;

  String verificationId = "";

  void signInWithPhoneAuthCredential(
      PhoneAuthCredential phoneAuthCredential) async {
    try {
      final authCredential =
          await auth.signInWithCredential(phoneAuthCredential);

      if (authCredential.user != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DashboardPage(
                      uid: authCredential.user?.uid,
                    )));
      }
    } on FirebaseAuthException catch (e) {
      print("catch");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Phone Number',
                    hintText: 'Enter valid number'),
                controller: numController,
                keyboardType: TextInputType.phone,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                obscureText: true,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter valid password'),
                controller: otpController,
              ),
            ),
            !isLoading
                ? TextButton(
                    onPressed: () {
                      fetchotp();
                      setState(() {
                        isLoading = true;
                      });
                    },
                    child: const Text("Fetch OTP"),
                  )
                : CircularProgressIndicator(),
            TextButton(
                onPressed: () {
                  verify();
                },
                child: const Text("Send"))
          ],
        ),
      ),
    );
  }

  Future<void> verify() async {
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: otpController.text);

    signInWithPhoneAuthCredential(phoneAuthCredential);
  }

  Future<void> fetchotp() async {
    await auth.verifyPhoneNumber(
      phoneNumber: numController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        this.verificationId = verificationId;

        setState(() {
          isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
}
