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
  int count=0;
  Future<String> isJoinTheSearchClient() async
  {
    if(isJoin=="")
    {
      print('no result from join stage');
      if(count==3)
        {
          join();
          count=0;
        }
      count++;
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
  Future<void> beg() async {
    stompClient = StompClient(
      config:  StompConfig(
        url: 'ws://10.0.2.2:8069/socket/gs-mobile-websocket',
        onConnect: await onBegToConfirmConnectCallback,
        onWebSocketError: onWebSocketErrorCallback,
      ),
    );
    stompClient.activate();
  }
  bool begResult=false;
  Future<bool> isTheClosestOneCanConfirm() async
  {
    if(begResult==false)
    {
      print('this s not u turn to confirm ');
      beg();
      //if not initz yet then wait for 5 sec then call this againt
      await Future.delayed(const Duration(seconds: 5));
      return isTheClosestOneCanConfirm();
    }
    else
    {
      print('time to confirm something');
      return begResult;
    }
  }
  Future<void> onBegToConfirmConnectCallback(StompFrame frame) async{
    Map<String, dynamic> credentials = {
    };
    String message = jsonEncode(credentials);

    //test sending
    stompClient.send(destination: '/socket/driver/beg', body: message, headers: {
      'Content-Type': 'application/json',
      'Authorization': accessToken,
    });


    stompClient.subscribe(
      destination: '/socket/driver/beg-result',
      callback: (StompFrame frame) {
        print('begging result : ${frame.body}');
        // end the subcribe
        this.begResult=bool.parse(frame.body.toString());
        stompClient.deactivate();
        // Access the "driver_ID" field

      },
    );
  }
  Future<void> confirm() async {
    stompClient = StompClient(
      config:  StompConfig(
        url: 'ws://10.0.2.2:8069/socket/gs-mobile-websocket',
        onConnect: await onConfirmConnectCallback,
        onWebSocketError: onWebSocketErrorCallback,
      ),
    );
    stompClient.activate();
  }
  bool confirmResult=false;
  Future<bool> getConfirmResult() async
  {
    if(confirmResult==false)
    {
      print('this s not u turn to confirm ');
      confirm();
      //if not initz yet then wait for 5 sec then call this againt
      await Future.delayed(const Duration(seconds: 5));
      return getConfirmResult();
    }
    else
    {
      print('time to confirm something');
      return confirmResult;
    }
  }
  Future<void> onConfirmConnectCallback(StompFrame frame) async{
    Map<String, dynamic> credentials = {
    };
    String message = jsonEncode(credentials);

    //test sending
    stompClient.send(destination: '/socket/driver/confirm', body: message, headers: {
      'Content-Type': 'application/json',
      'Authorization': accessToken,
    });


    stompClient.subscribe(
      destination: '/socket/driver/confirm-result',
      callback: (StompFrame frame) {
        print('confirm result : ${frame.body}');
        // end the subcribe
        this.confirmResult=bool.parse(frame.body.toString());
        stompClient.deactivate();
        // Access the "driver_ID" field

      },
    );
  }
  Future<void> leave() async {
    stompClient = StompClient(
      config:  StompConfig(
        url: 'ws://10.0.2.2:8069/socket/gs-mobile-websocket',
        onConnect: await onDenyConnectCallback,
        onWebSocketError: onWebSocketErrorCallback,
      ),
    );
    stompClient.activate();
  }
  bool leaveResult=false;
  Future<bool> getLeaveResult() async
  {
    if(leaveResult==false)
    {
      print('this s not u turn to deny ');
      leave();
      //if not initz yet then wait for 5 sec then call this againt
      await Future.delayed(const Duration(seconds: 5));
      return getLeaveResult();
    }
    else
    {
      print('time to deny something');
      return leaveResult;
    }
  }
  Future<void> onDenyConnectCallback(StompFrame frame) async{
    Map<String, dynamic> credentials = {
    };
    String message = jsonEncode(credentials);

    //test sending
    stompClient.send(destination: '/socket/driver/leave', body: message, headers: {
      'Content-Type': 'application/json',
      'Authorization': accessToken,
    });


    stompClient.subscribe(
      destination: '/socket/driver/leave-result',
      callback: (StompFrame frame) {
        print('confirm result : ${frame.body}');
        // end the subcribe
        this.leaveResult=bool.parse(frame.body.toString());
        stompClient.deactivate();
        // Access the "driver_ID" field

      },
    );
  }
}