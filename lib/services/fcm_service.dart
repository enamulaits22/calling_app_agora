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

  Future<void> changeStatus(String status) async {
    Uri url = Uri.parse('https://aos-swipe-backend.herokuapp.com/api/user');

    try {
      var headers = {
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7ImRpYW1vbmQiOjAsIl9pZCI6IjYyMWEzZDZlNzVjMGUxOTkwODZhNGQyMiIsImVtYWlsIjoiYXRtc2hpYmxlQGdtYWlsLmNvbSIsInR5cGUiOiJ1c2VyIiwicm9sZXMiOlsidXNlciJdLCJnZW5kZXIiOiJtYWxlIiwiYmlydGhkYXkiOiIxOTk2LTAyLTI4VDAwOjAwOjAwLjAwMFoiLCJjb3VudHJ5Q29kZSI6ImJkIn0sImlhdCI6MTY1NjQwNjI0OCwiZXhwIjoxNjU3NzAyMjQ4fQ.P3DsEmf5t1Wwv7wKMt-ux7x-emlN2fezjLi-Yue6dXk',
        'Content-Type': 'application/json'
      };

      var body = json.encode({"gender": status});
      final response = await http.patch(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        log(response.body);
        print('================================change status successful!!!');
        } else {
        log('=============================Failed to change status!!!');
      }
    } on Exception catch (e) {
      if (e is SocketException) {
        print('================================Failed to change status!!!');
      }
    }
  }

  Future<dynamic> getStatus() async {
    Uri url = Uri.parse('https://aos-swipe-backend.herokuapp.com/api/user');

    try {
      var headers = {
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjp7ImRpYW1vbmQiOjAsIl9pZCI6IjYyMWEzZDZlNzVjMGUxOTkwODZhNGQyMiIsImVtYWlsIjoiYXRtc2hpYmxlQGdtYWlsLmNvbSIsInR5cGUiOiJ1c2VyIiwicm9sZXMiOlsidXNlciJdLCJnZW5kZXIiOiJtYWxlIiwiYmlydGhkYXkiOiIxOTk2LTAyLTI4VDAwOjAwOjAwLjAwMFoiLCJjb3VudHJ5Q29kZSI6ImJkIn0sImlhdCI6MTY1NjQwNjI0OCwiZXhwIjoxNjU3NzAyMjQ4fQ.P3DsEmf5t1Wwv7wKMt-ux7x-emlN2fezjLi-Yue6dXk',
        'Content-Type': 'application/json'
      };

      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        log(response.body);
        print('================================get status successful!!!');
        return jsonDecode(response.body);
        } else {
        log('=============================Failed to get status!!!');
      }
    } on Exception catch (e) {
      if (e is SocketException) {
        print('================================Failed to get status!!!');
      }
    }
  }
}