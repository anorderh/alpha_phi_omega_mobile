import 'package:flutter/material.dart';

Widget getInfoButton() {
  return TextButton(
      onPressed: () {},
      style: ButtonStyle(
          shape: MaterialStateProperty.all<OutlinedBorder>(CircleBorder()),
          padding:
          MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero)),
      child: Icon(Icons.info, color: Colors.grey.shade700, size: 40));
}

Widget getComposeButton() {
  return TextButton(
      onPressed: () {},
      style: ButtonStyle(
          shape: MaterialStateProperty.all<OutlinedBorder>(CircleBorder()),
          padding:
          MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero)),
      child: Icon(Icons.add, color: Colors.grey.shade700, size: 40));
}

Widget getHeader(String headerTitle) {
  return FittedBox(
    fit: BoxFit.fill,
    child: Container(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(35.0)),
            color: Colors.blue),
        child: Text(
          headerTitle,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        )),
  );
}