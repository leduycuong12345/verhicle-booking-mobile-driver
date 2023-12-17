class CallCenter{
  late int Id;

  late String _tenkhachhang;
  late String _sdt;
  late int LoaiXe;
  late double _gpsLat;
  late double _gpsLong;

  late String _sonha;
  late String _duong;
  late String _phuong;
  late String _quan;
  late String _thanhpho;
  late String _statusCode;

  String get statusCode => _statusCode;

  set statusCode(String value) {
    _statusCode = value;
  }

  String get tenkhachhang => _tenkhachhang;

  set tenkhachhang(String value) {
    _tenkhachhang = value;
  }


  String get sdt => _sdt;

  set sdt(String value) {
    _sdt = value;
  }


  double get gpsLat => _gpsLat;

  set gpsLat(double value) {
    _gpsLat = value;
  }

  double get gpsLong => _gpsLong;

  set gpsLong(double value) {
    _gpsLong = value;
  }

  String get sonha => _sonha;

  set sonha(String value) {
    _sonha = value;
  }

  String get duong => _duong;

  set duong(String value) {
    _duong = value;
  }

  String get phuong => _phuong;

  set phuong(String value) {
    _phuong = value;
  }

  String get quan => _quan;

  set quan(String value) {
    _quan = value;
  }

  String get thanhpho => _thanhpho;

  set thanhpho(String value) {
    _thanhpho = value;
  }


  CallCenter(
      this.Id,
      this._tenkhachhang,
      this._sdt,
      this._gpsLat,
      this._gpsLong,
      this._sonha,
      this._duong,
      this._phuong,
      this._quan,
      this._thanhpho
      ,this._statusCode);
}