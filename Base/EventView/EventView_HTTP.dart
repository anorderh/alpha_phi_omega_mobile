///
/// Methods involving HTTP requests for EventView.dart
///

import 'dart:io';
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import '../../Login/Login_HTTP.dart';
import 'package:http/http.dart' as http;
import '../../Internal/APOM_Objects.dart';

/// Scrapes all event's shifts and corresponding participants
///
/// If success, List length should be 2
/// - [0] = bool if user is present
/// - [1] = map representing shifts to participants
Future<List<dynamic>> getParticipants(Map httpTags, String link) async {
  Bs4Element? name, number, comment, canDrive;
  List<Bs4Element> shifts;
  Map<String, Map<String, List<Participant>>> participants = {};

  try {
    var response = await http.post(
      Uri.parse(link),
      body: httpTags['data'],
      headers: httpTags['headers'],
    );
    BeautifulSoup eventResponse = BeautifulSoup(response.body);

    if (!verifyHTTP(eventResponse)) {
      return ["Not recognized"];
    }

    // Retrieve all shifts.
    shifts =
        eventResponse.findAll('div', attrs: {'class': 'content-container'});

    // Process all shifts.
    for (int i = 0; i < shifts.length; i++) {
      String shiftName = shifts[i].nextElement!.text;
      participants[shiftName] = {'active': []};
      // if tables length > 1, waitlist present
      List<Bs4Element> tables = shifts[i]
          .findAllNextElements("table", attrs: {'class': 'content-table'});

      // Process and link participants
      for (int j = 0; j < tables.length; j++) {
        if (j == 1) {
          participants[shiftName]!['waitlist'] = [];
        }
        Bs4Element body = tables[j].find('tbody')!;

        for (var tag in body.findAll('tr')) {
          name = tag.find('td', attrs: {'nowrap': 'nowrap'})?.find('a',
              attrs: {'style': 'color:#000000'});

          if (name != null) {
            number =
                tag.find('td', attrs: {'align': 'center', 'nowrap': 'nowrap'});
            comment = number!.findNextElement('td', attrs: {'align': 'center'});
            canDrive = tag.find('div', attrs: {'onmouseout': 'UnTip()'});

            // Adding participant to map.
            participants[shiftName]![j == 0 ? "active" : "waitlist"]!.add(
                Participant(name.text, comment!.text, number.text,
                    int.tryParse(canDrive?.text ?? "")));
          }
        }
      }
    }
  } on SocketException {
    return ["Unstable network"];
  } catch (e) {
    return [e.toString().substring(0, 45)];
  }

  return [isUserSignedUp(shifts), participants];
}

// Discern if User is already signed up
int isUserSignedUp(List<Bs4Element> shifts) {
  for (int i = 0; i < shifts.length; i++) {
    List<Bs4Element> bodies = shifts[i].findAll('tbody');
    for (Bs4Element body in bodies) {
      if (body.find('td', attrs: {'style': 'font-weight:bold;'}) != null) {
        return i;
      }
    }
  }

  return -1;
}

// Add user to event on www.apoon.org
Future<String> addSelf(Map httpTags, String baseURL, String id, String comment,
    int haveCar, int driveOthers, int shiftID) async {
  Map<String, String> data = {
    '__csrf_magic': httpTags['data']['__csrf_magic']!,
    'eventid': id,
    'user[comments]': comment,
    'user[haveCar]': haveCar.toString(),
    'user[drivehowmanyothers]': driveOthers.toString(),
    'shiftid': shiftID.toString()
  };
  late http.Response response;

  try {
    response = await http.post(
        Uri.parse(baseURL + '?action=eventattendeeadd'),
        body: data,
        headers: httpTags['headers']);

    if (!verifyHTTP(BeautifulSoup(response.body))) {
      return 'Not recognized';
    }
  } on SocketException {
    return "Unstable network";
  } catch (e) {
    return e.toString().substring(0, 45);
  }

  return response.statusCode == 200 ? 'success' : 'failure'; // 200 is success
}

// Remove user from event on www.apoon.org
Future<String> removeSelf(
    Map httpTags, String baseURL, String id, int shiftID) async {
  String queryURL = baseURL +
      '?action=eventattendeeremove' +
      '&eventid=$id' +
      '&shiftid=$shiftID';
  late http.Response response;

  try {
    response =
    await http.get(Uri.parse(queryURL), headers: httpTags['headers']);

    if (!verifyHTTP(BeautifulSoup(response.body))) {
      return 'Not recognized';
    }
  } on SocketException {
    return "Unstable network";
  } catch (e) {
    return e.toString().substring(0, 45);
  }

  return response.statusCode == 200 ? 'success' : 'failure'; // 200 is success
}
