import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../RevampLib/AppData.dart';

class AboutApp extends StatelessWidget {
  const AboutApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
                    child: Text("About App", style: TextStyle(fontSize: 24)),
                  )
                ],
              ),
            ),
          ),
          Flexible(
              flex: 8,
              child: Container(
                padding: EdgeInsets.all(10),
                child: Text("This will be where the About App information is."))),
        ],
      ),
    );
  }
}
