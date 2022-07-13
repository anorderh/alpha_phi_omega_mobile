import 'package:flutter/material.dart';
import 'package:example/RevampLib/AppData.dart';

class ParticipantList extends StatefulWidget {
  String eventLink;

  ParticipantList({Key? key, required this.eventLink}) : super(key: key);

  @override
  _ParticipantListState createState() => _ParticipantListState();
}

class _ParticipantListState extends State<ParticipantList> {
  Color tileColor = Colors.white;
  late Map<int, Participant> participants;

  List<ListTile> retrieveTiles() {
    List<ListTile> tiles = [];

    if (participants.isEmpty) {
      tiles.add(
          ListTile(tileColor: tileColor, title: Text("No participants!"))
      );
    } else {
      for (Participant person in participants.values) {
        tileColor =
        (tileColor == Colors.white) ? Colors.blue.shade50 : Colors.white;

        tiles.add(
            ListTile(
                tileColor: tileColor,
                title: Text(person.name),
                trailing: Container(
                  alignment: Alignment.centerRight,
                  width: 150,
                  child: person.comment != null ?
                  Text(person.comment!, textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14)) : Container(),
                ))
        );
      }
    }

    return tiles;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: MediaQuery
              .of(context)
              .size
              .width,
          padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
          color: Colors.blue,
          child: Row(
            children: const <Widget>[
              Text("Event Attendees",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Spacer(),
              Text("Comments",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold))
            ],
          ),
        ),
        Column(
          children: retrieveTiles(),
        )
      ],
    );
  }
}
