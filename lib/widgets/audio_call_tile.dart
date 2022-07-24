import 'package:calling_app/config/presentation/app_color.dart';
import 'package:calling_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class AudioCallTile extends StatelessWidget {
  final String callerName;
  final String callingTime;
  final String imageUrl;
  final VoidCallback onEndCall;
  final bool isMutedAudio;
  final VoidCallback onToggleMuteAudio;
  final bool isSpeakerEnable;
  final VoidCallback onToggleSpeaker;
  final VoidCallback onSwitchVideo;

  const AudioCallTile({
    Key? key,
    required this.callerName,
    required this.callingTime,
    required this.imageUrl,
    required this.isMutedAudio,
    required this.onEndCall,
    required this.onToggleMuteAudio,
    required this.isSpeakerEnable,
    required this.onToggleSpeaker,
    required this.onSwitchVideo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Container(
              height: 120,
              width: double.infinity,
              // color: Colors.green,
              decoration: BoxDecoration(
                gradient: AppColor.blueGradient,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$callerName',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '$callingTime',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Image.network('$imageUrl', width: size.width, fit: BoxFit.cover),
            ),
            Container(
              height: 80,
              width: double.infinity,
              // color: Colors.green,
              decoration: BoxDecoration(
                gradient: AppColor.blueGradient,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: onSwitchVideo,
                    icon: Icon(
                      Icons.videocam,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    decoration: isSpeakerEnable ? BoxDecoration(
                      color: Colors.grey.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20)
                    ) : null,
                    child: IconButton(
                      onPressed: onToggleSpeaker,
                      icon: Icon(
                        const IconData(
                          0xe6c5,
                          fontFamily: 'MaterialIcons',
                        ),
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onToggleMuteAudio,
                    icon: Icon(
                      !isMutedAudio ? Icons.mic : Icons.mic_off,
                      color: Colors.white,
                    ),
                  ),
                  CustomButton(
                    icon: Icons.call_end,
                    fillColor: Colors.red,
                    iconColor: Colors.white,
                    iconSize: 30,
                    onTapBtn: onEndCall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
