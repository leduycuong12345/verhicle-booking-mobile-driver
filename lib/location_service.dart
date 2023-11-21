import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
class LocationService{
  final String key='AIzaSyB5Tf45NZaTF9fCMjQu23bGJHRpPtwvfm4';

  Future<String> getPlaceId(String input) async{
      final String url="https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=$key";
      var response=await http.get(Uri.parse(url));
      var json = convert.jsonDecode(response.body);
      print("json:" +json.toString());
      print("json[candidates]:" +json['candidates'].toString());
      print("json[candidates][0]:" +json['candidates'][0].toString());
      print("json[candidates][0]['placeId']:" +json['candidates'][0]['place_id'].toString());
      var placeId=json['candidates'][0]['place_id'] as String;

      print("place_id:" +placeId);

      return placeId;
  }
  Future <Map<String,dynamic>> getPlace(String input) async{
    final placeId=await getPlaceId(input);
    final String url="https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key";

    var response=await http.get(Uri.parse(url));
    var json=convert.jsonDecode(response.body);
    print("json:" +json.toString());
    var results=json['result'] as Map<String,dynamic>;

    print(results);
    return results;
  }
}