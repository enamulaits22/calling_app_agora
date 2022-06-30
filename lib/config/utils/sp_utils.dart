import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static Future<bool> setCallStatus(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString('status', value);
  }

  static Future<String?> getCallStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('status');
  }
}