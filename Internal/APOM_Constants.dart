///
/// Internal constants for APOM
///

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'APOM_Objects.dart';

String profile_action = "action=profile";
int refreshDefault = 3;

Map<int, String> weekdayLibrary = {
  1: 'M',
  2: 'T',
  3: 'W',
  4: 'Th',
  5: 'F',
  6: 'Sa',
  7: 'Su'
};

Map<String, Map<String, CredInfo>> chapterLibrary = {
  "Alpha Delta": {
    'Service': CredInfo(Colors.red, FontAwesomeIcons.handshakeAngle),
    'Special': CredInfo(Colors.blue, FontAwesomeIcons.star),
    'Fellowship': CredInfo(Colors.green, FontAwesomeIcons.peopleGroup),
    'Leadership': CredInfo(Colors.purple, FontAwesomeIcons.flag),
    'Fundraising': CredInfo(Colors.pink, FontAwesomeIcons.moneyBillWave),
    'Interchapter': CredInfo(Colors.brown, FontAwesomeIcons.car),
    'Philanthropy':
    CredInfo(Colors.cyanAccent.shade700, FontAwesomeIcons.children),
    'External Relations':
    CredInfo(Colors.deepPurple, FontAwesomeIcons.addressCard),
    'Required': CredInfo(Colors.lime[900]!, FontAwesomeIcons.calendarCheck),
    'Open Forum': CredInfo(Colors.red.shade900, FontAwesomeIcons.comments),
    'Chair': CredInfo(Colors.lightBlueAccent, FontAwesomeIcons.chair),
    'Academic': CredInfo(Colors.pinkAccent, FontAwesomeIcons.graduationCap),
    'Meeting': CredInfo(Colors.orange, FontAwesomeIcons.chalkboardUser),
    'Study': CredInfo(Colors.orangeAccent, FontAwesomeIcons.school)
  },
};

Map<String, String> greekAlphabet = {
  "Alpha": 'Α',
  "Beta": 'Β',
  "Gamma": 'Γ',
  "Delta": 'Δ',
  'Epsilon': 'Ε',
  'Zeta': 'Ζ',
  'Eta': 'Η',
  'Theta': 'Θ',
  'Iota': 'Ι',
  'Kappa': 'Κ',
  'Lambda': 'Λ',
  'Mu': 'Μ',
  'Nu': 'Ν',
  'Xi': 'Ξ',
  'Omicron': 'Ο',
  'Pi': 'Π',
  'Rho': 'Ρ',
  'Sigma': 'Σ',
  'Tau': 'Τ',
  'Upsilon': 'Υ',
  'Phi': 'Φ',
  'Chi': 'Χ',
  'Psi': 'Ψ',
  'Omega': 'Ω'
};

CredInfo pullCredInfo(String name, String chapter) {
  for (MapEntry entry in chapterLibrary[chapter]!.entries) {
    if (name.toUpperCase().contains(entry.key.toUpperCase())) {
      return entry.value;
    }
  }

  return CredInfo(Colors.grey.shade500, FontAwesomeIcons.folder);
}