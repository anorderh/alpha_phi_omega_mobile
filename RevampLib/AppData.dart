import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ReqInfo {
  Color color;
  IconData icon;

  ReqInfo(this.color, this.icon);
}

ReqInfo pullReqInfo(String name) {
  Map<String, ReqInfo> reqLibrary = {
    'Service' : ReqInfo(Colors.red.shade200, FontAwesomeIcons.handshakeAngle),
    'Fellowship' : ReqInfo(Colors.green.shade200, FontAwesomeIcons.peopleGroup),
    'Leadership' : ReqInfo(Colors.purple.shade400, FontAwesomeIcons.flag),
    'Fundraising' : ReqInfo(Colors.pink.shade200, FontAwesomeIcons.moneyBillWave),
    'Interchapter' : ReqInfo(Colors.brown.shade400, FontAwesomeIcons.car),
    'Philanthropy' : ReqInfo(Colors.cyan.shade200, FontAwesomeIcons.children),
    'External Relations' : ReqInfo(Colors.deepPurple.shade400, FontAwesomeIcons.addressCard),
    'Special Fellowship' : ReqInfo(Colors.blue.shade500, FontAwesomeIcons.star),
    'Required Events' : ReqInfo(Colors.lime.shade500, FontAwesomeIcons.calendarCheck),
    'Open Forum' : ReqInfo(Colors.red.shade600, FontAwesomeIcons.comments),
    'Chair' : ReqInfo(Colors.lightBlueAccent.shade200, FontAwesomeIcons.chair),
    'Academic' : ReqInfo(Colors.pinkAccent, FontAwesomeIcons.graduationCap),
    'Meeting' : ReqInfo(Colors.orange.shade400, FontAwesomeIcons.chalkboardUser)
  };

  return reqLibrary[name] ?? ReqInfo(Colors.grey.shade500, FontAwesomeIcons.folder);
}