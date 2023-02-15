///
/// Dialogs prompted when error detected
///

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Data/AppData.dart';
import '../Data/UserData.dart';
import '../Login/Login_HTTP.dart';

///
/// Dialog to display when refreshing a widget
///
class HTTPRefreshDialog extends StatefulWidget {
  final Function refreshScrape;

  const HTTPRefreshDialog({Key? key, required this.refreshScrape})
      : super(key: key);

  @override
  _HTTPRefreshDialogState createState() => _HTTPRefreshDialogState();
}

class _HTTPRefreshDialogState extends State<HTTPRefreshDialog> {
  late UserData user;
  late ExceptionTracker tracker;

  late Timer countdown;
  late Widget logout;
  late String actionMsg;
  bool actionStarted = false;

  int secondsLeft = 5;
  late bool forceLogout;
  int exceptionMax = 3;


  @override
  void initState() {
    // Starting Timer!
    countdown = Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
    super.initState();
  }

  @override
  void didChangeDependencies() {
    user = MainUser.of(context).data;
    tracker = System.of(context).tracker;
    tracker.exceptionStack += 1;

    forceLogout = (tracker.exceptionStack >= exceptionMax);

    // HTTP Refresh or Logout based on # of continuous errors.
    if (forceLogout) {
      actionMsg = "Logging out in ";
      logout = SizedBox.shrink();
    } else {
      actionMsg = "Reconnecting in ";
      logout = initCloseButton();
    }

    super.didChangeDependencies();
  }

  Widget initCloseButton() {
    return Container(
      margin: EdgeInsets.only(top: 15),
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(15)),
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

  // H: Countdown method
  void setCountDown() {
    setState(() {
      secondsLeft -= 1;

      if (secondsLeft == 0) {
        actionStarted = true;
        countdown.cancel();

        if (forceLogout) {
          tracker.exceptionStack = 0;
          Logout(context);
        } else {
          restartHTTP();
        }
      }
    });
  }

  // Refreshing HTTP with current user data
  void restartHTTP() async {
    String httpMsg = await initHTTP(
        user.http, user.http.data['email']!, user.http.data['password']!);
    if (httpMsg == "Success") {
      tracker.exceptionStack = 0;
    }

    await widget.refreshScrape();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))),
        title: Column(
          children: [
            Text(
              "Unstable network",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Stack: ${tracker.exceptionStack}",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              "$actionMsg$secondsLeft...",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            )
          ],
        ),
        content: Container(
          width: 250,
          child: actionStarted
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
  final String? exception;

  const ErrorDialog({Key? key, required this.title, this.exception})
      : super(key: key);

  @override
  _ErrorDialogState createState() => _ErrorDialogState();
}

class _ErrorDialogState extends State<ErrorDialog> {
  late Timer countdown;
  int secondsToRefresh = 5;
  bool loggingOut = false;

  @override
  void initState() {
    // Start Timer!
    countdown = Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
    super.initState();
  }

  // Countdown method
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0))),
        title: Column(
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: EdgeInsets.only(top: 2, bottom: 2),
              child: Column(
                children: [
                  Text(
                    "LOG: ${widget.exception}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic),
                  ),
                  Text(
                    "Screenshot this and report to an app admin.\n"
                    "Logging out in $secondsToRefresh...",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  )
                ],
              ),
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
