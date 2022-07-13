import 'package:flutter/material.dart';
import '../Backend/apo_objects.dart';
import '../http_Directory/httpEvents.dart' as httpEvent;
import '../EventPage/_EventSpec.dart';
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
  late ScrollController descScroll;
  late ScrollController participantScroll;
  int userIndex = -1;
  int quantity = 0;

  @override
  void initState() {
    super.initState();
    descScroll = ScrollController();
    participantScroll = ScrollController();
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
        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: FittedBox(
          fit: BoxFit.contain,
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.fromLTRB(10, 10, 10, 6),
            child: Text(widget.event.title,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 40,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ),
      Card(
        margin: EdgeInsets.fromLTRB(10, 8, 10, 4),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.event,
                    color: Colors.blueGrey,
                  ),
                  Spacer(),
                  Text(widget.event.date ?? 'n/a'),
                  Spacer()
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Row(
                children: <Widget>[
                  Icon(Icons.place, color: Colors.red.shade500),
                  Spacer(),
                  Expanded(
                    child: Text(
                      widget.event.loc ?? 'n/a',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Spacer()
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.bar_chart,
                    color: Colors.green,
                  ),
                  Spacer(),
                  Text(widget.event.cred ?? 'n/a'),
                  Spacer()
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.person,
                    color: Colors.lightBlueAccent,
                  ),
                  Spacer(),
                  Text(widget.event.creator ?? 'n/a'),
                  Spacer()
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Row(
                children: <Widget>[
                  const Icon(
                      Icons.info_outline, color: Colors.orange
                  ),
                  Expanded(
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                        child: Scrollbar(
                          isAlwaysShown: true,
                          controller: descScroll,
                          child: Container(
                            height: 150,
                            child: SingleChildScrollView(
                              controller: descScroll,
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(widget.event.desc ?? 'No description available.')
                              ),
                            ),
                          ),
                        )
                    )
                  ),
                ],
              ),
            )
          ],
        ),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar:
          AppBar(backgroundColor: Colors.blueAccent),
      body: Scrollbar(
          thickness: 5,
          child: SingleChildScrollView(
              child: Column(
            children: <Widget>[
              EventButton(userJoined: userJoined, join: joinEvent, leave: leaveEvent),
              info(),
              ]))),
    );
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
