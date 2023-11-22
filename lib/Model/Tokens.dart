class Tokens {
  String _accessToken="";
  String _refreshToken="";

  Tokens(this._accessToken, this._refreshToken);

  String get accessToken => _accessToken;

  set accessToken(String value) {
    _accessToken = value;
  }



  String get refreshToken => _refreshToken;

  set refreshToken(String value) {
    _refreshToken = value;
  }

}