import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

import '../Model/Account.dart';
import '../Model/Tokens.dart';
import '../Service/DriverService/DriverService.dart';
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
  Set<Marker> _markers=Set<Marker>();

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: CameraPosition(
          target: LatLng(_pos.latitude,_pos.longitude),
          zoom: 18,
        ),
        markers:{
          Marker(
          markerId:MarkerId ('_driverPos'),
          infoWindow: InfoWindow(title:'Tài xế'),
          icon:BitmapDescriptor.defaultMarker,
          position: LatLng(_pos.latitude,_pos.longitude),
          ),
        },
        onMapCreated: (GoogleMapController controller) async{
          _controller.complete(controller);

          //LatLng pos=await DriverService(this._tokens).getCurrentDriverPosition();
          //await _goToPlace(pos.latitude,pos.longitude);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:()async{
          Response res =await _postRequestToSearchForClient();
          if(res.statusCode==200)
            {
              print("found client status: "+res.statusCode.toString()+ "json:"+res.body.toString());

              var responseData = json.decode(res.body);
              _goToPlace(responseData["gps_lat"],responseData["gps_long"]);
            }
          else
            {
              //khong tim thay khach hang
            }
        } ,

        label: const Text('Tìm kiếm khách hàng'),
        icon: const Icon(Icons.car_rental),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  Future<Response> _postRequestToSearchForClient() async
  {
      Response res=await DriverService(_tokens).postRequestToSearchForClient(_pos);
      return res;
  }
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
          CameraPosition(target:LatLng(lat,lng),zoom:19),
        ));

    _setMarker(LatLng(lat,lng));
  }
  void _setMarker(LatLng point)
  {
    setState((){
      _markers.add(
        Marker(
          markerId:MarkerId('_clientPos'),
          position: point,
          infoWindow: InfoWindow(title:'Khách hàng'),
          icon:BitmapDescriptor.defaultMarker,
        ),
      );
    });
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