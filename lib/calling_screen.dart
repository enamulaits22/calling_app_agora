import 'dart:developer';

import 'package:calling_app/config/config.dart';
import 'package:calling_app/config/utils/sp_utils.dart';
import 'package:calling_app/widgets/custom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  const CallingScreen({Key? key, this.documentsId}) : super(key: key);

  @override
  _CallingScreenState createState() => _CallingScreenState();
}

// App state class
class _CallingScreenState extends State<CallingScreen> {
  bool _joined = false;
  int _remoteUid = 0;
  bool _switch = false;
  bool isMutedAudio = false;
  late RtcEngine engine;
  late CollectionReference users;

  @override
  void initState() {
    super.initState();

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
  }

  // Init the app
  Future<void> initPlatformState() async {
    final service = FlutterBackgroundService();
    service.invoke(
        "stopService"); //:::::::::::::::::::::::::::stopped background service
    SharedPref.saveValueToShaprf(Config.callStatus,'reset');
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
      log('userJoined ${uid}');
      setState(() {
        _remoteUid = uid;
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
    await engine.joinChannel(Config.Token, Config.channelName, null, 0);
  }

  // Build UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Call'),
      ),
      body: Stack(
        children: [
          Center(
            child: _switch ? _renderRemoteVideo() : _renderLocalPreview(),
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
                  child: _switch ? _renderLocalPreview() : _renderRemoteVideo(),
                ),
              ),
            ),
          ),
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

    //set receiver reject status initial to False
    users
        .doc('${widget.documentsId}')
        .update({'hasReceiverRejectedCall': 'false'})
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));

    // caller end call status set to True
    users
        .doc('${widget.documentsId}')
        .update({'hasCallerEndCall': 'true'})
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));

    Navigator.of(context).pop();
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
}
