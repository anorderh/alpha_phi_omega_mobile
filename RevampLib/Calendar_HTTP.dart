import 'package:http/http.dart' as http;
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:example/RevampLib/AppData.dart';
import 'package:example/RevampLib/UserData.dart';
import 'package:calendar_view/calendar_view.dart';
import 'CalendarHelpers.dart';

Future<bool> startEventScrapping(DateTime date, bool forceRefresh) async {
  mainCalendar.focusedDate = date;
  int eventCount = 0;

  // check if calendar present
  if (mainCalendar.monthProcessed == null ||
      (forceRefresh || mainCalendar.monthProcessed != date.month)) {
    await setCalendar(date);
  }

  // retrieve and pull data from day's events
  eventCount = await pullEventsFrom(date.day);

  // return bool stating if eventList empty
  return eventCount != 0;
}

Future<void> setCalendar(DateTime date) async {
  http.Response raw;

  String calendarUrl = base_url +
      '?month=${date.month}' +
      '&year=${date.year}' +
      '&action=vieweventcalendar';

  raw = await http.post(
    Uri.parse(calendarUrl),
    body: mainUser.http.data,
    headers: mainUser.http.headers,
  );

  mainCalendar.monthProcessed = date.month;
  mainUser.http.calendarResponse = BeautifulSoup(raw.body);
}

Future<int> pullEventsFrom(int day) async {
  List<Bs4Element> eventBlocks;
  List<EventFull> results = [];
  int eventQuantity = 0;

  for (Bs4Element tag in mainUser.http.calendarResponse
      .findAll('div', attrs: {'class': 'calendar-daynumber'})) {
    if (int.parse(tag.text.toString()) == day) {
      eventBlocks = tag.nextElement!.children;

      // generating futures from all Event Blocks and processing concurrently
      results = await Future.wait(Iterable.generate(eventBlocks.length, (i) {
        return handleEvent(eventBlocks[i].a!['href']!, ++eventQuantity);
      }));

      // add to controller
      for (EventFull event in results) {
        if (event.start != null) {
          mainCalendar.eventController.add(CalendarEventData<EventFull>(
              title: event.title,
              event: event,
              startTime: event.start,
              endTime: event.end,
              date: event.date));
        } else {
          mainCalendar.allDayEvents[mainCalendar.focusedDate.weekday - 1].add(event);
        }
      }

      break;
    }
  }

  return eventQuantity;
}

Future<EventFull> handleEvent(String link, int eventNumber) async {
  print("handled event #" + eventNumber.toString());
  List<DateTime> eventTimes; // [{date}, start, end]

  var response = await http.post(
    Uri.parse(link),
    body: mainUser.http.data,
    headers: mainUser.http.headers,
  );

  // getting event page response & base header
  mainUser.http.eventResponse = BeautifulSoup(response.body);
  Bs4Element header = mainUser.http.eventResponse.find('div', attrs: {'class': 'row'})!;

  // retrieving Event date
  eventTimes = deriveTimes(header
      .find('div', attrs: {'onmouseover': 'Tip(\'Event Date & Time\')'})!
      .parent!
      .text);

  // Event object
  EventFull event = EventFull(
      title: mainUser.http.eventResponse
          .find('h1', attrs: {'style': 'margin-bottom:15px;'})!
          .a!
          .text,
      link: link,
      date: eventTimes[0],
      participants: []);

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
    // creator
    event.creator = header
        .find('div', attrs: {'onmouseover': 'Tip(\'Event Creator\')'})!
        .parent!
        .text;
  } catch (e) {}
  ;

  return event;
}
