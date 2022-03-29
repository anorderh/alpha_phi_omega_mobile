import 'package:flutter/material.dart';
import '../Backend/apo_objects.dart';
import '../http_Directory/httpEvents.dart' as httpEvent;
import '../EventPage/ParticipantTiles.dart';
import 'EventButton.dart';

class EventSingle extends StatefulWidget {
  final EventFull event;
  final String username;

  EventSingle(this.event, this.username);

  @override
  _EventSingleState createState() => _EventSingleState();
}

class _EventSingleState extends State<EventSingle> {
  bool userJoined = false;
  int userIndex = -1;
  int quantity = 0;

  @override
  void initState() {
    super.initState();
    List<Participant> people = widget.event.participants;
    quantity = people.length;

    for (int i = 0; i < quantity; i++) {
      if (people[i].name == widget.username) {
        userIndex = i;
        userJoined = true;
        break;
      }
    }
  }

  Widget info() {
    return Column(children: <Widget>[
      Padding(
          padding: const EdgeInsets.all(3),
          child: Text(widget.event.cred ?? 'n/a')),
      Padding(
          padding: const EdgeInsets.all(3),
          child: Text(widget.event.date ?? 'n/a')),
      Padding(
          padding: const EdgeInsets.all(3),
          child: Text(widget.event.loc ?? 'n/a')),
      Padding(
          padding: const EdgeInsets.all(3),
          child: Text(widget.event.desc ?? 'n/a')),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(widget.event.title),
            backgroundColor: Colors.deepPurple),
        body: ListView(
          children: [
            EventButton(userJoined: userJoined, join: joinEvent, leave: leaveEvent),
            ParticipantTiles(participants: widget.event.participants),
            info()],
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
        ));
  }

  void joinEvent() async {
    httpEvent.addSelf(widget.event.id, '', 0, 3);
    setState(() {
      userJoined = true;
      widget.event.participants.add(Participant(widget.username, 'N/A'));
      userIndex = quantity;
      quantity += 1;
    });
  }

  void leaveEvent() async {
    httpEvent.removeSelf(widget.event.id);
    setState(() {
      userJoined = false;
      widget.event.participants.removeAt(userIndex);
      userIndex = -1;
      quantity -= 1;
    });
  }
}
