import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

import '../Model/Account.dart';
import '../Model/CallCenter.dart';
import '../Model/Tokens.dart';
import '../Service/DriverService/DriverService.dart';
import '../Service/DriverService/SocketDriverService.dart';
import '../Service/GoogleService/location_service.dart';
import '../Service/LoginService/APITokensHolder.dart';
class ActionScreen extends StatefulWidget {
  late Tokens _tokens;
  late LatLng _pos;

  LatLng get pos => _pos;

  set pos(LatLng value) {
    _pos = value;
  }

  Tokens get tokens => _tokens;

  set tokens(Tokens value) {
    _tokens = value;
  }

  ActionScreen(this._tokens,this._pos, {super.key});

  @override
  State<ActionScreen> createState() => ActionMapState(_tokens,_pos);
}
class ActionMapState extends State<ActionScreen> {
  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();
  late Tokens _tokens;
  LatLng _pos;
  bool isWorking=false;//if success to get response after send post request : "../api/v1/driver/join"
  SocketDriverService socketConnection=new SocketDriverService();
  late CallCenter _client;
  Set<Marker> _markers=Set<Marker>();
  Set<Polygon> _polygons=Set<Polygon>();
  Set<Polyline> _polylines=Set<Polyline>();
  List<LatLng> polygonLatLngs=<LatLng>[];

  int _polygonIdCounter =1;
  int _polylineIdCounter =1;
  LatLng get pos => _pos;

  set pos(LatLng value) {
    _pos = value;
  }

  ActionMapState(this._tokens,this._pos);
  Tokens get tokens => _tokens;


