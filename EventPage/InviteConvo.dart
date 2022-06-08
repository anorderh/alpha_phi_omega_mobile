import 'package:flutter/material.dart';

class InviteConvo extends StatefulWidget {
  Map<String, String> senderInfo;
  Map<String, String> recipientInfo;
  Function accept;

  InviteConvo({required this.accept,
    required this.senderInfo,
    required this.recipientInfo,
    Key? key})
      : super(key: key);

  @override
  _InviteConvoState createState() => _InviteConvoState();
}

class _InviteConvoState extends State<InviteConvo> {
  @override
  Widget build(BuildContext context) {
    return Container(
    );


    // Flexible(
    //   child: Padding(
    //     padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
    //     child: Row(
    //       children: <Widget>[
    //         Expanded(
    //           child: Padding(
    //             padding: EdgeInsets.all(2),
    //             child: ElevatedButton(
    //               style: ElevatedButton.styleFrom(
    //                   primary: Colors.yellow.shade800),
    //               child: Icon(Icons.highlight_remove),
    //               onPressed: () {},
    //             ),
    //           ),
    //         ),
    //         Expanded(
    //             child: Padding(
    //               padding: EdgeInsets.all(2),
    //               child: ElevatedButton(
    //                 style: ElevatedButton.styleFrom(primary: Colors.blue),
    //                 child: Icon(Icons.send),
    //                 onPressed: (selectedBrother.data == 'No brothers selected.'
    //                     ? null
    //                     : sendInvite),
    //               ),
    //             ))
    //       ],
    //     ),
    //   ),
    // )
  }
}

