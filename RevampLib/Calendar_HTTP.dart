import 'package:http/http.dart' as http;
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:example/RevampLib/AppData.dart';
import 'package:example/RevampLib/UserData.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:intl/intl.dart';
import 'CalendarHelpers.dart';

Future<bool> startEventScrapping(UserData user, CalendarData calendar,
    DateTime date, bool forceRefresh) async {
  calendar.setFocusedDate(date);
  int eventCount = 0;

  // check if calendar present
  if (calendar.monthProcessed == null ||
      (forceRefresh || calendar.monthProcessed != date.month)) {
    user.http.setCalendarResponse(await setCalendar(user.http.getHTTPTags(), date));
    calendar.setMonthProcessed(date.month);
  }

  // retrieve and pull data from day's events
  eventCount = await pullEventsFrom(user, calendar, date.day);

  // return bool stating if eventList empty
  return eventCount != 0;
}

Future<BeautifulSoup> setCalendar(Map httpTags, DateTime date) async {
  http.Response raw;

  String calendarUrl = base_url +
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

Future<int> pullEventsFrom(UserData user, CalendarData calendar, int day) async {
  List<Bs4Element> eventBlocks;
  List<EventFull> results = [];
  int eventQuantity = 0;

  for (Bs4Element tag in user.http.calendarResponse
      .findAll('div', attrs: {'class': 'calendar-daynumber'})) {
    if (int.parse(tag.text.toString()) == day) {
      eventBlocks = tag.nextElement!.children;

      // generating futures from all Event Blocks and processing concurrently
      results = await Future.wait(Iterable.generate(eventBlocks.length, (i) {
        return handleEvent(user.http.getHTTPTags(), eventBlocks[i].a!['href']!, ++eventQuantity);
      }));

      // add to controller
      for (EventFull event in results) {
        if (event.start != null) {
          calendar.eventController.add(CalendarEventData<EventFull>(
              title: event.title,
              event: event,
              startTime: event.start,
              endTime: event.end,
              date: event.date));
        } else {
          calendar.allDayEvents[calendar.focusedDate.weekday - 1]
              .add(event);
        }
      }

      break;
    }
  }

  return eventQuantity;
}

Future<EventFull> handleEvent(Map httpTags, String link, int eventNumber) async {
  print("handled event #" + eventNumber.toString());
  List<DateTime> eventTimes; // [{date}, start, end]
  DateTime tempDate;
  List<String> temp = [];

  var response = await http.post(
    Uri.parse(link),
    body: httpTags['data'],
    headers: httpTags['headers'],
  );

  // getting event page response & base header
  BeautifulSoup eventResponse = BeautifulSoup(response.body);
  Bs4Element header = eventResponse.find('div', attrs: {'class': 'row'})!;

  // retrieving Event date
  eventTimes = deriveTimes(header
      .find('div', attrs: {'onmouseover': 'Tip(\'Event Date & Time\')'})!
      .parent!
      .text);

  // Event object
  EventFull event = EventFull(
      title: eventResponse
          .find('h1', attrs: {'style': 'margin-bottom:15px;'})!
          .a!
          .text,
      link: link,
      date: eventTimes[0],
      id: link.replaceAll(base_url + '?action=eventsignup&eventid=', ''));

  // implementing start & end times, if applicable
  if (eventTimes.length > 1 && eventTimes[1] != eventTimes[2]) {
    event.start = eventTimes[1];
    event.end = eventTimes[2];

    print(
        "start: " + event.start.toString() + "| end: " + event.end.toString());
  } else {
    print("event \"${event.title}\" is all day");
  }

  try {
    // credit
    event.cred = header
        .find('ul',
            attrs: {'style': 'list-style: none; margin: 0; padding: 0;'})!
        .find('li')!
        .text;
  } catch (e) {}
  ;

  try {
    // location
    event.loc = header
        .find('div', attrs: {'onmouseover': 'Tip(\'Event Location\')'})!
        .parent!
        .text;
  } catch (e) {}
  ;

  try {
    // desc
    event.desc = header
        .find('div', attrs: {'onmouseover': 'Tip(\'Event Information\')'})!
        .parent!
        .text;
  } catch (e) {}
  ;

  try {
    // lock
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
  ;

  try {
    // close
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
  ;

  try {
    // creator
    event.creator = header
        .find('div', attrs: {'onmouseover': 'Tip(\'Event Creator\')'})!
        .parent!
        .text;
  } catch (e) {}
  ;

  return event;
}
