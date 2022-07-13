import 'package:flutter/material.dart';
import 'Login.dart';
import '../Frontend/bottom_nav.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:example/EventPage/EventDialog/calcDate.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/services.dart';
import 'package:example/RevampLib/UserData.dart';
import 'package:example/RevampLib/AppData.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
        controller: EventController(),
        child: System(
          version: "1.0",
          lastUpdated: DateTime(2022, 7, 13),
          currentDate: DateTime(2022, 7, 19),
          child: MainUser(
            data: UserData(),
            child: MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(
                  primarySwatch: Colors.blue,
                  textTheme: GoogleFonts.dmSerifDisplayTextTheme()),
              home: LoginBody(),
            ),
          ),
        ));
  }
}