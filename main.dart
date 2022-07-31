///
/// START - defines and runs MyApp
///
/// Created by Anthony Norderhaug
/// 7/30/2022
/// EMAIL: anthony@norderhaug.org, IG: nordenhagen_anthony
///

import 'package:flutter/material.dart';
import 'Login/Login.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:calendar_view/calendar_view.dart';
import 'Data/UserData.dart';
import 'Data/AppData.dart';
import 'package:sizer/sizer.dart';
import 'Internal/AboutApp_Constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // calendar_view package
    return CalendarControllerProvider(
      controller: EventController(),
      // AppData.dart
      child: System(
        version: version,
        lastUpdated: lastUpdated,
        currentDate: DateTime.now(),
        tracker: ExceptionTracker(),
        // UserData.dart
        child: MainUser(
          data: UserData(),
          // Sizer package
          child: Sizer(builder: (context, orientation, deviceType) {
            return MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(
                  primarySwatch: Colors.blue,
                  textTheme: GoogleFonts.dmSerifDisplayTextTheme()),
              home: LoginBody(), // Login.dart
            );
          }),
        ),
      ),
    );
  }
}
