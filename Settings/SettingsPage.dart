///
/// Page Widget to implement SettingsContents.dart
///

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../Data/AppData.dart';

class SettingsPage extends StatelessWidget {
  final String title;
  final Widget content;

  const SettingsPage({Key? key, required this.title, required this.content})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // should be 1/9 flexible value
            Flexible(
              flex: 1,
              child: Container(
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 10, top: 15),
                      alignment: Alignment.topLeft,
                      child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(FontAwesomeIcons.rotateLeft,
                              color: Colors.black)),
                    ),
                    Container(
                      alignment: Alignment.bottomCenter,
                      child: Text(title, style: TextStyle(fontSize: 24)),
                    )
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 9,
              child: content,
            ),
            Flexible(
              flex: 1,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("V " + System.of(context).version,
                        style:
                        TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                    Text(
                        "Last Updated " +
                            DateFormat.yMMMd('en_US')
                                .format(System.of(context).lastUpdated)
                                .toString(),
                        style:
                        TextStyle(fontSize: 14, color: Colors.grey.shade600))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
