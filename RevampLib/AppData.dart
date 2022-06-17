import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CredInfo {
  Color color;
  IconData icon;

  CredInfo(this.color, this.icon);
}

class EventMini {
  String title, link, cred, start, end;
  DateTime date;

  EventMini(
      {required this.title,
      required this.link,
      required this.date,
      this.cred = "None",
      this.start = "None",
      this.end = "None"});
}

class EventFull extends EventMini {
  String loc, desc, creator;
  List<Participant> participants;

  EventFull(
      {required title,
      required link,
      required date,
      cred = "None",
      start = "None",
      end = "None",
      required this.loc,
      required this.desc,
      required this.creator,
      required this.participants})
      : super(
            title: title,
            link: link,
            date: date,
            cred: cred,
            start: start,
            end: end);
}

class Participant {
  final String name;
  String comment;

  Participant(this.name, [this.comment = 'n/a']);
}

Map<int, String> weekdayLibrary = {
  1: 'M',
  2: 'T',
  3: 'W',
  4: 'Th',
  5: 'F',
  6: 'Sa',
  7: 'Su'
};

Map<String, CredInfo> reqLibrary = {
  'Service': CredInfo(Colors.red, FontAwesomeIcons.handshakeAngle),
  'Fellowship': CredInfo(Colors.green, FontAwesomeIcons.peopleGroup),
  'Leadership': CredInfo(Colors.purple, FontAwesomeIcons.flag),
  'Fundraising':
  CredInfo(Colors.pink, FontAwesomeIcons.moneyBillWave),
  'Interchapter': CredInfo(Colors.brown, FontAwesomeIcons.car),
  'Philanthropy': CredInfo(Colors.cyan, FontAwesomeIcons.children),
  'External Relations':
  CredInfo(Colors.deepPurple, FontAwesomeIcons.addressCard),
  'Special Fellowship': CredInfo(Colors.blue, FontAwesomeIcons.star),
  'Required Events':
  CredInfo(Colors.lime, FontAwesomeIcons.calendarCheck),
  'Open Forum': CredInfo(Colors.red.shade900, FontAwesomeIcons.comments),
  'Chair': CredInfo(Colors.lightBlueAccent, FontAwesomeIcons.chair),
  'Academic': CredInfo(Colors.pinkAccent, FontAwesomeIcons.graduationCap),
  'Meeting': CredInfo(Colors.orange, FontAwesomeIcons.chalkboardUser)
};

CredInfo pullCredInfo(String name) {
  for (MapEntry entry in reqLibrary.entries) {
    if (name.toUpperCase().contains(entry.key.toUpperCase())) {
      return entry.value;
    }
  }

  return CredInfo(Colors.grey.shade500, FontAwesomeIcons.folder);
}
