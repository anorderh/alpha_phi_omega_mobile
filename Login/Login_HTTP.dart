///
/// Methods involving HTTP requests for Login.dart
///

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import '../../Data/UserData.dart';

// Creating valid session to log into www.appon.org.
Future<String> initHTTP(UserHTTP inputHTTP, String user, String pw) async {
  inputHTTP.data['email'] = user;
  inputHTTP.data['password'] = pw;

  // Clear cookies!
  inputHTTP.headers.remove('Cookie');
  inputHTTP.headers.remove('__csrf_magic');

  try {
    // Requests 1 & 2 verifies internet is solid.
    print("REQUEST #1: RETRIEVING PHPSESSID");
    var response = await http.post(
      Uri.parse(inputHTTP.baseURL),
      body: inputHTTP.data,
      headers: inputHTTP.headers,
    );
    inputHTTP.headers['Cookie'] = response.headers['set-cookie']!.split(';')[0];
    print(inputHTTP.headers['Cookie']);

    print("REQUEST #2: RETRIEVING CSRF");
    response = await http.post(
      Uri.parse(inputHTTP.baseURL),
      body: inputHTTP.data,
      headers: inputHTTP.headers,
    );
    inputHTTP.data['__csrf_magic'] = BeautifulSoup(response.body).find('input')!['value']!;
    print(inputHTTP.data['__csrf_magic']);

    // Request 3 verifies credentials are solid.
    print("REQUEST 3: VALIDATING LOGIN");
    response = await http.post(
      Uri.parse(inputHTTP.baseURL),
      body: inputHTTP.data,
      headers: inputHTTP.headers,
    );

    // Check if login is successful!
    inputHTTP.homeResponse = BeautifulSoup(response.body);
    inputHTTP.validConnection = verifyHTTP(inputHTTP.homeResponse);

    return inputHTTP.validConnection ? "Success" : "Failure";
  } on SocketException {
    return "Unstable network";
  }
}

bool verifyHTTP(BeautifulSoup response) {
  // If HTML tag is present, login succeeded.
  if (response.find('div', attrs: {'id': 'topheader-name'}) != null) {
    return true;
  } else {
    return false;
  }
}