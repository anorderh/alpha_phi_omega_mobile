///
/// Internal objects for APOM
///

import 'package:flutter/cupertino.dart';

class CredInfo {
  Color color;
  IconData icon;

  CredInfo(this.color, this.icon);
}

class EventFull extends Comparable<EventFull> {
  String title, link, id, cred, loc, desc, creator;
  DateTime date;
  DateTime? start, end;
  DateTime? lock, close;

  EventFull(
      {required this.title,
        required this.link,
        required this.id,
        required this.date,
        this.start,
        this.end,
        this.lock,
        this.close,
        this.cred = 'n/a',
        this.loc = 'n/a',
        this.desc = 'n/a',
        this.creator = 'n/a'});

  @override
  int compareTo(EventFull other) {
    if (date.isAtSameMomentAs(other.date)) {
      // check if both events aren't all-day
      if (start != null && other.start != null) {
        return 0;
      }

      // discern if event times are before & after
      if (start!.isBefore(other.start!)) {
        return -1;
      } else if (start!.isAfter(other.start!)) {
        return 1;
      } else {
        return 0;
      }
    } else {
      // discern if event dates are before or after
      if (date.isBefore(other.date)) {
        return -1;
      } else {
        return 1;
      }
    }
  }
}

class Participant {
  final String name;
  String? comment;
  String? number;
  int? canDrive;

  Participant(this.name, [this.comment, this.number, this.canDrive]);
}

class ChangelogEntry {
  final String version;
  final DateTime updated;
  final List<String> body;

  ChangelogEntry({required this.version, required this.updated, required this.body});
}