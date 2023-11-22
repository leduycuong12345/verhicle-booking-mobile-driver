
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../Model/Account.dart';
import '../../Model/Tokens.dart';

class APITokensHolder {
  final String _signinURL="http://10.0.2.2:8069/api/v1/user/signin";//use 10.0.2.2 instead localhost because loopback error
  final String _refreshTokenURL="http://10.0.2.2:8069/api/v1/user/refreshtoken";

  Future<http.Response> signinAPI(Account account) async {
    return await http.post(
      Uri.parse(_signinURL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': account.username,
        'password':account.password
      }),
    );
  }
  Future<Tokens> getTokensForAuthentication(Account account) async
  {

    http.Response response=await signinAPI(account);

    print("content json:$response");
    //send then read response and adding token toHeader
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      var responseData = json.decode(response.body);
      return Tokens(responseData["accessToken"],responseData["refreshToken"]);
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to get authorization token!!.');
    }

  }
}