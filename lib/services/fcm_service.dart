import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;

class FCMService {
  Future<bool> sendCallRequest(String fcmToken) async {
    bool isCallSuccessful = false;
    Map data = {
      "to": fcmToken,
      "collapse_key": "type_a",
      "notification": {
        "body": "",
        "title": ""
      },
      "data": {
        "body": "Body of Your Notification in Data",
        "title": "Title of Your Notification in Title",
        "key_1": "Value for key_1",
        "key_2": "Value for key_2"
      }
    };

    var body = json.encode(data);
    Uri url = Uri.parse('https://fcm.googleapis.com/fcm/send');
    var headers = {
      'Authorization': 'key=AAAArCB0vb0:APA91bFuCMifuun0jiRq5hIizygcN6uUw1BkQXp9BP5fBibXSZnkutLAVjIMxCGb3s1afwy9SCZy_QeY-rPweGqFc4Y4B-32eNkkd_z2T8OONol-sWb0s2-xqFLzkNXYYOySo4n42Qej',
      'Content-Type': 'application/json'
    };

    try {
      final response = await http.post(url, body: body, headers: headers);
      if (response.statusCode == 200) {
        log(response.body);
        print('================================Call send successful!!!');
        isCallSuccessful = true;
      } else {
        log('Failed to call!!!');
        isCallSuccessful = false;
      }
    } on Exception catch (e) {
      if (e is SocketException) {
        print('================================Failed to call!!!');
        isCallSuccessful = false;
      }
    }
    return isCallSuccessful;
  }
}