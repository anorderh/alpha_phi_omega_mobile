import 'package:example/Backend/apo_objects.dart';
import 'package:flutter/material.dart';

class ParticipantTiles extends StatefulWidget {
  List<Participant> participants;

  ParticipantTiles({Key? key, required this.participants}) : super(key: key);

  @override
  _ParticipantTilesState createState() => _ParticipantTilesState();
}

class _ParticipantTilesState extends State<ParticipantTiles> {
  Color tileColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    int quantity = widget.participants.length;

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
        ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: quantity,
            itemBuilder: (context, index) {
              if (quantity == 0) {
                return const ListTile(title: Text("No participants!"));
              } else {
                Participant person = widget.participants[index];
                tileColor =
                (index % 2 == 1) ? Colors.white : Colors.blue.shade50;

                return ListTile(
                    tileColor: tileColor,
                    title: Text(person.name),
                    subtitle: Text(
                      person.number,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    trailing: Container(
                      alignment: Alignment.centerRight,
                      width: 150,
                      child: Text(person.comment, textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14)),
                    ));
              }
            })
      ],
    );
  }
}
