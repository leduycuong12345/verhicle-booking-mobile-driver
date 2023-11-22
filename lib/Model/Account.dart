class Account{
  String _username="";
  String _password="";
  String get username => _username;

  String get password => _password;

  set password(String value) {
    _password = value;
  }

  set username(String value) {
    _username = value;
  }

  Account(this._username, this._password);
}
