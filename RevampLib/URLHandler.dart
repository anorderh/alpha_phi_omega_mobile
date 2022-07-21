import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class LinkableText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign align;

  const LinkableText({Key? key, required this.text, required this.style, required this.align}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Linkify(
      textAlign: align,
      text: text,
      style: style,
      onOpen: (link) async {
        if (!await launchUrl(Uri.parse(link.url))) {
          throw 'Could not launch ${link.url}';
        }
      }
    );
  }
}
