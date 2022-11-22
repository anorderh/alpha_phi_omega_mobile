///
/// Methods involving HTTP requests for Calendar.dart
///

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import '../../Data/AppData.dart';
import '../../Data/UserData.dart';
import 'package:calendar_view/calendar_view.dart';
import '../../Internal/APOM_Objects.dart';
import '../../Login/Login_HTTP.dart';
import 'package:intl/intl.dart';
import 'CalendarHelpers.dart';

// Core, processes Calendar page
Future<String> startEventScrapping(UserData user, CalendarData calendar,
    DateTime date, bool forceRefresh) async {
  calendar.setFocusedDate(date);
  int eventCount = 0;

  try {
    // Check if process has alrady occurred
    if (calendar.monthProcessed == null ||
        (forceRefresh || calendar.monthProcessed != date.month)) {
      user.http.calendarResponse =
      await setCalendar(user.http.getHTTPTags(), user.http.baseURL, date);
    }

    if (verifyHTTP(user.http.calendarResponse)) {
      calendar.setMonthProcessed(date.month);
    } else {
      return "Not recognized";
    }

    // Pull date's event data.
    // ! BLOCK if current queue is different from FocusedDate
    if (date.compareTo(calendar.focusedDate) == 0) {
      eventCount = await pullEventsFrom(user, calendar, date.day);
    }
  } on SocketException {
    return "Unstable network";
  } catch (e) {
    return e.toString().substring(0, 45);
  }

  return eventCount != 0 ? "success" : "empty";
}

// H: Scrape and store calendar response
Future<BeautifulSoup> setCalendar(
    Map httpTags, String baseURL, DateTime date) async {
  http.Response raw;

  String calendarUrl = baseURL +
      '?month=${date.month}' +
      '&year=${date.year}' +
      '&action=vieweventcalendar';

  raw = await http.post(
    Uri.parse(calendarUrl),
    body: httpTags['data'],
    headers: httpTags['headers'],
  );

  return BeautifulSoup(raw.body);
}

// Get and process all events from specific day
Future<int> pullEventsFrom(
    UserData user, CalendarData calendar, int day) async {
  List<Bs4Element> eventBlocks;
  List<EventFull> results = [];
  int eventQuantity = 0;

  for (Bs4Element tag in user.http.calendarResponse
      .findAll('div', attrs: {'class': 'calendar-daynumber'})) {
    if (int.parse(tag.text.toString()) == day) {
      eventBlocks = tag.nextElement!.children;

      // Processing all events concurrently
      results = await Future.wait(Iterable.generate(eventBlocks.length, (i) {
        return handleEvent(user.http.getHTTPTags(), user.http.baseURL,
            eventBlocks[i].a!['href']!, ++eventQuantity);
      }));

      for (EventFull event in results) {
        // ! BLOCK if current queue is different from FocusedDate
        if (event.start != null) {
          calendar.eventController.add(CalendarEventData<EventFull>(
              title: event.title,
              event: event,
              startTime: event.start,
              endTime: event.end,
              date: event.date));
        } else {
          var day =
              calendar.allDayEvents['${event.date.month}.${event.date.day}'];
          if (day != null && !isEventAlreadyPresent(day, event.link)) {
            calendar.allDayEvents['${event.date.month}.${event.date.day}']
                ?.add(event);
          }
        }
      }

      break;
    }
  }

  return eventQuantity;
}

// Process single event data
Future<EventFull> handleEvent(
    Map httpTags, String baseURL, String link, int eventNumber) async {
  // print("handled event #" + eventNumber.toString());
  List<DateTime> eventTimes; // [{date}, start, end]
  DateTime tempDate;
  List<String> temp = [];

  var response = await http.post(
    Uri.parse(link),
    body: httpTags['data'],
    headers: httpTags['headers'],
  );

  // Event page response & base header.
  BeautifulSoup eventResponse = BeautifulSoup(response.body);
  Bs4Element header = eventResponse.find('div', attrs: {'class': 'row'})!;

  eventTimes = deriveTimes(header
      .find('div', attrs: {'onmouseover': 'Tip(\'Event Date & Time\')'})!
      .parent!
      .text);

  // Partial EventFull object ~ to fill later
  EventFull event = EventFull(
      title: eventResponse
          .find('h1', attrs: {'style': 'margin-bottom:15px;'})!
          .a!
          .text,
      link: link,
      date: eventTimes[0],
      id: link.replaceAll(baseURL + '?action=eventsignup&eventid=', ''));

  // Start & end times?
  if (eventTimes.length > 1 && eventTimes[1] != eventTimes[2]) {
    event.start = eventTimes[1];
    event.end = eventTimes[2];

    // print(
    //     "start: " + event.start.toString() + "| end: " + event.end.toString());
  } else {
    // print("event \"${event.title}\" is all day");
  }

  try {
    // Credit?
    List<Bs4Element> tags = header.find('ul', attrs: {
      'style': 'list-style: none; margin: 0; padding: 0;'
    })!.findAll('li');

    event.cred = Iterable.generate(tags.length, (i) {
      return tags[i].text;
    }).toList().join("\n");
  } catch (e) {}
  ;

  try {
    // Location?
    event.loc = header
        .find('div', attrs: {'onmouseover': 'Tip(\'Event Location\')'})!
        .parent!
        .text;
  } catch (e) {}
  ;

  try {
    // Desc?
    event.desc = header
        .find('div', attrs: {'onmouseover': 'Tip(\'Event Information\')'})!
        .parent!
        .text;
  } catch (e) {}

  try {
    // Signups lock date?
    temp = [
      header
          .find('div', attrs: {'onmouseover': 'Tip(\'Sign-ups Lock\')'})!
          .parent!
          .text
    ];

    temp = temp[0].replaceAll(" Sign-ups lock on ", "").split(" at ");
    tempDate = DateFormat("MMM d").parse(temp[0]);
    tempDate = DateTime(eventTimes[0].year, tempDate.month, tempDate.day);

    event.lock = getTimeinDateTime(tempDate, temp[1]);
  } catch (e) {}

  try {
    // Signups close date?
    temp = [
      header
          .find('div', attrs: {'onmouseover': 'Tip(\'Sign-ups Close\')'})!
          .parent!
          .text
    ];

    temp = temp[0].replaceAll(" Sign-ups close on ", "").split(" at ");
    tempDate = DateFormat("MMM d").parse(temp[0]);
    tempDate = DateTime(eventTimes[0].year, tempDate.month, tempDate.day);

    event.close = getTimeinDateTime(tempDate, temp[1]);
  } catch (e) {}

  try {
    // Creator?
    event.creator = header
        .find('div', attrs: {'onmouseover': 'Tip(\'Event Creator\')'})!
        .parent!
        .text;
  } catch (e) {}

  return event;
}
