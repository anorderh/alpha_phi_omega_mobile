import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:example/RevampLib/AppData.dart';
import 'package:http/http.dart' as http;
import 'UserData.dart';

// future[0] is bool representing if user present
// future[1] is map representing IDs linked to participants
Future<List<dynamic>> getParticipants(Map httpTags, String link) async {
  Bs4Element? name, number, comment, canDrive;
  int id;
  Map<int, Participant> participants = {};

  // processing event Link
  var response = await http.post(
    Uri.parse(link),
    body: httpTags['data'],
    headers: httpTags['headers'],
  );
  BeautifulSoup eventResponse = BeautifulSoup(response.body);

  // retrieve participant table
  Bs4Element body = eventResponse.find('tbody')!;

  // processing table tiles
  for (var tag in body.findAll('tr')) {
    name = tag.find('td', attrs: {'nowrap': 'nowrap'})?.find('a',
        attrs: {'style': 'color:#000000'});

    // if name is valid, pull other info
    if (name != null) {
      id = int.parse(name['href']!.replaceAll("?action=profile&userid=", ''));
      number = tag.find('td', attrs: {'align': 'center', 'nowrap': 'nowrap'});
      comment = number!.findNextElement('td', attrs: {'align': 'center'});
      canDrive = tag.find('div', attrs: {'onmouseout': 'UnTip()'});

      // add to map
      participants[id] = Participant(name.text, comment!.text, number.text,
          int.tryParse(canDrive?.text ?? ""));
    }
  }

  return [await isUserSignedUp(body), participants];
}

Future<bool> isUserSignedUp(Bs4Element body) async {
  return body.find('td', attrs: {'style': 'font-weight:bold;'}) != null;
}

Future<bool> addSelf(Map httpTags, String id, String comment, int haveCar, int driveOthers) async {
  Map<String, String> data = {
    '__csrf_magic': httpTags['data']['__csrf_magic']!,
    'eventid': id,
    'user[comments]': comment,
    'user[haveCar]': haveCar.toString(),
    'user[drivehowmanyothers]': driveOthers.toString()
  };

  http.Response response = await http.post(
      Uri.parse(base_url + '?action=eventattendeeadd'),
      body: data,
      headers: httpTags['headers']);

  return response.statusCode == 200; // 200 is success
}

Future<bool> removeSelf(Map httpTags, String id) async {
  String queryURL = base_url + '?action=eventattendeeremove' + '&eventid=$id';

  http.Response response = await http.get(
      Uri.parse(queryURL),
      headers: httpTags['headers']);

  return response.statusCode == 200; // 200 is success
}
