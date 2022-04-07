import 'package:flutter/material.dart';
import 'package:example/Backend/database.dart';

TextStyle title = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontStyle: FontStyle.italic);

TextStyle heading = const TextStyle(
    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black);

TextStyle highlight = const TextStyle(
    fontSize: 14, color: Colors.black, backgroundColor: Colors.yellowAccent);

TextStyle normal = const TextStyle(fontSize: 14, color: Colors.black);

Widget getInfoButton(BuildContext context) {
  return TextButton(
      onPressed: () {
        showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => helpScreen);
      },
      style: ButtonStyle(
          shape: MaterialStateProperty.all<OutlinedBorder>(CircleBorder()),
          padding:
              MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero)),
      child: Icon(Icons.info, color: Colors.grey.shade700, size: 40));
}

Widget getComposeButton(String header, Function compose) {
  if (header == 'INBOX') {
    return TextButton(
        onPressed: () {
          compose();
          getTotalBrothers();
        },
        style: ButtonStyle(
            shape: MaterialStateProperty.all<OutlinedBorder>(CircleBorder()),
            padding:
                MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero)),
        child: Icon(Icons.add, color: Colors.grey.shade700, size: 40));
  }
  return SizedBox.shrink();
}

Widget getHeader(String headerTitle) {
  return FittedBox(
    fit: BoxFit.fill,
    child: Container(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(35.0)),
            color: Colors.blue),
        child: Text(
          headerTitle,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        )),
  );
}

Widget helpScreen = AlertDialog(
  insetPadding: EdgeInsets.all(100),
    content: Builder(
      builder: (context) {
        return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(3),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
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
                    TextSpan(text: ' Each piece of mail is represented by a square tile. '),
                    TextSpan(text: 'To open them, simply tap on the tile. '),
                  ]),
                ),
                Text("There are 4 types of mail:", style: heading),
              ]),
        );
      },

    ));
