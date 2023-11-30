import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../Model/Account.dart';
import '../Model/Tokens.dart';
import '../Service/DriverService/DriverService.dart';
import '../Service/LoginService/APITokensHolder.dart';
import 'ActionController.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late Tokens _tokens;

  Tokens get tokens => _tokens;

  Future<void> _setTokens(String username,String password) async
  {

     _tokens=await APITokensHolder().getTokensForAuthentication(Account(username,password));
     print("access token: "+_tokens.accessToken + ", refreshToken : "+_tokens.refreshToken);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ứng dụng tài xế CuongSolution'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Tên đăng nhập:'),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Mật khẩu:'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async{
                //Lay input tu nguoi dung
                String username = usernameController.text;
                String password = passwordController.text;
                //gui toi API-core de lay accesstoken va renewtoken , gps cua driver:))
                await _setTokens(username,password);
                LatLng pos=await DriverService(this._tokens).getCurrentDriverPosition();

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  ActionScreen(_tokens,pos)),
                );
              },
              child: Text('Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}