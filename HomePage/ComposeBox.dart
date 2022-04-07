import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:example/Backend/database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'BrotherSelect.dart';

class ComposeBox extends StatefulWidget {
  Map<String, String> events;
  String sender;
  String imageUrl;

  ComposeBox(
      {required this.events,
      required this.sender,
      required this.imageUrl,
      Key? key})
      : super(key: key);

  @override
  _ComposeBoxState createState() => _ComposeBoxState();
}

class _ComposeBoxState extends State<ComposeBox> {
  String? selectedEvent = "";
  late List<String> eventList;
  late Text selectedBrother;
  late TextEditingController commentController;

  void openSelection() async {
    Map<String, Map<String, String>> repo = await getTotalBrothers();

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => BrotherSelection(
                  info: repo,
                  choose: pullBrother,
                )));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    eventList = widget.events.keys.toList();
    selectedEvent = eventList[0];
    commentController = TextEditingController();
    selectedBrother = const Text(
      "No brothers selected.",
      overflow: TextOverflow.ellipsis,
    );
  }

  void pullBrother(Text nameWidget) {
    setState(() {
      selectedBrother = nameWidget;
    });
  }

  void sendInvite() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("ComposeBox test"), backgroundColor: Colors.blueAccent),
      body: Dialog(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(5),
            color: Colors.blue,
            child: const Text(
              "Invite",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Flexible(
            child: Padding(
                padding: EdgeInsets.all(15),
                child: Row(
                  children: <Widget>[
                    const Expanded(
                      child: Text("Event: ",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black)),
                    ),
                    SizedBox(
                      width: 200,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2(
                          isExpanded: true,
                          buttonPadding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                          buttonDecoration: BoxDecoration(
                              color: Color.fromRGBO(0, 100, 255, 0.05),
                              border:
                                  Border.all(width: 1, color: Colors.black)),
                          hint: Text(
                            'Select Item',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          items: eventList
                              .map((title) => DropdownMenuItem<String>(
                                    value: title,
                                    child: Text(
                                      title,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  ))
                              .toList(),
                          value: selectedEvent,
                          onChanged: (value) {
                            setState(() {
                              selectedEvent = (value as String);
                            });
                          },
                          buttonHeight: 30,
                          buttonWidth: 180,
                          itemHeight: 30,
                        ),
                      ),
                    )
                  ],
                )),
          ),
          Flexible(
            child: Padding(
                padding: EdgeInsets.all(15),
                child: Row(
                  children: <Widget>[
                    const Expanded(
                      child: Text("Recipient: ",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black)),
                    ),
                    SizedBox(
                      width: 200,
                      child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(0, 100, 255, 0.05),
                              primary: Colors.grey,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(0))),
                              side: const BorderSide(
                                  width: 0.8, color: Colors.black)),
                          onPressed: openSelection,
                          child: Padding(
                              padding: EdgeInsets.all(10),
                              child: selectedBrother)),
                    )
                  ],
                )),
          ),
          Flexible(
            child: Padding(
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: commentController,
                  decoration: const InputDecoration(
                      filled: true,
                      hintText: "Leave a comment (optional):",
                      fillColor: Color.fromRGBO(0, 100, 255, 0.05),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(Radius.zero)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(Radius.zero))),
                  maxLines: 4,
                )),
          ),
          Flexible(
            child: Padding(
              padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(2),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.yellow.shade800),
                        child: Icon(Icons.highlight_remove),
                        onPressed: () {},
                      ),
                    ),
                  ),
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.all(2),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.blue),
                      child: Icon(Icons.send),
                      onPressed: (selectedBrother.data == 'No brothers selected.' ? null : sendInvite),
                    ),
                  ))
                ],
              ),
            ),
          )
        ],
      )),
    );
  }
}
