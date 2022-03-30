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
  late bool headerVisible;
  late String header;
  late Widget loadBox;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    header = 'Inbox';
    headerVisible = true;
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

  void pageChange(int index) {
    setState(() {
      if (index == 1) {
        header = 'Sent';
      } else {
        header = 'Inbox';
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
          alignment: Alignment.center,
          children: <Widget>[
            PageView(
                onPageChanged: pageChange,
                controller: controller,
                children: [
                  MailList(
                      mail: widget.received,
                      scrollPhysics: const NeverScrollableScrollPhysics()),
                  MailList(
                      mail: widget.sent,
                      scrollPhysics: const NeverScrollableScrollPhysics())
                ]),
            Align(
              alignment: Alignment.topRight,
              child: AnimatedOpacity(
                  opacity: headerVisible ? 1.0 : 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.blueAccent,
                      ),
                      child: FittedBox(
                          fit: BoxFit.contain,
                          child: Padding(
                            padding: EdgeInsets.all(5),
                            child: Text(
                              header,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          )))),
            ),
            loadBox
          ],
        ));
  }
}