  @override
  void initState(){
    super.initState();
  }
  /*void _setMarker(LatLng point)
  {
    setState((){
      _markers.add(
        Marker(
          markerId:MarkerId('marker'),
          position: point,
        ),
      );
    });
  }*/
  void _setPolygon(){
    final String polygonIdVal='polygon_$_polygonIdCounter';

    _polygons.add(
      Polygon(
        polygonId:PolygonId(polygonIdVal),
        points:polygonLatLngs,
        strokeWidth:2,
        fillColor: Colors.transparent,
      ),
    );

  }
  void _setPolyline(List<PointLatLng> points){
    final String polylineIdVal='polyline_$_polylineIdCounter';
    _polylineIdCounter++;

    _polylines.add(
      Polyline(
          polylineId: PolylineId(polylineIdVal),
          width:7,
          color:Colors.blue,
          points:points
              .map((point)=>LatLng(point.latitude,point.longitude),
          ).toList()
      ),
    );
  }
  bool isJoinButtonVisible=true;
  bool isConfirmButtonVisible=false;
  bool isDenyButtonVisible=false;
  bool isClosestDriver=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text('Google Maps'),),
      body:Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            markers:_markers,
            polygons: _polygons,
            polylines: _polylines,
            initialCameraPosition: CameraPosition(//starter from driver position
              target: LatLng(_pos.latitude,_pos.longitude),
              zoom: 18,
            ),
            /*markers:{
              Marker( //driver marker
              markerId:MarkerId ('_driverPos'),
              infoWindow: InfoWindow(title:'Tài xế'),
              icon:BitmapDescriptor.defaultMarker,
              position: LatLng(_pos.latitude,_pos.longitude),
              ),
            markers: {
              _markers,
            },*/
            onMapCreated: (GoogleMapController controller) async{
              _controller.complete(controller);
              _setDriverMarker(_pos);
              //LatLng pos=await DriverService(this._tokens).getCurrentDriverPosition();
              //await _goToPlace(pos.latitude,pos.longitude);
            },
              zoomControlsEnabled: false,
              zoomGesturesEnabled: true,
              scrollGesturesEnabled: true,
              compassEnabled: true,
              rotateGesturesEnabled: true,
              mapToolbarEnabled: true,
              tiltGesturesEnabled: true,
              gestureRecognizers: < Factory < OneSequenceGestureRecognizer >> [
                new Factory < OneSequenceGestureRecognizer > (
                      () => new EagerGestureRecognizer(),
                ),
              ].toSet() // Enable zoom controls
          ),
          Positioned(
            bottom: 16.0,
            left: 0.0,
            right: 0.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Visibility(
              visible: isJoinButtonVisible,
              child: ElevatedButton(
                onPressed:()async{
                  await driverConnectToServer(); // finish stage 1
                  await receiveClientInfo_Stage();//finish stage 2
                  await this.socketConnection.beg(); //start stage 3
                  isClosestDriver = await this.socketConnection.isTheClosestOneCanConfirm();
                  if(isClosestDriver)
                    {
                      setState(() {
                        isDenyButtonVisible=true;
                        isConfirmButtonVisible=true;
                      });

                    }
                } ,
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.car_rental), // Replace with your desired icon
                    SizedBox(width: 8.0), // Adjust the spacing as needed
                    Text('Tìm kiếm khách hàng'),
                  ],
                ),
              ),
            ),
                Visibility(
                  visible: isConfirmButtonVisible,
                  child: ElevatedButton(
                    onPressed:()async{
                      await this.socketConnection.confirm();
                      bool confirmResult=await this.socketConnection.getConfirmResult();
                      if(confirmResult)
                        {
                          setState(() {
                            isDenyButtonVisible=false;
                            isConfirmButtonVisible=false;
                          });
                          _successToConfirmNotification();
                        }
                    } ,
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.car_rental), // Replace with your desired icon
                        SizedBox(width: 8.0), // Adjust the spacing as needed
                        Text('Chấp nhận chuyến đi'),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: isDenyButtonVisible,
                  child: ElevatedButton(
                    onPressed:()async{
                      await this.socketConnection.leave();
                      bool denyResult=await this.socketConnection.getLeaveResult();
                      if(denyResult)
                      {
                        setState(() {
                          isDenyButtonVisible=false;
                          isConfirmButtonVisible=false;
                        });
                        _successToDenyNotification();
                      }
                    } ,
                    child:Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.car_rental), // Replace with your desired icon
                        SizedBox(width: 8.0), // Adjust the spacing as needed
                        Text('Từ chối chuyến đi'),
                      ],
                    ),
                  ),
                ),
            ]
          ),)
        ],
      ),
      /*floatingActionButton: FloatingActionButton.extended(
        onPressed:()async{
          await driverConnectToServer(); // finish stage 1
          await receiveClientInfo_Stage();//finish stage 2
        } ,

        label: const Text('Tìm kiếm khách hàng'),
        icon: const Icon(Icons.car_rental),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,*/

    );
  }

  Future<void> driverConnectToServer() async {
    socketConnection.initzJoinStage(pos, tokens.accessToken);
    await socketConnection.join();
    await _joinStageNotification();
  }

  Future<void> receiveClientInfo_Stage() async {
    _client= await socketConnection.retriveClientInfo();
    String statusCode =_client.statusCode;//await _postRequestToSearchForClient();
    if(statusCode=="200")
      {
        print("join the wait line with status: "+statusCode);
        isWorking=true;//trigger on

        //_goToPlace(_client.gpsLat,_client.gpsLong);// client place

        var directions=await  LocationService().getSocketDirection(
            _pos.latitude, _pos.longitude,
                 _client.gpsLat ,_client.gpsLong
        );
        print("json String: "+directions.toString());
        _goToPlace(directions['end_location']['lat'],directions['end_location']['lng']);
        _setDriverMarker(LatLng(_pos.latitude, _pos.longitude));
        _setPolyline(directions['polyline_decoded']);

        _successReceiveClientInfoNotification();
      }
    else
      {
        //khong tim thay khach hang hoca loi khac
        _failReceiveClientInfoNotification();
      }
  }
  /*Future<String> _postRequestToSearchForClient() async
  {
      *//*Response res=await DriverService(_tokens).postRequestToSearchForClient(_pos);*//*
      //return await this._socketConnect.postRequestToSearchForClient(pos, _tokens.accessToken);
    return  test.onConnectCallback(pos, _tokens.accessToken);
  }*/
  Future<void> _goToPlace(
      //Map<String,dynamic> place
      double lat,
      double lng
      )
  async {
    //   final double lat=place['geometry']['location']['lat'];
    //   final double lng=place['geometry']['location']['lng'];
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target:LatLng(lat,lng),zoom:18),
        ));

    _setClientMarker(LatLng(lat,lng));
  }

  void _setClientMarker(LatLng point)
  {
    setState((){
      _markers.add(
        Marker(
          markerId:MarkerId('_clientPos'),
          position: point,
          infoWindow: InfoWindow(title:'Khách hàng:${_client.tenkhachhang},SĐT:${_client.sdt}' ,
              snippet:'${_client.sonha} ${_client.duong} ${_client.phuong} ${_client.quan} ${_client.thanhpho}'),
          icon:BitmapDescriptor.defaultMarker,
        ),
      );
    });
  }
  void _setDriverMarker(LatLng point)
  {
    setState((){
      _markers.add(
        Marker(
          markerId:MarkerId('_driverPos'),
          position: point,
          infoWindow: InfoWindow(title:'Tài xế'),
          icon:BitmapDescriptor.defaultMarker,
        ),
      );
    });
  }
  Future<void> _successReceiveClientInfoNotification() async
  {
    isJoinButtonVisible=false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check,
              color: Colors.green,
            ),
            SizedBox(width: 8), // Adjust the spacing as needed
            Expanded(
              child: Text(
                'Nhận được thông tin khách hàng và tiến hành đợi xác nhận',
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black.withOpacity(0.5),
        duration: Duration(seconds: 15),
      ),
    );
  }
  Future<void> _failReceiveClientInfoNotification() async
  {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check,
              color: Colors.green,
            ),
            SizedBox(width: 8), // Adjust the spacing as needed
            Expanded(
              child: Text(
                'Không được thông tin khách hàng',
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black.withOpacity(0.5),
        duration: Duration(seconds: 15),
      ),
    );
  }
  Future<void> _successToConfirmNotification() async
  {
    isJoinButtonVisible=false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check,
              color: Colors.green,
            ),
            SizedBox(width: 8), // Adjust the spacing as needed
            Expanded(
              child: Text(
                'Lấy chuyến đi thành công chúc bạn vui vẻ.',
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black.withOpacity(0.5),
        duration: Duration(seconds: 15),
      ),
    );
  }
  Future<void> _successToDenyNotification() async
  {
    isJoinButtonVisible=false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check,
              color: Colors.green,
            ),
            SizedBox(width: 8), // Adjust the spacing as needed
            Expanded(
              child: Text(
                'Từ chối chuyến đi thành công chúc bạn vui vẻ.',
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black.withOpacity(0.5),
        duration: Duration(seconds: 15),
      ),
    );
  }
  Future<void> _joinStageNotification() async
  {
      String status =await socketConnection.isJoinTheSearchClient();

      // Display the half-invisible notification
      if(status=="200") {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.check,
                    color: Colors.green,
                  ),
                  SizedBox(width: 8), // Adjust the spacing as needed
                  Expanded(
                    child: Text(
                      'Đã thành công gia nhập hàng đợi để tìm kiếm khách hàng',
                      overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.black.withOpacity(0.5),
            duration: Duration(seconds: 15),
          ),
        );
      }
      else
        {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                  SizedBox(width: 8), // Adjust the spacing as needed
                  Expanded(
                    child: Text(
                      'Thất bại gia nhập hàng đợi để tìm kiếm khách hàng',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.black.withOpacity(0.5),
              duration: Duration(seconds: 15),
            ),
          );
        }
  }
  // Future<void> updateCurrentDriverPos(id) async {
  //   final GoogleMapController controller = await _controller.future;
  //
  //   //init camera position
  //   LatLng pos=await DriverService(this._tokens).getCurrentDriverPosition();
  //   _currentDriverPos=CameraPosition(
  //     target: pos,
  //     zoom: 11.5,
  //   );
  //   await controller.animateCamera(CameraUpdate.newCameraPosition(_currentDriverPos));
  //
  //   Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  //   final marker = markers.values.toList().firstWhere((item) => item.markerId == id);
  //   //init marker position
  //   _driverMarker=Marker(
  //     markerId: marker.markerId,
  //     onTap: () {
  //       print("tapped");
  //     },
  //     infoWindow: InfoWindow(title:'Tài xế'),
  //     icon:BitmapDescriptor.defaultMarker,
  //     position: pos,
  //   );
  //   setState(() {
  //     //the marker is identified by the markerId and not with the index of the list
  //     markers[id] = _driverMarker;
  //   });
  // }
}