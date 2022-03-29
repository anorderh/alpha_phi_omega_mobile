import 'dart:convert';

import 'package:flutter/material.dart';

class EventMinimal {
  String title, link;
  String? cred, date;

  EventMinimal(this.title, this.cred, this.date, this.link);

  Map<String, dynamic> toJSON() =>
      {'title': title, 'cred': cred, 'date': date, 'link': link};

  @override
  String toString() {
    return '$title\n$cred\n$date';
  }
}

EventMinimal JSONtoEventMinimal(Map data) {
  return EventMinimal(data['title'], data['cred'], data['date'], data['link']);
}

class EventFull extends EventMinimal {
  String? loc, desc, sign, creator;
  int id;
  List<Participant> participants = [];

  EventFull(String title, String? cred, String? date, this.loc, this.desc,
      this.creator, String link, this.id, this.participants)
      : super(title, cred, date, link);

  @override
  Map<String, dynamic> toJSON() =>
      {
        'title': title,
        'cred': cred,
        'date': date,
        'loc': loc,
        'desc': desc,
        'creator': creator,
        'link': link,
        'id': id,
        'participants': participantsToJSON(participants)
      };

  @override
  String toString() {
    return '$title\n$cred\n$date\n$loc\n$desc\n$link\n';
  }
}

EventFull JSONtoEventFull(Map data) {

  return EventFull(
      data['title'],
      data['cred'],
      data['date'],
      data['loc'],
      data['desc'],
      data['creator'],
      data['link'],
      data['id'],
      JSONToParticipants(data['participants']));
}

class Participant {
  final String name;
  String number = 'n/a';

  Participant(this.name, String number) {
    this.number = _format(number);
  }

  String _format(String number) {
    List removeChars = ['(', ')', ' ', '-'];
    for (var char in removeChars) {
      number = number.replaceAll(char, '');
    }

    return '+1' + number;
  }

  Map<String, String> toJSON() => {'name': name, 'number': number};

  @override
  String toString() {
    return '$name';
  }
}

Participant JSONtoParticipant(Map data) {
  return Participant(data['name'], data['number']);
}

List<Map<String, String>> participantsToJSON(List<Participant> participants) {
  List<Map<String, String>> data = [];
  for (Participant person in participants) {
    data.add(person.toJSON());
  }

  return data;
}

List<Participant> JSONToParticipants(List<Map<String, String>> data) {
  List<Participant> participants = [];
  for (Map map in data) {
    participants.add(JSONtoParticipant(map));
  }

  return participants;
}

class Mail {
  String title;
  String body;
  List<Participant> recipients;
  dynamic sender; // can be String or Participant
  String imageUrl;

  Mail({required this.title, required this.body, required this.recipients,
      this.sender = "APOM Alerts", this.imageUrl = 'https://i.ibb.co/7YSq0x8/APO-2.png'});

  Map<String, dynamic> toJSON() {
    return {
      'title': title,
      'body': body,
      'recipients': participantsToJSON(recipients),
      'sender': (sender is Participant) ? sender.toJSON() : sender,
      'imageURL': imageUrl
    };
  }
}

class Invite extends Mail {
  String eventLink;

  Invite({required String title, required String body, required List<Participant> recipients,
      required dynamic sender, required String imageUrl, required this.eventLink})
      : super(title: title, body: body, recipients: recipients, sender: sender, imageUrl: imageUrl);

  @override
  Map<String, dynamic> toJSON() {
    Map<String, dynamic> serialized = super.toJSON();
    serialized['eventlink'] = eventLink;

    return serialized;
  }
}

class Reply extends Mail {
  bool joined;

  Reply({required String title, required String body, required List<Participant> recipients,
      dynamic sender, required String imageUrl, required this.joined})
      : super(title: title, body: body, recipients: recipients, sender: sender, imageUrl: imageUrl);

  @override
  Map<String, dynamic> toJSON() {
    Map<String, dynamic> serialized = super.toJSON();
    serialized['joined'] = joined ? 1 : 0;

    return serialized;
  }
}

Mail createMail(Map data) {

  if (data['eventlink'] != null) {
    return Invite(
      title: data['title'],
      body: data['body'],
      recipients: JSONToParticipants(data['recipients']),
        sender: (data['sender'] is Map) ? JSONtoParticipant(data['sender']) : data['sender'],
      imageUrl: data['imageurl'],
      eventLink: data['eventlink']);
  } else if (data['joined'] != null) {
    return Reply(
        title: data['title'],
        body: data['body'],
        recipients: JSONToParticipants(data['recipients']),
        sender: (data['sender'] is Map)
            ? JSONtoParticipant(data['sender'])
            : data['sender'],
        imageUrl: data['imageurl'],
        joined: data['joined']);
  } else {
    return Mail(
        title: data['title'],
        body: data['body'],
        recipients: JSONToParticipants(data['recipients']));
  }
}
