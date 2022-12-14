///
/// Constant values for app documentation
///  **MODIFY THESE AFTER MAKING UPDATES***
///

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'APOM_Objects.dart';

// SYSTEM INFO

String version = "1.0.4"; // When changing version, update in pubspec.yaml too.
DateTime lastUpdated = DateTime(2022, 8, 6);
String helpEmail = 'mailto:apomfeedback@gmail.com';

// CHANGE LOG

List<ChangelogEntry> changelog = [
  ChangelogEntry(
      version: "1.0",
      updated: DateTime(2022, 8, 6),
      body: ["APOM's 1st release!"]),
];

// PACKAGES USED

List<String> packagesUsed = [
  "Flutter HTTP",
  "Font Awesome Flutter",
  "Beautiful Soup Dart",
  "Dropdown Button2",
  "Calendar View",
  "Expandable Page View",
  "Persistent Bottom Nav Bar",
  "URL Launcher",
  "Flutter Linkify",
  "Cached Network Image",
  "Shimmer",
  "Sizer",
  "Smooth Page Indicator",
  "Flutter Secure Storage",
  "Shared Preferences",
  "Provider"
];
