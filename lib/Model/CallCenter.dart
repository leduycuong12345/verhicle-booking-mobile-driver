class CallCenter{
  late int Id;

  late String _tenkhachhang;
  late String _sdt;
  late int LoaiXe;
  late String _diemDon;
  late double _gpsLat;
  late double _gpsLong;

  late String _sonha;
  late String _duong;
  late String _phuong;
  late String _quan;
  late String _thanhpho;

  String get tenkhachhang => _tenkhachhang;

  set tenkhachhang(String value) {
    _tenkhachhang = value;
  }


  String get sdt => _sdt;

  set sdt(String value) {
    _sdt = value;
  }

  String get diemDon => _diemDon;

  set diemDon(String value) {
    _diemDon = value;
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
}