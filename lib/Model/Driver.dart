class Driver {
  late int _driver_Id;


  int get driver_Id => _driver_Id;

  set driver_Id(int value) {
    _driver_Id = value;
  }

  late String _driver_Name;
  late double _driverLatitude;
  late double _driverLongitude;

  String get driver_Name => _driver_Name;

  set driver_Name(String value) {
    _driver_Name = value;
  }

  double get driverLatitude => _driverLatitude;

  double get driverLongitude => _driverLongitude;

  set driverLongitude(double value) {
    _driverLongitude = value;
  }

  set driverLatitude(double value) {
    _driverLatitude = value;
  }
}