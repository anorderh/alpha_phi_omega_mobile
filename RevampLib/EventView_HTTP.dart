import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:example/RevampLib/AppData.dart';
import 'package:example/RevampLib/Login_HTTP.dart';
import 'package:http/http.dart' as http;
import 'UserData.dart';

// future[0] is bool representing if user present
// future[1] is map representing IDs linked to participants
Future<List<dynamic>> getParticipants(Map httpTags, String link) async {
  Bs4Element? name, number, comment, canDrive;
  List<Bs4Element> shifts;
  Map<String, Map<String, List<Participant>>> participants = {};

  // processing event Link
  var response = await http.post(
    Uri.parse(link),
    body: httpTags['data'],
    headers: httpTags['headers'],
  );
  BeautifulSoup eventResponse = BeautifulSoup(response.body);

  // validate HTTP connection
  if (!verifyHTTP(eventResponse)) {
    return ['http error'];
  }

  // validate parsed content
  try {
    // retrieve participant table
    shifts =
        eventResponse.findAll('div', attrs: {'class': 'content-container'});

    // get all shifts present
    for (int i = 0; i < shifts.length; i++) {
      String shiftName = shifts[i].nextElement!.text;
      participants[shiftName] = {'active': []};
      List<Bs4Element> tables = shifts[i]
          .findAllNextElements("table", attrs: {'class': 'content-table'});

      // retrieve both active, & waitlist if present
      for (int j = 0; j < tables.length; j++) {
        if (j == 1) {
          participants[shiftName]!['waitlist'] = [];
        }
        Bs4Element body = tables[j].find('tbody')!;

        for (var tag in body.findAll('tr')) {
          name = tag.find('td', attrs: {'nowrap': 'nowrap'})?.find('a',
              attrs: {'style': 'color:#000000'});

          // if name is valid, pull other info
          if (name != null) {
            number =
                tag.find('td', attrs: {'align': 'center', 'nowrap': 'nowrap'});
            comment = number!.findNextElement('td', attrs: {'align': 'center'});
            canDrive = tag.find('div', attrs: {'onmouseout': 'UnTip()'});

            // add to map
            participants[shiftName]![j == 0 ? "active" : "waitlist"]!.add(
                Participant(name.text, comment!.text, number.text,
                    int.tryParse(canDrive?.text ?? "")));
          }
        }
      }
    }
  } catch (e) {
    return ['parse error'];
  }

  return [isUserSignedUp(shifts), participants];
}

// return i if user found in a Shift, -1 if not found
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

  http.Response response = await http.post(
      Uri.parse(baseURL + '?action=eventattendeeadd'),
      body: data,
      headers: httpTags['headers']);

  if (!verifyHTTP(BeautifulSoup(response.body))) {
    return 'http error';
  }

  return response.statusCode == 200 ? 'success' : 'failure'; // 200 is success
}

Future<String> removeSelf(
    Map httpTags, String baseURL, String id, int shiftID) async {
  String queryURL = baseURL +
      '?action=eventattendeeremove' +
      '&eventid=$id' +
      '&shiftid=$shiftID';

  http.Response response =
      await http.get(Uri.parse(queryURL), headers: httpTags['headers']);

  if (!verifyHTTP(BeautifulSoup(response.body))) {
    return 'http error';
  }

  return response.statusCode == 200 ? 'success' : 'failure'; // 200 is success
}
