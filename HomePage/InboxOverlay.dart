import 'package:flutter/material.dart';
import 'InboxHelper.dart';

class InboxOverlay extends StatefulWidget {
  String header;

  InboxOverlay(this.header, {Key? key}) : super(key: key);

  @override
  _InboxOverlayState createState() => _InboxOverlayState();
}

class _InboxOverlayState extends State<InboxOverlay> {
  late Widget infoButton;
  late Widget composeButton;
  late Widget header;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    infoButton = getInfoButton();
    composeButton = getComposeButton();
    header = getHeader(widget.header);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          children: <Widget>[header, Spacer(), composeButton, infoButton],
        ));
  }
}
