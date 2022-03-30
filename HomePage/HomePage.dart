import 'dart:ui';
import 'package:example/EventPage/EventList.dart';
import 'package:flutter/material.dart';
import 'package:example/Backend/apo_objects.dart';
import 'package:example/EventPage/Events.dart';
import 'CreditProgress.dart';
import 'HomeBar.dart';
import 'Inbox.dart';
import 'ProfileHeader.dart';
import 'InboxOverlay.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> userDetails;

  HomePage(this.userDetails);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Widget> homeTabs;
  late List<bool> _selections;
  late int _selectedIndex;
  Future<dynamic> upcoming = Future.value(null);
  late Widget loadBox;
  String inboxHeader = "INBOX";
  late Widget _inboxOverlay;

  void selectTab(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 2) {
        _inboxOverlay = InboxOverlay(inboxHeader);
      } else {
        _inboxOverlay = const SizedBox.shrink();
      }
    });
  }

  void initiateLoading(bool input) {
    setState(() {
      if (input) {
        loadBox = Container(
            color: const Color.fromRGBO(99, 99, 99, 0.8),
            child: const Padding(
                padding: EdgeInsets.all(5),
                child: CircularProgressIndicator()));
      } else {
        loadBox = const SizedBox.shrink();
      }
    });
  }

  void changeInboxOverlay(String header) {
    setState(() {
      inboxHeader = header;
    });
  }

  @override
  void initState() {
    super.initState();
    loadBox = const SizedBox.shrink();
    _inboxOverlay = const SizedBox.shrink();
    upcoming =
        init_event_list(widget.userDetails['upcomingEvents'], EventMinimal);
    homeTabs = <Widget>[
      CreditProgress(progress: widget.userDetails['progress']),
      EventList(
          events: upcoming,
          loading: initiateLoading,
          name: widget.userDetails['name'],
          scrollPhysics: const NeverScrollableScrollPhysics()),
      Inbox(received: [
        Invite(
            title: 'test',
            body: 'abcdefghijklmnopqrstuvwxyz aaaaaaaaaaaaaaaaaaa',
            recipients: [Participant('me', '9999999999')],
            sender: Participant('Anthony Norderhaug', '9999999999'),
            imageUrl: 'https://www.apoonline.org/alphadelta/image.php?id=116140',
            eventLink: 'https://www.apoonline.org/alphadelta/memberhome.php?action=eventsignup&eventid=822690'),
        Mail(
            title: 'test',
            body: 'test',
            recipients: [Participant('me', '9999999999')]),
      ], sent: [], changeOverlay: changeInboxOverlay)
    ];
    _selections = List.filled(homeTabs.length, false);
    _selectedIndex = 0;
    _selections[_selectedIndex] = true;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
            body: SingleChildScrollView(
                physics: const ScrollPhysics(),
                child: Stack(
                  children: <Widget>[
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ProfileHeader(
                            name: widget.userDetails['name'],
                            position: widget.userDetails['position'],
                            imageURL: widget.userDetails['image_url']),
                        HomeBar(selections: _selections, select: selectTab),
                        homeTabs[_selectedIndex],
                      ],
                    ),
                  ],
                ))),
        Container(
          padding: EdgeInsets.fromLTRB(10,10,0,5),
          child: _inboxOverlay,
        )
      ],
    );
  }
}
