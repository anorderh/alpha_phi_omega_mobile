import 'package:flutter/material.dart';

class MailTutorial extends StatelessWidget {
  MailTutorial({Key? key}) : super(key: key);

  TextStyle title = const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black,
      fontStyle: FontStyle.italic);
  TextStyle heading =
      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black);
  TextStyle highlight = const TextStyle(
      fontSize: 14, color: Colors.black, backgroundColor: Colors.yellowAccent);
  TextStyle normal = const TextStyle(fontSize: 14, color: Colors.black);

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Container(
      padding: EdgeInsets.all(3),
      child: Column(children: <Widget>[
        Text("How to Use Mail", style: title),
        RichText(
            text: TextSpan(style: normal, children: <TextSpan>[
          TextSpan(text: '    The purpose of the '),
          TextSpan(text: 'Mail ', style: heading),
          TextSpan(text: 'tab is for Brothers to send and receive '),
          TextSpan(text: 'event invites', style: highlight),
          TextSpan(text: ' amongst each other.')
        ])),
        RichText(
          text: TextSpan(style: normal, children: <TextSpan>[
            TextSpan(text: '1.', style: heading),
            TextSpan(text: ' The Mail tab consists of two pages: '),
            TextSpan(text: 'Inbox', style: highlight),
            TextSpan(text: ' and '),
            TextSpan(text: 'Sent', style: highlight),
            TextSpan(
                text:
                    '. To switch between them, swipe left and right on the tab\'s contents')
          ]),
        ),
        RichText(
          text: TextSpan(style: normal, children: <TextSpan>[
            TextSpan(text: '2.', style: heading),
            TextSpan(
                text: ' Each piece of mail is represented by a square tile. '),
            TextSpan(text: 'To open them, simply tap on the tile. '),
          ]),
        ),
        Text("There are 4 types of mail:", style: heading),
      ]),
    ));
  }
}
