import 'package:example/EventPage/EventPage.dart';
import 'package:flutter/material.dart';
import '../Homepage/HomePage.dart';
import '../http_Directory/http.dart';
import 'package:example/InterviewTracker/PledgeTracker.dart';

class Nav extends StatefulWidget {
  final Map<String, dynamic> userDetails;

  Nav(this.userDetails);

  @override
  _NavState createState() => _NavState();
}

class _NavState extends State<Nav> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    _widgetOptions = <Widget>[
      HomePage(widget.userDetails),
      Text('Families Screen'),
      EventPage(widget.userDetails),
      Tracker()
      // Tracker()
    ];
    super.initState();
  }
  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alpha Phi Omega'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
              ),
              label:
              'Profile'
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.family_restroom,
            ),
            label:
              'Families'
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.event,
            ),
            label:
              'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.pending_actions,
            ),
            label:
            'Pledge Tracker',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTap,
        selectedFontSize: 13.0,
        unselectedFontSize: 13.0,
        type: BottomNavigationBarType.fixed,
        fixedColor: Colors.blueAccent,
      ),

    );
  }
}
