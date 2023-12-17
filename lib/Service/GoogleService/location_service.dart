import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:math';
class LocationService{
  String placeAPIkey='AIzaSyA2pDew3MosoZjKt7q6xk32oIroHTKMdOo';
  String newPlaceAPIkey='AIzaSyDOuEs82sEhRtPCPXFddlzjv_8DR19nvXQ';
  String directionAPIkey='AIzaSyBlIgLgFnu0CUG7tx7L9-PQwKSy4O__t0o';
  //String directionAPIkey='AIzaSyA30mtivjeWI_YE1L5OeXCqadaVyQpTbVs';
  Future<String> getPlaceId(String input) async{
      final String url="https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=$placeAPIkey";
      var response=await http.get(Uri.parse(url));
      var json = convert.jsonDecode(response.body);
      print("json:" +json.toString());
      print("json[candidates]:" +json['candidates'].toString());
      print("json[candidates][0]:" +json['candidates'][0].toString());
      print("json[candidates][0]['placeId']:" +json['candidates'][0]['place_id'].toString());
      var placeId=json['candidates'][0]['place_id'] as String;

      print("place_id:" +placeId);

      //sleep so it wont cause spaw to google api
      //await foo();
      return placeId;
  }
  Future <Map<String,dynamic>> getPlace(String input) async{
    final placeId=await getPlaceId(input);
    final String url="https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$placeAPIkey";

    var response=await http.get(Uri.parse(url));
    var json=convert.jsonDecode(response.body);
    print("json:" +json.toString());
    var results=json['result'] as Map<String,dynamic>;

    print(results);
    //sleep so it wont cause spaw to google api
    //await foo();
    return results;
  }
  Future <Map<String,dynamic>> getDirection(String origin, String destination) async{
    final String url=
        "https://maps.googleapis.com/maps/api/directions/json?mode=driving&origin=$origin&destination=$destination&key=$directionAPIkey";

    print("direction url: "+url );
    var response=await http.get(Uri.parse(url));
    var json=convert.jsonDecode(response.body);

    var prettyJson = convert.jsonEncode(json, toEncodable: (object) => object.toString());
    print("json: " + prettyJson);

    // json:{geocoded_waypoints: [{geocoder_status: OK, place_id: ChIJD7fiBh9u5kcRYJSMaMOCCwQ, types: [locality, political]}, {geocoder_status: OK, place_id: ChIJ53USP0nBhkcRjQ50xhPN_zw, types: [locality, political]}], routes: [{bounds: {northeast: {lat: 48.8572882, lng: 9.1892874}, southwest: {lat: 45.04121840000001, lng: 2.3067871}}, copyrights: Map data ©2023 GeoBasis-DE/BKG (©2009), Google, legs: [{distance: {text: 911 km, value: 911418}, duration: {text: 9 hours 14 mins, value: 33225}, end_address: Milan, Metropolitan City of Milan, Italy, end_location: {lat: 45.46495119999999, lng: 9.1892874}, start_address: Paris, France, start_location: {lat: 48.8572882, lng: 2.352395}, steps: [{distance: {text: 80 m, value: 80}, duration: {text: 1 min, value: 23}, end_location: {lat: 48.8575475, lng: 2.3513765}, html_instructions: Head <b>west</b> on <b>Rue de Rivoli</b> toward <b>Pl. de l'Hôtel de Ville</b>, polyline: {points: ameiHomjMERIr@Gf@QdAIT}, start_location: {lat: 48.8572882, lng: 2.352395}, travel_mode: DRIVI
    // D/EGL_emulation( 9044): app_time_stats: avg=141.60ms min=13.95ms max=500.45ms count=10
    var results={
      'bound_ne':json['routes'][0]['bounds']['northeast'],
      'bound_sw':json['routes'][0]['bounds']['southwest'],
      'start_location':json['routes'][0]['legs'][0]['start_location'],
      'end_location':json['routes'][0]['legs'][0]['end_location'],
      'polyline':json['routes'][0]['overview_polyline']['points'],
      'polyline_decoded':PolylinePoints().decodePolyline( json['routes'][0]['overview_polyline']['points']),
    };
    print(results);
    //sleep so it wont cause spaw to google api
    //await foo();
    return results;
  }
  Future <Map<String,dynamic>> getSocketDirection(double driverLat,double driverLng, double clientLat,double clientLng) async{
    await Future.delayed(const Duration(seconds: 10));

    final String url=
        "https://maps.googleapis.com/maps/api/directions/json?mode=driving&origin=$driverLat,$driverLng"
        "&destination=$clientLat,$clientLng&key=$directionAPIkey";

    print("direction url: "+url );
    var response=await http.get(Uri.parse(url));
    var json=convert.jsonDecode(response.body);

    var prettyJson = convert.jsonEncode(json, toEncodable: (object) => object.toString());
    print("json: " + prettyJson);


    if(json["status"]=="OVER_QUERY_LIMIT")
      {
        print("over limit error wait for 10seconds");
        await Future.delayed(const Duration(seconds: 10));
        //return await getSocketDirection( driverLat, driverLng,  clientLat, clientLng);
        return await readJson();//counter OVER_QUERY_LIMIT
      }
    else
      {
        var results={
          'bound_ne':json['routes'][0]['bounds']['northeast'],
          'bound_sw':json['routes'][0]['bounds']['southwest'],
          'start_location':json['routes'][0]['legs'][0]['start_location'],
          'end_location':json['routes'][0]['legs'][0]['end_location'],
          'polyline':json['routes'][0]['overview_polyline']['points'],
          'polyline_decoded':PolylinePoints().decodePolyline( json['routes'][0]['overview_polyline']['points']),
        };
        // json:{geocoded_waypoints: [{geocoder_status: OK, place_id: ChIJD7fiBh9u5kcRYJSMaMOCCwQ, types: [locality, political]}, {geocoder_status: OK, place_id: ChIJ53USP0nBhkcRjQ50xhPN_zw, types: [locality, political]}], routes: [{bounds: {northeast: {lat: 48.8572882, lng: 9.1892874}, southwest: {lat: 45.04121840000001, lng: 2.3067871}}, copyrights: Map data ©2023 GeoBasis-DE/BKG (©2009), Google, legs: [{distance: {text: 911 km, value: 911418}, duration: {text: 9 hours 14 mins, value: 33225}, end_address: Milan, Metropolitan City of Milan, Italy, end_location: {lat: 45.46495119999999, lng: 9.1892874}, start_address: Paris, France, start_location: {lat: 48.8572882, lng: 2.352395}, steps: [{distance: {text: 80 m, value: 80}, duration: {text: 1 min, value: 23}, end_location: {lat: 48.8575475, lng: 2.3513765}, html_instructions: Head <b>west</b> on <b>Rue de Rivoli</b> toward <b>Pl. de l'Hôtel de Ville</b>, polyline: {points: ameiHomjMERIr@Gf@QdAIT}, start_location: {lat: 48.8572882, lng: 2.352395}, travel_mode: DRIVI
        // D/EGL_emulation( 9044): app_time_stats: avg=141.60ms min=13.95ms max=500.45ms count=10

        print(results);
        //sleep so it wont cause spaw to google api
        return results;
      }
  }

