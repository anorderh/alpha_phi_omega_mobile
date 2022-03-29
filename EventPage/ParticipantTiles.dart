import 'package:example/Backend/apo_objects.dart';
import 'package:flutter/material.dart';

class ParticipantTiles extends StatefulWidget {
  List<Participant> participants;

  ParticipantTiles(
      {Key? key, required this.participants})
      : super(key: key);

  @override
  _ParticipantTilesState createState() => _ParticipantTilesState();
}

class _ParticipantTilesState extends State<ParticipantTiles> {
  @override
  Widget build(BuildContext context) {
    int quantity = widget.participants.length;

    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: quantity,
        itemBuilder: (context, index) {
          if (quantity == 0) {
            return const ListTile(title: Text("No participants!"));
          } else {
            Participant person = widget.participants[index];

            return ListTile(
                title: Text(person.name), subtitle: Text(person.number));
          }
        });
  }
}
