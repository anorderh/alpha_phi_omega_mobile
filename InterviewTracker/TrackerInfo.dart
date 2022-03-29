import 'package:flutter/material.dart';

class TrackerInfo extends StatefulWidget {
  int m, s, i;

  TrackerInfo(
      {Key? key,
      required this.m,
      required this.s,
      required this.i})
      : super(key: key);

  @override
  _TrackerInfoState createState() => _TrackerInfoState();
}

class _TrackerInfoState extends State<TrackerInfo> {
  late int messaged, scheduled, interviewed;

  @override
  void initState() {
    super.initState();
    messaged = widget.m;
    scheduled = widget.s;
    interviewed = widget.i;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Align(
          alignment: Alignment.topCenter,
          child: Padding(
              padding: EdgeInsets.fromLTRB(0, 25, 0, 0),
              child: Text("Pledge Tracker", style: TextStyle(fontSize: 20)))),
      Padding(
        padding: EdgeInsets.all(15),
        child: Column(children: <Widget>[
          Text("Messaged: $messaged", style: const TextStyle(fontSize: 16)),
          Text("Scheduled: $scheduled", style: const TextStyle(fontSize: 16)),
          Text("Interviewed: $interviewed",
              style: const TextStyle(fontSize: 16))
        ]),
      )
    ]);
  }
}
