import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:http/http.dart' as http;
import 'package:example/Backend/apo_objects.dart';
import 'dart:async';
import 'package:example/http_Directory/http.dart';

Future<List<EventMinimal>> pull_events(int month, int day, int year) async {
  if (year == 1) {
    return [];
  }

  var response = await http.post(
    Uri.parse(_url_rebuild(month, year)),
    body: data,
    headers: headers,
  );

  var soup = BeautifulSoup(response.body);
  List<String> eventLinks = [];
  List calendarBlocks = [];

  List calendarDays = _pull_day_tags(
      soup); // this pulls every day within a month, look into '.text' attribute to get 1 day only
  calendarBlocks = calendarDays[day - 1].findAll('a');
  if (calendarBlocks.isEmpty) {
    return [];
  }

  for (var block in calendarBlocks) {
      eventLinks.add(block['href']);
      // empty try-catch here before, to account for events w/ no link
      // was it even necessary?
  }

  List<EventMinimal> eventList = await init_event_list(eventLinks, EventMinimal);
  return eventList;
}

List<dynamic> _pull_day_tags(BeautifulSoup soup) {
  List tags = soup.findAll('td', attrs: {'class': 'calendar-day'});
  List valid_tags = [];

  for (Bs4Element tag in tags) {
    if (tag.find('div') != null) {
      valid_tags.add(tag);
    }
  }

  return valid_tags;
}

Future<List<EventMinimal>> init_event_list(List<String> links, Type eventType) async {
  Future<List<EventMinimal>> eventList = Future.value([]);

  return eventList.then((future) async {
    for (var link in links) {
      var event = await handle_event(link, eventType);
      future.add(event);
    }
    return future;
  });
}

Future<dynamic> handle_event(String link, Type eventType) async {
  List<String> details;
  var response = await http.post(
    Uri.parse(link),
    body: data,
    headers: headers,
  );

  BeautifulSoup soup = BeautifulSoup(response.body);
  if (eventType == EventMinimal) {
    details = _init_details(soup, 3);

    return EventMinimal(
        details[0], // title
        details[1], // cred
        details[2], // date
        link);
  } else {
    details = _init_details(soup, 6);

    return EventFull(
        details[0], // title
        details[1], // cred
        details[2], // date
        details[3], // loc
        details[4], // desc
        details[5], // creator
        link,
        int.parse(link.split('&')[1].replaceAll('eventid=', '')),
        _handle_participants(soup));

  }
}

List<Participant> _handle_participants(BeautifulSoup soup) {
  Bs4Element? name, number, comment;
  var body = soup.find('tbody');
  List<Participant> members = [];

  for (var tag in body!.findAll('tr')) {
    name = tag.find('td', attrs: {'nowrap': 'nowrap'})?.find('a', attrs: {'style': 'color:#000000'});
    number = tag.find('td', attrs: {'align': 'center'});
    comment = number?.findNextElement('td', attrs: {'align': 'center'});

    if (name != null) {
      members.add(Participant(name.text, number?.text ?? 'hidden', comment?.text ?? 'n/a'));
    }
  }

  return members;
}

String _url_rebuild(int month, int year) {
  return '$base_url?month=$month&year=$year&action=vieweventcalendar';
}

List<String> _init_details(BeautifulSoup soup, int detailSize) {
  List<String> details = List.filled(detailSize, 'n/a');
  List<Bs4Element> eventHeader = soup.findAll('div', attrs: {'class':'six columns'});
  List<Bs4Element> validTags = [];
  for (var classTag in eventHeader) {
    for (var tag in classTag.findAll('div')) {
      if (tag.nextElement?['onmouseover'] != null) {
        validTags.add(tag);
      }
    }
  }

  // title
  details[0] = soup.find('h1', attrs: {'style': 'margin-bottom:15px;'})!.a!.text;

  try { // cred
    details[1] = soup
        .find('ul',
        attrs: {'style': 'list-style: none; margin: 0; padding: 0;'})!
        .find('li')!
        .text;
  } catch (e) {
    details[1] = 'n/a';
  }

  for (var tag in validTags) {
    try {
      String label = tag.nextElement!['onmouseover']!;

      if (label == 'Tip(\'Event Date & Time\')') {
        details[2] = tag.text;
      } else if (detailSize > 3) {
        if (label == 'Tip(\'Event Location\')') {
          details[3] = tag.text;
        } else if (label == 'Tip(\'Event Information\')') {
          details[4] = tag.text;
        } else if (label == 'Tip(\'Event Creator\')') {
          details[5] = tag.text;
        }
      } else {
        return details;
      }
    } catch(e) {}
  }

  return details;
}
