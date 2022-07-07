import 'package:http/http.dart' as http;
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:example/RevampLib/UserData.dart';
import 'package:example/RevampLib/AppData.dart';
import 'CalendarHelpers.dart';
import 'Calendar_HTTP.dart';

Future<bool> scrapeUserInfo() async {
  try {
    http.Response raw;
    String userInfoURL = base_url + '?' + profile_action;

    raw = await http.post(
      Uri.parse(userInfoURL),
      body: mainUser.http.data,
      headers: mainUser.http.headers,
    );
    mainUser.http.profileResponse = BeautifulSoup(raw.body);

    mainUser.name = mainUser.http.profileResponse
        .find('div', attrs: {'class': 'content-header'})!
        .children[0]
        .text;

    mainUser.position = mainUser.http.profileResponse
        .find('div', attrs: {'class': 'content-subheader'})!
        .text
        .split(" of ")[0]
        .substring(1);

    mainUser.pictureURL = "http://www.apoonline.org/alphadelta/" +
        mainUser.http.profileResponse.find('img')!['src']!;

    mainUser.greeting = deriveGreeting(mainCalendar.currentDate);

    print("USER INFO:\n${mainUser.name}\n${mainUser.position}\n");
  } catch (e) {
    print(e.toString());
    return false;
  }
  return true;
}

Future<bool> scrapeUserContent() async {
  try {
    await Future.wait([scrapeReqs(), scrapeUpcomingEvents()]);
  } catch (e) {
    print(e.toString());
    return false;
  }

  return true;
}

Future<void> scrapeReqs() async {
  mainUser.reqs = mapReqs(
      _stringsFromTags(mainUser.http.homeResponse.findAll(
          // credit names
          'a',
          attrs: {'style': 'margin-bottom: .5em;display: block;color:black;'})),
      _stringsFromTags(mainUser.http.homeResponse.findAll(
          // credit amounts
          'span',
          attrs: {'style': 'float:right; color:grey;'})));
}

Map<String, List<double>> mapReqs(List<String> types, List<String> amounts) {
  Map<String, List<double>> credits = {};
  types = cleanCreditNames(types);

  for (int i = 0; i < types.length; i++) {
    List<String> components = amounts[i].replaceAll(' of', '').split(' ');

    if (components[0][0] != '\$') {
      // removing Fees tracker from progress
      credits[types[i]] = [
        double.parse(components[0]),
        double.parse(components[1])
      ];
    }
  }

  return credits;
}

List<String> cleanCreditNames(List<String> rawCredits) {
  return Iterable<String>.generate(rawCredits.length, (i) {
    return rawCredits[i]
        .replaceAll(" Credit ", "")
        .replaceAll("Progress", "")
        .replaceAll("Hour", "");
  }).toList();
}

List<String> _stringsFromTags(List<Bs4Element> tags) {
  List<String> group = [];

  for (var tag in tags) {
    group.add(tag.text);
  }

  return group;
}

Future<void> scrapeUpcomingEvents() async {
  http.Response raw;
  String upcomingURL = base_url + '?' + upcomingEvents_action;
  List<String> eventLinks = [];
  int eventQuantity = 1;

  raw = await http.post(
    Uri.parse(upcomingURL),
    body: mainUser.http.data,
    headers: mainUser.http.headers,
  );
  mainUser.http.upcomingEventsResponse = BeautifulSoup(raw.body);

  // finding all links and adding to List
  mainUser.http.upcomingEventsResponse
      .findAll('div', attrs: {'class': 'calendar-title'}).forEach((tag) {
    eventLinks.add(base_url + tag.a!['href']!);
  });

  // processing all links simultaneously
  await Future.wait(Iterable.generate(eventLinks.length, (i) {
    return addUpcomingEvent(eventLinks[i], eventQuantity++);
  }));

  // sort scraped events
  mainUser.upcomingEvents.sort((a, b) => a.compareTo(b));

  print("events passed");
}

Future<void> addUpcomingEvent(String link, int quantity) async {
  EventFull event = await handleEvent(link, quantity);
  mainUser.upcomingEvents.add(event);
}
