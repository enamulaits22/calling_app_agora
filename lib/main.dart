import 'dart:developer';

import 'package:calling_app/config/config.dart';
import 'package:calling_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

// App state class
class _MyAppState extends State<MyApp> {
  bool _joined = false;
  int _remoteUid = 0;
  bool _switch = false;
  bool isMutedAudio = false;
  late RtcEngine engine;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Init the app
  Future<void> initPlatformState() async {
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
      });
    }, userOffline: (int uid, UserOfflineReason reason) {
      log('userOffline ${uid}');
      setState(() {
        _remoteUid = 0;
      });
    }));
    // Enable video
    await engine.enableVideo();
    // Join channel with channel name as 123
    await engine.joinChannel(Config.Token, Config.channelName, null, 0);
  }


  // Build UI
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter example app'),
        ),
        body: Stack(
          children: [
            Center(
              child: _switch ? _renderRemoteVideo() : _renderLocalPreview(),
            ),
            Align(
              alignment: Alignment.topLeft,
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
                    child:
                    _switch ? _renderLocalPreview() : _renderRemoteVideo(),
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
    } 

    else {
      return Text(
        'Please join channel first',
        textAlign: TextAlign.center,
      );
    }
  }

  // Remote video rendering
  Widget _renderRemoteVideo() {
    if (_remoteUid != 0 && defaultTargetPlatform == TargetPlatform.android || _remoteUid != 0 && defaultTargetPlatform == TargetPlatform.iOS) {
      return RtcRemoteView.SurfaceView(
        uid: _remoteUid,
        channelId: Config.channelName,
      );
    } 

    if (_remoteUid != 0 && defaultTargetPlatform == TargetPlatform.windows || _remoteUid != 0 && defaultTargetPlatform == TargetPlatform.macOS) {
      return RtcRemoteView.TextureView(
        uid: _remoteUid,
        channelId: Config.channelName,
      );
    } 

    else {
      return Text(
        'Please wait remote user join',
        textAlign: TextAlign.center,
      );
    }
  }

  //Leave channel
  void _onLeaveChannel() async {
    await engine.leaveChannel();
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