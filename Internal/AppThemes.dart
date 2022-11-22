///
/// Defining and setting app themes
///

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Data/Preferences.dart';

class ThemeProvider extends ChangeNotifier {
  late ThemeMode themeMode;

  ThemeProvider() {
    // Load from preferences.
    themeMode = (UserPreferences.prefs.getBool("darkMode") ?? false)
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  bool get isDarkMode => themeMode == ThemeMode.dark;

  void toggleDark(bool status) async {
    themeMode = status ? ThemeMode.dark : ThemeMode.light;

    // Save into preferences.
    UserPreferences.prefs.setBool("darkMode", status);
    notifyListeners();
  }
}

class MyThemes {
  static final darkTheme = ThemeData(
      scaffoldBackgroundColor: Colors.grey.shade900,
      primaryColor: Colors.grey.shade900,
      fontFamily: GoogleFonts.dmSerifDisplay().fontFamily,
      iconTheme: IconThemeData(color: Colors.white),
      colorScheme:
          ColorScheme.dark(primary: Colors.blue, secondary: Colors.white),
      primarySwatch: Colors.blue,
      dialogBackgroundColor: Colors.grey.shade900,
      brightness: Brightness.dark,
      appBarTheme: AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.light));

  static final lightTheme = ThemeData(
      scaffoldBackgroundColor: Colors.white,
      primaryColor: Colors.white,
      fontFamily: GoogleFonts.dmSerifDisplay().fontFamily,
      iconTheme: IconThemeData(color: Colors.black),
      colorScheme:
          ColorScheme.light(primary: Colors.blue, secondary: Colors.black),
      primarySwatch: Colors.blue,
      dialogBackgroundColor: Colors.white,
      brightness: Brightness.light,
      appBarTheme: AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle.dark));
}
