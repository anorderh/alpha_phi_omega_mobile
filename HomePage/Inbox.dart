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
  late List<Widget> pages;
  PageController controller = PageController(initialPage: 0);
  late Widget loadBox;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadBox = const SizedBox.shrink();
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
      width: 5000,
        height: 5000,
        padding: const EdgeInsets.all(5),
        child: Stack(
          children: <Widget>[
            PageView(
                controller: controller,
                children: [
                  MailList(mail: widget.received, scrollPhysics: const NeverScrollableScrollPhysics()),
                  MailList(mail: widget.sent, scrollPhysics: const NeverScrollableScrollPhysics())
                ]
            ),
            loadBox
          ],
        ));
  }
}
