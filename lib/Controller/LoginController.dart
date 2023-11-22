import 'package:flutter/material.dart';

import '../Model/Account.dart';
import '../Model/Tokens.dart';
import '../Service/LoginService/APITokensHolder.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late Tokens _tokens;

  Tokens get tokens => _tokens;

  void _setTokens(String username,String password) async
  {

     _tokens=await APITokensHolder().getTokensForAuthentication(Account(username,password));
     print("access token: "+_tokens.accessToken + ", refreshToken : "+_tokens.refreshToken);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ứng dụng tài xế'),
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
                //gui toi API-core de lay accesstoken va renewtoken :))
                _setTokens(username,password);
              },
              child: Text('Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}