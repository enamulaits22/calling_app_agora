import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

class FCMService {
  Future<bool> sendCallRequest(String fcmToken) async {
    bool isCallSuccessful = false;
    Map data = {
      "to": fcmToken,
      "collapse_key": "type_a",
      "notification": {
        "body": "Body of Your Notification",
        "title": "Title of Your Notification"
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
      'Authorization': 'key=AAAAFnWljmg:APA91bEnP7Bb7UVlMS43avYzVbDbr_NmAmENdm2AECa6Ns80gCKAjsyl3zlXBh2wIAbnyIJx3lb-z9yvwBQZ9lzkyKreIurJuru5XmSiXoQUwqPIp490XnvkafmFwpXkfrlVcQV3ZB9X',
      'Content-Type': 'application/json'
    };

    final http.Response response = await http.post(url, body: body, headers: headers);

    if (response.statusCode == 200) {
      log(response.body);
      log('Call send successful!!!');
      isCallSuccessful = true;
      return isCallSuccessful;
    } else {
      throw Exception('Failed to submit');
    }
  }
}
