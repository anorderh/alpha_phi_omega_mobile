import 'package:http/http.dart' as http;
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:example/RevampLib/UserData.dart';
import 'package:example/RevampLib/AppData.dart';
import 'CalendarHelpers.dart';
import 'Calendar_HTTP.dart';
import 'Login_HTTP.dart';

Future<String> scrapeUserInfo(UserData user) async {
  http.Response raw;
  String userInfoURL = user.http.baseURL + '?' + profile_action;

  // processing request
  raw = await http.post(
    Uri.parse(userInfoURL),
    body: user.http.data,
    headers: user.http.headers,
  );
  user.http.profileResponse = BeautifulSoup(raw.body);

  // checking if http success
  if (!verifyHTTP(user.http.profileResponse)) {
    return "http error";
  }

  // checking if contents can be parsed
  try {
    user.name = user.http.profileResponse
        .find('div', attrs: {'class': 'content-header'})!
        .children[0]
        .text;

    user.position = user.http.profileResponse
        .find('div', attrs: {'class': 'content-subheader'})!
        .text
        .split(" of ")[0]
        .substring(1);

    user.pictureURL = "http://www.apoonline.org/alphadelta/" +
        user.http.profileResponse.find('img')!['src']!;

    user.greeting = deriveGreeting(DateTime.now());
  } catch (e) {
    print(e.toString());
    return "parse error";
  }

  print("USER INFO:\n${user.name}\n${user.position}\n");
  return "success";
}

Future<List<String>> scrapeUserContent(UserData user,
    {required bool ignore}) async {
  return await Future.wait(ignore
      ? [scrapeUpcomingEvents(user)]
      : [scrapeUserInfo(user), scrapeReqs(user), scrapeUpcomingEvents(user)]);
}

Future<String> scrapeReqs(UserData user) async {
  // checking if http success
  if (!verifyHTTP(user.http.homeResponse)) {
    return "http error";
  } else {
    try {
      user.reqs = mapReqs(
          _stringsFromTags(user.http.homeResponse.findAll(
              // credit names
              'a',
              attrs: {
                'style': 'margin-bottom: .5em;display: block;color:black;'
              })),
          _stringsFromTags(user.http.homeResponse.findAll(
              // credit amounts
              'span',
              attrs: {'style': 'float:right; color:grey;'})));
    } catch (e) {
      return "parse error";
    }

    return "success";
  }
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

Future<String> scrapeUpcomingEvents(UserData user) async {
  http.Response raw;
  String upcomingURL = user.http.baseURL + '?' + upcomingEvents_action;
  List<String> eventLinks = [];
  int eventQuantity = 1;

  raw = await http.post(
    Uri.parse(upcomingURL),
    body: user.http.data,
    headers: user.http.headers,
  );
  user.http.upcomingEventsResponse = BeautifulSoup(raw.body);
  if (!verifyHTTP(user.http.upcomingEventsResponse)) {
    return "http error";
  }

  try {
    // finding all links and adding to List
    user.http.upcomingEventsResponse
        .findAll('div', attrs: {'class': 'calendar-title'}).forEach((tag) {
      eventLinks.add(user.http.baseURL + tag.a!['href']!);
    });

    // processing all links simultaneously
    user.setUpcomingEvents(
        await Future.wait(Iterable.generate(eventLinks.length, (i) {
      return addUpcomingEvent(user.http.getHTTPTags(), user.http.baseURL,
          eventLinks[i], eventQuantity++);
    })));
  } catch (e) {
    return "parse error";
  }

  // sort scraped events
  user.upcomingEvents.sort((a, b) => a.compareTo(b));

  print("events passed");
  return "success";
}

Future<EventFull> addUpcomingEvent(
    Map httpTags, String baseURL, String link, int quantity) async {
  return await handleEvent(httpTags, baseURL, link, quantity);
}
