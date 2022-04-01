import 'package:flutter/material.dart';
import 'package:example/Backend/apo_objects.dart';
import 'EventList.dart';

class EventTile extends StatefulWidget {
  EventMinimal event;
  Function eventCallback;

  EventTile(this.event, this.eventCallback, {Key? key}) : super(key: key);

  @override
  _EventTileState createState() => _EventTileState();
}

class _EventTileState extends State<EventTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
        child: Row(children: <Widget>[
          Expanded(
              child: ListTile(
                  title: Text(widget.event.title),
                  subtitle: Text(widget.event.date ?? 'n/a'))),
          IconButton(
              icon: const Icon(Icons.pending),
              onPressed: () {
                widget.eventCallback(widget.event);
              })
        ]));
  }
}
