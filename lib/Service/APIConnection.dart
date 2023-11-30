import 'dart:core';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../Model/Tokens.dart';

class APIConnection{
  final String _refreshTokenURL="http://10.0.2.2:8069/api/v1/user/refreshtoken";
  late Tokens _tokens;

  APIConnection(this._tokens);

  Future<http.Response> renewTokenAPI() async {
    return await http.post(
      Uri.parse(_refreshTokenURL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'refreshToken': _tokens.refreshToken,
      }),
    );
  }
  Future<void> renewAccessTokenByRefreshToken() async
  {
    print("u access token expired so get the new one by refreshToken:"+_tokens.refreshToken);
    var response=await renewTokenAPI();
    //send then read response and adding token toHeader
    if(response.statusCode==200)
      {
        var responseData = json.decode(response.body);
        _tokens=Tokens(responseData["accessToken"],responseData["refreshToken"]);
      }
  }

  Future<http.Response> getRequest(String url)async
  {
    var response=await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        // HttpHeaders.authorizationHeader:'Basic '+ _tokens.accessToken,
        HttpHeaders.authorizationHeader: _tokens.accessToken,
        // 'Authorization':_tokens.accessToken,
      },
    );
    if(response.statusCode!=200 ) //status code 409 403 402 401 ...
        {
      print("url: "+url+" return status code this request: "+response.statusCode.toString() + " with accessToken:"+_tokens.accessToken);
      //renew access token
      await renewAccessTokenByRefreshToken();
      //end renew access token

      //call this function againt to make a recusion loop lmao. I m the hacker :)))
      return getRequest(url);
    }
    else
    { // statuscode= 200 = success
      return response;
    }
  }
  Future<http.Response> postRequest(String url,String json)async
  {
    var response=await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        // HttpHeaders.authorizationHeader:'Basic '+ _tokens.accessToken,
        HttpHeaders.authorizationHeader: _tokens.accessToken,
        // 'Authorization':_tokens.accessToken,
      },
      body: json
    );
    if(response.statusCode!=200 ) //status code 409 403 402 401 ...
        {
      print("url: "+url+" return status code this request: "+response.statusCode.toString() + " with accessToken:"+_tokens.accessToken);
      //renew access token
      await renewAccessTokenByRefreshToken();
      //end renew access token

      //call this function againt to make a recusion loop lmao. I m the hacker :)))
      return postRequest(url,json);
    }
    else
    { // statuscode= 200 = success
      return response;
    }
  }
}