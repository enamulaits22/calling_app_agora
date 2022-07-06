import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static Future<bool> saveValueToShaprf(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  static Future<String?> getValueFromShrprs(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
}