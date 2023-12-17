import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import '../../Model/CallCenter.dart';
import '../../Model/Driver.dart';
class SocketDriverService{
  late StompClient stompClient;
  Future<void> connect() async {
    stompClient = StompClient(
      config:  StompConfig(
        url: 'ws://10.0.2.2:8069/socket/gs-mobile-websocket',
        onConnect: onConnectCallback,
        onWebSocketError: onWebSocketErrorCallback,
      ),
    );
    stompClient.activate();
  }
  void onConnectCallback(StompFrame frame) {

    Map<String, dynamic> credentials = {
      'driverLatitude': pos.latitude ,
      'driverLongitude':  pos.longitude,
      'accessToken':accessToken,
      'destination': '/socket/driver/join',
    };
    String message = jsonEncode(credentials);

    //test sending
    stompClient.send(destination: '/socket/driver/join', body: message, headers: {});

    print('Connected to the WebSocket');
    // Subscribe to a destination
    stompClient.subscribe(
      destination: '/socket/driver/greetings',
      callback: (StompFrame frame) {
        print('Received message: ${frame.body}');
        // Handle the received message
      },
    );

  }

  late LatLng pos;
  late String accessToken;
  String isJoin="";
  void initzJoinStage(LatLng pos,String accessToken)
  {
    this.pos=pos;
    this.accessToken=accessToken;
  }
  void onWebSocketErrorCallback(dynamic error) {
    print('Error on WebSocket: $error');
    // Handle WebSocket errors
  }
  Future<void> join() async {
    stompClient = StompClient(
      config:  StompConfig(
        url: 'ws://10.0.2.2:8069/socket/gs-mobile-websocket',
        onConnect: await onJoinConnectCallback,
        onWebSocketError: onWebSocketErrorCallback,
      ),
    );
    stompClient.activate();
  }
  CallCenter _client=CallCenter(-1, "", "", 0, 0, "", "", "_phuong", "_quan", "_thanhpho", "_statusCode");


  set client(CallCenter value) { // use recusion to hack getter logic
    _client = value;
  }
  Future<CallCenter> retriveClientInfo() async
  {

    if (_client.Id==-1)
      {
        print('not create yet comeback lately');
        //if not initz yet then wait for 5 sec then call this againt
        await Future.delayed(const Duration(seconds: 5));
        return retriveClientInfo();
      }
    else
      {
        print('ha ha we init the client info');
        return _client;
      }
  }
  Future<String> isJoinTheSearchClient() async
  {
    if(isJoin=="")
    {
      print('no result from join stage');
      //if not initz yet then wait for 5 sec then call this againt
      await Future.delayed(const Duration(seconds: 5));
      return isJoinTheSearchClient();
    }
    else
    {
      print('return result from join stage');
      return isJoin;
    }
  }
  Future<void> onJoinConnectCallback(StompFrame frame) async{
    Map<String, dynamic> credentials = {
      'driverLatitude': pos.latitude ,
      'driverLongitude':  pos.longitude,
    };
    String message = jsonEncode(credentials);

    //test sending
    stompClient.send(destination: '/socket/driver/join', body: message, headers: {
      'Content-Type': 'application/json',
      'Authorization': accessToken,
    });

    print('Connected to the WebSocket');
    // Subscribe to a destination
    stompClient.subscribe(
      destination: '/socket/driver/greetings',
      callback: (StompFrame frame) {
        print('Join to search the client with status:${frame.body}');
        isJoin=frame.body.toString();
      },
    );

    stompClient.subscribe(
      destination: '/socket/driver/receive-client-info',
      callback: (StompFrame frame) {
        print('Receive info client: ${frame.body}');
        // end the subcribe
        var messageValue = frame.body;
         initCallCenter(messageValue);
        stompClient.deactivate();
        // Access the "driver_ID" field

      },
    );
  }
  void initCallCenter(var content)
  {
     //print("check mic: ${content}");
     // Parse the JSON string
     Map<String, dynamic> jsonMap = json.decode(content);
     _client=new CallCenter(
         int.parse(jsonMap["callCenterId"].toString()),
         jsonMap["tenkhachhang"].toString(),
         jsonMap["sdt"].toString(),
         double.parse(jsonMap["client_gps_lat"].toString()),
         double.parse(jsonMap["client_gps_long"].toString()),
         jsonMap["sonha"].toString(),
         jsonMap["duong"].toString(),
         jsonMap["phuong"].toString(),
         jsonMap["quan"].toString(),
         jsonMap["thanhpho"].toString(),
         jsonMap["securityStatus"].toString());

  }

}