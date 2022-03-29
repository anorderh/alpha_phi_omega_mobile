import 'package:flutter/material.dart';

class EventButton extends StatefulWidget {
  bool userJoined;
  final Function join, leave;

  EventButton(
      {Key? key, required this.userJoined, required this.join, required this.leave})
      : super(key: key);

  @override
  _EventButtonState createState() => _EventButtonState();
}

class _EventButtonState extends State<EventButton> {
  @override
  Widget build(BuildContext context) {
    if (!widget.userJoined) {
      return ElevatedButton(
          style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20)),
          onPressed: () {widget.join();},
          child: const Text('Join event')
      );
    } else {
      return ElevatedButton(
          style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20)),
          onPressed: () {widget.leave();},
          child: const Text('Leave event')
      );
    }
  }
}