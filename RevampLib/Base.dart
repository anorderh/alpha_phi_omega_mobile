import 'package:example/EventPage/EventPage.dart';
import 'package:flutter/material.dart';
import '../Homepage/HomePage.dart';
import '../http_Directory/http.dart';
import 'package:example/InterviewTracker/PledgeTracker.dart';
import '../RevampLib/Home.dart';

class Base extends StatefulWidget {
  const Base({Key? key}) : super(key: key);

  @override
  _BaseState createState() => _BaseState();
}

class _BaseState extends State<Base> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Home(),
        bottomNavigationBar: Container(  // BOTTOM NAVIGATION BAR
          width: MediaQuery.of(context).size.width,
          height: 80,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black38.withOpacity(0.5),
                  spreadRadius: -20,
                  blurRadius: 150,
                )
              ]),
          child: Padding(
            padding: EdgeInsets.only(left: 25, right: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconBottomBar(  // HOME BUTTON
                    icon: Icons.home_rounded,
                    selected: _selectedIndex == 0,
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    }),
                IconBottomBar(  // EVENTS BUTTON
                    icon: Icons.event_rounded,
                    selected: _selectedIndex == 1,
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    })
              ],
            ),
          ),
        ));
  }
}

class IconBottomBar extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final Function() onPressed;

  const IconBottomBar(
      {required this.icon,
      required this.selected,
      required this.onPressed,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width/3,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 32, color: selected ? Colors.blue : Colors.grey),
      ),
    );
  }
}
