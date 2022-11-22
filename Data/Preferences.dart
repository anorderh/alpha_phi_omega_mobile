///
/// Stored preferences for managing system appearance
///


import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static late SharedPreferences prefs;

  static Future init() async => prefs = await SharedPreferences.getInstance();
}
