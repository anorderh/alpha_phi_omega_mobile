import 'package:example/HomePage/ComposeBox.dart';
import 'package:flutter/material.dart';
import 'InboxHelper.dart';

class InboxOverlay extends StatefulWidget {
  String header;
  Map<String, dynamic> composeDetails;

  InboxOverlay(this.header, this.composeDetails, {Key? key}) : super(key: key);

  @override
  _InboxOverlayState createState() => _InboxOverlayState();
}

class _InboxOverlayState extends State<InboxOverlay> {
  void composeMessage() async {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ComposeBox(
                  events: widget.composeDetails['events'],
                  sender: widget.composeDetails['sender'],
                  imageUrl: widget.composeDetails['imageUrl'],
                )));
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          children: <Widget>[
            getHeader(widget.header),
            Spacer(),
            getComposeButton(widget.header, composeMessage),
            getInfoButton(context)
          ],
        ));
  }
}
