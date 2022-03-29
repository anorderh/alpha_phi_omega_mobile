import 'package:flutter/material.dart';
import '../Backend/apo_objects.dart';
import 'InboxBar.dart';
import 'MailList.dart';

class Inbox extends StatefulWidget {
  List<Mail> received, sent;

  Inbox({Key? key, required this.received, required this.sent})
      : super(key: key);

  @override
  _InboxState createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  late List<Widget> inboxTabs;
  late List<bool> _selections;
  late int _selectedIndex;
  late Widget loadBox;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadBox = const SizedBox.shrink();
    inboxTabs = [
      MailList(mail: widget.received, scrollPhysics: NeverScrollableScrollPhysics()),
      const Text('sent')
    ];

    _selections = List.filled(inboxTabs.length, false);
    _selectedIndex = 0;
    _selections[_selectedIndex] = true;
  }

  void selectTab(int index) {
    setState(() {
      _selectedIndex = index;
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

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(5),
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                InboxBar(selections: _selections, select: selectTab),
                inboxTabs[_selectedIndex]
              ],
            ),
            loadBox
          ],
        ));
  }
}
