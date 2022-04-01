import 'package:flutter/material.dart';
import 'InboxHelper.dart';

class InboxOverlay extends StatefulWidget {
  String header;

  InboxOverlay(this.header, {Key? key}) : super(key: key);

  @override
  _InboxOverlayState createState() => _InboxOverlayState();
}

class _InboxOverlayState extends State<InboxOverlay> {

  void composeMessage() async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EventSingle(eventFull, widget.name)));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          children: <Widget>[getHeader(widget.header), Spacer(), getComposeButton(widget.header), getInfoButton(context)],
        ));
  }
}
