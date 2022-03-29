import 'package:flutter/material.dart';
import 'EventSolo.dart';
import '../Backend/apo_objects.dart';
import 'package:example/EventPage/Events.dart';
import 'package:example/EventPage/EventList.dart';
import 'dart:convert';

class EventPage extends StatefulWidget {
  final Map<String, dynamic> userDetails;

  EventPage(this.userDetails);

  @override
  EventPageState createState() => EventPageState();
}

class EventPageState extends State<EventPage> {
  TextEditingController monthC = TextEditingController();
  TextEditingController dayC = TextEditingController();
  TextEditingController yearC = TextEditingController();
  Map lastInput = {'month': 1, 'day': 1, 'year': 1};
  bool loading = false;
  late Widget loadBox;
  Future<dynamic> events = Future.value(null);

  @override
  void initState() {
    super.initState();
    events = pull_events(1, 1, 1);
    loadBox = const SizedBox.shrink();
  }

  void initiateLoading(bool input) {
    setState(() {
      if (input) {
        loadBox = Container(
            color: const Color.fromRGBO(99, 99, 99, 0.8),
            child: const Padding(
                padding: EdgeInsets.all(5),
                child: CircularProgressIndicator()));
      } else {
        loadBox = const SizedBox.shrink();
      }
    });
  }

  Widget postEventPage({fail = false}) {
    if (yearC.text == "" || monthC.text == "" || dayC.text == "") {
      return const Center(child: Text('Specify the date'));
    } else if ((lastInput['month'] != int.parse(monthC.text)) ||
        (lastInput['day'] != int.parse(dayC.text)) ||
        (lastInput['year'] != int.parse(yearC.text))) {
      return const Center(child: Text('Press \"Find Events\"'));
    }

    return EventList(
      events: events,
      loading: initiateLoading,
      name: widget.userDetails['name'],
      scrollPhysics: const AlwaysScrollableScrollPhysics(),
    );
  }

  void find() async {
    setState(() {
      try {
        lastInput['month'] = int.parse(monthC.text);
        lastInput['day'] = int.parse(dayC.text);
        lastInput['year'] = int.parse(yearC.text);

        events = pull_events(int.parse(monthC.text), int.parse(dayC.text),
            int.parse(yearC.text));
        // ERROR! WHEN 1-1-1 IS CHANGED TO VALID DATE & TEXT UNFOCUSED, TEXT APPEARS
        // SAYING "no events found". THIS IS DUE TO postEvents() DEPENDING ON CONTROLLERS
        // LOOK INTO THIS MORE
      } on FormatException {}
    });

    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: <Widget>[
          const Align(
            alignment: Alignment.topCenter,
            child: Text("Event Catalog", style: TextStyle(fontSize: 20)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 20)),
            onPressed: find,
            child: const Text('Find events'),
          ),
          Row(children: <Widget>[
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: TextField(
                        controller: monthC,
                        decoration: InputDecoration(
                            label: const Text('Month'),
                            enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    width: 3, color: Colors.blue),
                                borderRadius: BorderRadius.circular(15)))))),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: TextField(
                        controller: dayC,
                        decoration: InputDecoration(
                            label: const Text('Day'),
                            enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    width: 3, color: Colors.blue),
                                borderRadius: BorderRadius.circular(15)))))),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: TextField(
                        controller: yearC,
                        decoration: InputDecoration(
                            label: const Text('Year'),
                            enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                    width: 3, color: Colors.blue),
                                borderRadius: BorderRadius.circular(15)))))),
          ]),
          Expanded(
              child: Stack(
            children: <Widget>[postEventPage(), loadBox],
          ))
        ],
      ),
    );
  }
}
