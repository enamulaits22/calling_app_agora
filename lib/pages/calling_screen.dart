import 'dart:developer';

import 'package:calling_app/config/config.dart';
import 'package:calling_app/config/utils/sp_utils.dart';
import 'package:calling_app/widgets/audio_call_tile.dart';
import 'package:calling_app/widgets/custom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';

class CallingScreen extends StatefulWidget {
  final String? documentsId;
  final String userName;
  final String? userPhoto;
  final String callType;

  const CallingScreen({
    Key? key,
    this.documentsId,
    required this.userName,
    required this.userPhoto,
    required this.callType,
  }) : super(key: key);

  @override
  _CallingScreenState createState() => _CallingScreenState();
}

// App state class
class _CallingScreenState extends State<CallingScreen> {
  bool _joined = false;
  int _remoteUid = 0; //remote user hasn't joined yet
  bool _switch = false;
  bool isMutedAudio = false;
  bool isMutedVideo = false;
  bool isSpeakerEnable = false;
  late RtcEngine engine;
  late CollectionReference users;
  late Timer timerToleaveChannel;
  late Timer timer;
  int startSeconds = 0;
  String callingTime = "connecting";
  late String callType = widget.callType;

  @override
  void initState() {
    super.initState();

    timerToleaveChannel = Timer(Duration(seconds: 10), () {
      _onLeaveChannel();
    });

    users = FirebaseFirestore.instance.collection('users');

    users.doc(widget.documentsId).snapshots().listen((event) {
      if (event.data() != null) {
        final e = event.data() as Map<String, dynamic>;
        if (e['hasReceiverRejectedCall'] == 'true') {
          _onLeaveChannel();
        }
      }
    });

    initPlatformState();
    setCallerAndReceiverInCallTrue();
  }

