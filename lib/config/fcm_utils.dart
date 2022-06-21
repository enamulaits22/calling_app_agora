import 'dart:async';
import 'dart:math' as math;
import 'package:calling_app/main.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:connectycube_flutter_call_kit/connectycube_flutter_call_kit.dart';

StreamController<int> event = StreamController();

void initiateCall() {
  controlCall();
  math.Random random = math.Random();
  CallEvent callEvent = CallEvent(
    sessionId: random.nextInt(100).toString(),
    callType: 1, // {0 :: Audio call}; {1 :: Video Call}
    callerId: 9644,
    callerName: 'Caller Name',
    opponentsIds: {1},
    userInfo: {'customParameter1': 'value1'},
  );

  ConnectycubeFlutterCallKit.instance.updateConfig(ringtone: 'basi_sur', icon: 'app_icon', color: '#07711e');
  
  ConnectycubeFlutterCallKit.showCallNotification(callEvent);
}

void controlCall() {
  Future<void> _onCallAccepted(CallEvent callEvent) async {
    // bool res = await DeviceApps.openApp('com.example.calling_app');
    // print(res.toString());

    // if (res) {
    //   Future.delayed(Duration(seconds: 2), (){
    //     navigatorKey?.currentState?.push(MaterialPageRoute(builder: (_) => CallingScreen()));
    //   });
    // }
    log(navigatorKey.currentContext.toString());
   
  Future.delayed(Duration(seconds: 5,),(){
     event.sink.add(1);
    log('hurre');
 
  });
  }

  Future<void> _onCallRejected(CallEvent callEvent) async {
    // the call was rejected
  }
  ConnectycubeFlutterCallKit.instance.init(
    onCallAccepted: _onCallAccepted,
    onCallRejected: _onCallRejected,
  );
}
