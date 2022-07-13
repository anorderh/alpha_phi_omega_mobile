import 'package:http/http.dart' as http;
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:example/RevampLib/UserData.dart';
import 'package:example/RevampLib/AppData.dart';

Future<UserHTTP?> initHTTP(UserHTTP inputHTTP, String user, String pw) async {
  // update user & pw
  inputHTTP.data['email'] = user;
  inputHTTP.data['password'] = pw;

  // clear cookie & csrf magic stored prior
  inputHTTP.headers.remove('Cookie');
  inputHTTP.headers.remove('__csrf_magic');

  print("REQUEST #1: RETRIEVING PHPSESSID");
  var response = await http.post(
    Uri.parse(base_url),
    body: inputHTTP.data,
    headers: inputHTTP.headers,
  );
  inputHTTP.headers['Cookie'] = response.headers['set-cookie']!.split(';')[0];
  print(inputHTTP.headers['Cookie']);

  print("REQUEST #2: RETRIEVING CSRF");
  response = await http.post(
    Uri.parse(base_url),
    body: inputHTTP.data,
    headers: inputHTTP.headers,
  );
  inputHTTP.data['__csrf_magic'] = BeautifulSoup(response.body).find('input')!['value']!;
  print(inputHTTP.data['__csrf_magic']);

  print("REQUEST 3: VALIDATING LOGIN");
  response = await http.post(
    Uri.parse(base_url),
    body: inputHTTP.data,
    headers: inputHTTP.headers,
  );

  inputHTTP.homeResponse = BeautifulSoup(response.body);

  if (verifyHTTP(inputHTTP)) {
    return inputHTTP;
  }
}

bool verifyHTTP(UserHTTP _http) {
  if (_http.homeResponse.find('div', attrs: {'id': 'topheader-name'}) != null) {
    _http.validLogin = true;
    return true;
  } else {
    return false;
  }
}