import 'package:flutter/material.dart';

class InboxBar extends StatefulWidget {
  List<bool> selections;
  Function select;

  InboxBar({Key? key, required this.selections, required this.select})
      : super(key: key);

  @override
  _InboxBarState createState() => _InboxBarState();
}

class _InboxBarState extends State<InboxBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      width: MediaQuery.of(context).size.width,
      child: ToggleButtons(
        children: <Widget>[
          Container(
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    children: const <Widget>[
                      Text("INBOX",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Icon(Icons.markunread_mailbox)
                    ],
                  ))),
          Container(
              padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
              child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    children: const <Widget>[
                      Text("SENT",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Icon(Icons.outgoing_mail)
                    ],
                  )))
        ],
        isSelected: widget.selections,
        color: Colors.grey,
        selectedColor: Colors.blueAccent,
        renderBorder: false,
        onPressed: (int index) {
          setState(() {
            for (int i = 0; i < widget.selections.length; i++) {
              if (i == index) {
                widget.selections[i] = true;
              } else {
                widget.selections[i] = false;
              }
            }

            widget.select(index);
          });
        },
      )
    );
  }
}