  void setCallerAndReceiverInCallTrue() async{
    //Receiver InCall Status set True
    print(widget.documentsId);
   await users
        .doc('${widget.documentsId}')
        .update({
          'isReceiverInCall': 'true',
        })
        .then((value) => print("isReceiverInCall => true"))
        .catchError((error) => print("Failed to add user: $error"));

    //Caller InCall Status set True
    users
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'isReceiverInCall': 'true'})
        .then((value) => print("isReceiverInCall => true"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<void> initPlatformState() async {
    final service = FlutterBackgroundService();
    service.invoke(
        "stopService"); //:::::::::::::::::::::::::::stopped background service
    SharedPref.saveValueToShaprf(Config.callStatus, 'reset');
    if (defaultTargetPlatform == TargetPlatform.android) {
      await [Permission.microphone, Permission.camera].request();
    }

    // Create RTC client instance
    RtcEngineContext context = RtcEngineContext(Config.APP_ID);
    engine = await RtcEngine.createWithContext(context);
    // Define event handling logic
    engine.setEventHandler(RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
      log('joinChannelSuccess ${channel} ${uid}');
      setState(() {
        _joined = true;
      });
    }, userJoined: (int uid, int elapsed) {
      timerToleaveChannel.cancel();
      countDownTime();
      log('userJoined ${uid}');
      setState(() {
        _remoteUid = uid; //remote user has joined
        _switch = true;
      });
    }, userOffline: (int uid, UserOfflineReason reason) {
      log('userOffline ${uid}');
      setState(() {
        _remoteUid = 0;
        _onLeaveChannel();
      });
    }));
    // Enable video
    await engine.enableVideo();
    // Join channel with channel name
    if (callType == 'audio') {
      await engine.setEnableSpeakerphone(isSpeakerEnable);
    }
    await engine.joinChannel(Config.Token, Config.channelName, null, 0);
  }

  Future<void> countDownTime() async {
    timer = Timer.periodic(Duration(seconds: 1), (time) {
      startSeconds = startSeconds + 1;

      int minutes = startSeconds ~/ 60;
      int seconds = (startSeconds % 60);
      setState(() {
        callingTime = minutes.toString().padLeft(2, "0") +
            ":" +
            seconds.toString().padLeft(2, "0");
      });
      print(callingTime);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _onLeaveChannel();
    timer.cancel();
    timerToleaveChannel.cancel();
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var res = await showDialog(
          context: context,
          builder: (c) => AlertDialog(
            title: Text('Warning'),
            content: Text('Do you really want to exit'),
            actions: [
              ElevatedButton(
                child: Text('Yes'),
                onPressed: () => Navigator.pop(c, true),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red),
                ),
              ),
              ElevatedButton(
                child: Text('No'),
                onPressed: () => Navigator.pop(c, false),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                ),
              ),
            ],
          ),
        );
        return res;
      },
      child: Scaffold(
        // appBar: AppBar(
        //   title: const Text('Agora Call'),
        // ),
        body: callType == 'audio'
            ? AudioCallTile(
                callerName: widget.userName,
                callingTime: callingTime,
                imageUrl: widget.userPhoto!,
                isMutedAudio: isMutedAudio,
                onEndCall: _onLeaveChannel,
                onToggleMuteAudio: _onToggleMuteAudio,
                isSpeakerEnable: isSpeakerEnable,
                onToggleSpeaker: _onToggleSpeaker,
                onSwitchVideo: _onSwitchVideo,
              )
            : Padding(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: Stack(
                  children: [
                    Center(
                      child: _switch && _remoteUid != 0
                          ? _renderRemoteVideo()
                          : _renderLocalPreview(),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.blue,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _switch = !_switch;
                            });
                          },
                          child: Center(
                            child: _switch && _remoteUid != 0
                                ? _renderLocalPreview()
                                : _renderRemoteVideo(),
                          ),
                        ),
                      ),
                    ),
                    _remoteUid != 0
                        ? Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.userName,
                                      style: TextStyle(
                                          fontSize: 22, color: Colors.white),
                                    ),
                                    Text(
                                      '$callingTime',
                                      style: TextStyle(
                                          fontSize: 22, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 40.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomButton(
                              icon: !isMutedAudio ? Icons.mic : Icons.mic_off,
                              fillColor: Colors.white,
                              iconColor: Colors.blue,
                              iconSize: 18,
                              onTapBtn: _onToggleMuteAudio,
                            ),
                            CustomButton(
                              icon: Icons.call_end,
                              fillColor: Colors.red,
                              iconColor: Colors.white,
                              iconSize: 30,
                              onTapBtn: _onLeaveChannel,
                            ),
                            CustomButton(
                              icon: !isMutedVideo
                                  ? Icons.videocam
                                  : Icons.videocam_off,
                              fillColor: Colors.white,
                              iconColor: Colors.blue,
                              iconSize: 18,
                              onTapBtn: _onToggleMuteVideo,
                            ),
                            CustomButton(
                              icon: Icons.switch_camera,
                              fillColor: Colors.white,
                              iconColor: Colors.blue,
                              iconSize: 18,
                              onTapBtn: _onSwitchCamera,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // Local video rendering
  Widget _renderLocalPreview() {
    if (_joined && defaultTargetPlatform == TargetPlatform.android ||
        _joined && defaultTargetPlatform == TargetPlatform.iOS) {
      return RtcLocalView.SurfaceView();
    }

    if (_joined && defaultTargetPlatform == TargetPlatform.windows ||
        _joined && defaultTargetPlatform == TargetPlatform.macOS) {
      return RtcLocalView.TextureView();
    } else {
      return Text(
        'Please join channel first',
        textAlign: TextAlign.center,
      );
    }
  }

  // Remote video rendering
  Widget _renderRemoteVideo() {
    if (_remoteUid != 0 && defaultTargetPlatform == TargetPlatform.android ||
        _remoteUid != 0 && defaultTargetPlatform == TargetPlatform.iOS) {
      return RtcRemoteView.SurfaceView(
        uid: _remoteUid,
        channelId: Config.channelName,
      );
    }

    if (_remoteUid != 0 && defaultTargetPlatform == TargetPlatform.windows ||
        _remoteUid != 0 && defaultTargetPlatform == TargetPlatform.macOS) {
      return RtcRemoteView.TextureView(
        uid: _remoteUid,
        channelId: Config.channelName,
      );
    } else {
      return Text(
        'Please wait remote user join',
        textAlign: TextAlign.center,
      );
    }
  }

  //Leave channel
  void _onLeaveChannel() async {
    await engine.leaveChannel();

    setCallingStatusAndInCallStatusToFalse();

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Call ended"),
    ));
  }

  void setCallingStatusAndInCallStatusToFalse() {
     //set Receiver reject status initial to False, caller end call status set to True, receiver inCall status set to false
    users
        .doc('${widget.documentsId}')
        .update({
          'hasReceiverRejectedCall': 'false',
          'hasCallerEndCall': 'true',
          'isReceiverInCall': 'false',
        })
        .then((value) => print("hasReceiverRejectedCall => false"))
        .catchError((error) => print("Failed to add user: $error"));

    //Caller InCall Status set False
    users
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'isReceiverInCall': 'false'})
        .then((value) => print("isReceiverInCall => false"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  //Switch camera
  void _onSwitchCamera() async {
    await engine.switchCamera();
  }

  //Enable and Disable audio
  void _onToggleMuteAudio() async {
    setState(() {
      isMutedAudio = !isMutedAudio;
    });
    await engine.muteLocalAudioStream(isMutedAudio);
  }

  //Enable and Disable video
  void _onToggleMuteVideo() async {
    setState(() {
      isMutedVideo = !isMutedVideo;
    });
    await engine.muteLocalVideoStream(isMutedVideo);
  }

  //Enable and Disable video
  void _onToggleSpeaker() async {
    setState(() {
      isSpeakerEnable = !isSpeakerEnable;
    });
    await engine.setEnableSpeakerphone(isSpeakerEnable);
  }
  
  //Switch between video and audio
  void _onSwitchVideo() async {
    setState(() {
      callType = 'video';
    });
    await engine.setEnableSpeakerphone(true);
  }
}
