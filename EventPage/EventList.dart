import 'package:flutter/material.dart';
import '../Backend/apo_objects.dart';
import 'EventSolo.dart';
import 'Events.dart';

class EventList extends StatefulWidget {
  Future<dynamic> events;
  Function loading;
  String name;
  ScrollPhysics scrollPhysics;

  EventList(
      {Key? key,
      required this.events,
      required this.loading,
      required this.name,
      required this.scrollPhysics})
      : super(key: key);

  @override
  _EventListState createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  void viewEvent(String eventLink) async {
    widget.loading(true);
    EventFull event = await handle_event(eventLink, EventFull);
    widget.loading(false);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EventSingle(event, widget.name)));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: widget.events,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState.index == 3) {
            if (snapshot.data.toString() == '[]') {
              return const Center(child: Text('No events found'));
            } else {
              return ListView.builder(
                  physics: widget.scrollPhysics,
                  itemCount: snapshot.data.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    EventMinimal event = snapshot.data[index];
                    return Card(
                        child: Row(children: <Widget>[
                      Expanded(
                          child: ListTile(
                              title: Text(event.title),
                              subtitle: Text(event.date ?? 'n/a'))),
                      IconButton(
                          icon: const Icon(Icons.pending),
                          onPressed: () {
                            viewEvent(event.link);
                          })
                    ]));
                  });
            }
          } else {
            return const SizedBox(
                width: 60,
                height: 60,
                child: Center(child: CircularProgressIndicator()));
          }
        });
  }
}
