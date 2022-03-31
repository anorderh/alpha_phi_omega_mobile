import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../Backend/apo_objects.dart';
import 'MailList.dart';

class Inbox extends StatefulWidget {
  List<Mail> received, sent;
  void Function(int?) changeOverlay;

  Inbox({Key? key, required this.received, required this.sent, required this.changeOverlay})
      : super(key: key);

  @override
  _InboxState createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  late List<Widget> pages;
  PageController controller = PageController(initialPage: 0);
  bool headerVisible = true;
  late Widget loadBox;
  int mailHeight = 200;

  double mailQuantity() {
    int r = widget.received.length;
    int s = widget.sent.length;

    if (r < 20 && s < 20) {
      if (r < 4 && s < 4) {
        return 2;
      } else {
        if (r < s) {
          return (s/2 + s%2);
        } else {
          return (r/2 + r%2);
        }
      }
    } else {
      return 10;
    }
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
  void initState() {
    // TODO: implement initState
    super.initState();
    headerVisible = true;
    loadBox = const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: (mailQuantity() * mailHeight).toDouble(),
        padding: const EdgeInsets.all(5),
        child: PageView(
            controller: controller,
            onPageChanged: widget.changeOverlay,
            children: [
          Column(children: <Widget>[
            MailList(
                mail: widget.received,
                scrollPhysics: const NeverScrollableScrollPhysics())
          ]),
          Column(
            children: <Widget>[
              MailList(
                  mail: widget.sent,
                  scrollPhysics: const NeverScrollableScrollPhysics())
            ],
          )
        ]));
  }
}
