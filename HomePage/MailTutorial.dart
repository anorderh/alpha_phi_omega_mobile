import 'package:flutter/material.dart';

class MailTutorial extends StatelessWidget {
  MailTutorial({Key? key}) : super(key: key);

  TextStyle headingStyle =
      TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(3),
        child: Row(
          children: <Widget>[
            Text("How to Use Mail",
                style: headingStyle),
            RichText(
                text: TextSpan(
                    style: TextStyle(fontSize: 12, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(text: 'The '),
                      TextSpan(text: 'Mail ', style: headingStyle),
                      TextSpan(text: 'tab is used to receive and send event invites between brothers, '),
                      TextSpan(text: 'as well as notifications from APOM\'s servers'),
                    ]))
          ],
        ),
      ),
    );
  }
}
