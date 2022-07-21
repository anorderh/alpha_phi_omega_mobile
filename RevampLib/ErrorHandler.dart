import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../RevampLib/AppData.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../RevampLib/Settings.dart';
import 'EventView.dart';
import 'Home_HTTP.dart';
import 'UserData.dart';
import 'Login_HTTP.dart';
import 'Home_Loading.dart';
import 'package:sizer/sizer.dart';
import 'package:expandable_page_view/expandable_page_view.dart';

class HTTPRefreshDialog extends StatefulWidget {
  final Function refreshScrape;

  const HTTPRefreshDialog({Key? key, required this.refreshScrape})
      : super(key: key);

  @override
  _HTTPRefreshDialogState createState() => _HTTPRefreshDialogState();
}

class _HTTPRefreshDialogState extends State<HTTPRefreshDialog> {
  late UserData user;
  late Widget logout;

  late Timer countdown;
  int secondsToRefresh = 3;
  bool HTTPstarted = false;

  @override
  void initState() {
    countdown = Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
    logout = initCloseButton();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    user = MainUser.of(context).data;
    super.didChangeDependencies();
  }

  Widget initCloseButton() {
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        // padding: EdgeInsets.all(0),
        child: Ink(
            width: 150,
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.blue,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 3)
              ],
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            child: Text("Logout",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white))),
        onTap: () {
          countdown.cancel();
          Logout(context);
        },
      ),
    );
  }

  void setCountDown() {
    setState(() {
      secondsToRefresh -= 1;

      if (secondsToRefresh == 0) {
        HTTPstarted = true;
        countdown.cancel();

        restartHTTP();
      }
    });
  }

  void restartHTTP() async {
    await initHTTP(
        user.http, user.http.data['email']!, user.http.data['password']!);
    await widget.refreshScrape();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        backgroundColor: Colors.lightBlue[50],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))),
        title: Column(
          children: [
            Text(
              "Invalid HTTP",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Reconnecting in $secondsToRefresh...",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            )
          ],
        ),
        content: Container(
          width: 250,
          child: HTTPstarted
              ? Center(
            heightFactor: 1,
            widthFactor: 1,
            child: SizedBox(
              height: 25,
              width: 25,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          )
              : logout,
        ));
  }
}

class ErrorDialog extends StatefulWidget {
  final String title;

  const ErrorDialog({Key? key, required this.title}) : super(key: key);

  @override
  _ErrorDialogState createState() => _ErrorDialogState();
}

class _ErrorDialogState extends State<ErrorDialog> {
  late Timer countdown;
  int secondsToRefresh = 3;
  bool loggingOut = false;

  @override
  void initState() {
    countdown = Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
    super.initState();
  }

  void setCountDown() {
    setState(() {
      secondsToRefresh -= 1;

      if (secondsToRefresh == 0) {
        loggingOut = true;
        countdown.cancel();

        logoutExtended();
      }
    });
  }

  void logoutExtended() async {
    await Future.delayed(Duration(seconds: 1), () {
      Logout(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        backgroundColor: Colors.lightBlue[50],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))),
        title: Column(
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Please report this bug to the app admin.\nLogging out in $secondsToRefresh...",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            )
          ],
        ),
        content: Container(
          width: 250,
          child: loggingOut
              ? Center(
                  heightFactor: 1,
                  widthFactor: 1,
                  child: SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                )
              : SizedBox.shrink(),
        ));
  }
}