  Future<void> foo() async {
    print('foo started');
    await Future.delayed(Duration(seconds: 2500));
    print('foo executed');
    return;
  }
  String getRandomString(List<String> stringList) {
    if (stringList.isEmpty) {
      return placeAPIkey; // Return null if the list is empty
    }

    Random random = Random();
    int randomIndex = random.nextInt(stringList.length);

    return stringList[randomIndex];
  }
  String randomDirectionKeyAPI() {
    List<String> myStrings = [
      "AIzaSyCSvZVARje22D-JB2MjcRQ7PfLuyM_ZPDw",
      "AIzaSyBlIgLgFnu0CUG7tx7L9-PQwKSy4O__t0o",
      "AIzaSyC9wPYfVvcEkBLwPaLQNZbMWsOkBVIzCDs",
    ];

    String randomString = getRandomString(myStrings);
    print("Randomly picked string: $randomString");
    return randomString;
  }
  Future<Map<String, dynamic>> readJson() async {
    // Load the JSON file
    final String jsonString = await rootBundle.loadString('assets/directionAPI.json');

    // Parse the JSON
    print("json string :"+jsonString);
    var pretty= await  json.decode(jsonString);
    var results={
      'bound_ne':pretty['routes'][0]['bounds']['northeast'],
      'bound_sw':pretty['routes'][0]['bounds']['southwest'],
      'start_location':pretty['routes'][0]['legs'][0]['start_location'],
      'end_location':pretty['routes'][0]['legs'][0]['end_location'],
      'polyline':pretty['routes'][0]['overview_polyline']['points'],
      'polyline_decoded':PolylinePoints().decodePolyline( pretty['routes'][0]['overview_polyline']['points']),
    };
    return results;
  }

}

