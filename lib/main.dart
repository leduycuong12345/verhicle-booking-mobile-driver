import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'Controller/LoginController.dart';
import 'location_service.dart';

void main() {
  runApp(const MyApp());
  //runApp( MapScreen());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      //debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        primaryColor: Colors.white,
      ),
      //home: const MyHomePage(title: 'Flutter Demo Home Page'),
      //home:const MapSample(),
      home: LoginScreen(),
    );
  }
}

/*class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

 */

class MapSample extends StatefulWidget {
  const MapSample({super.key});

  @override
  State<MapSample> createState() => MapSampleState();
}
class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();
  TextEditingController _originController=TextEditingController();
  TextEditingController _destinationController=TextEditingController();

  Set<Marker> _markers=Set<Marker>();
  Set<Polygon> _polygons=Set<Polygon>();
  Set<Polyline> _polylines=Set<Polyline>();
  List<LatLng> polygonLatLngs=<LatLng>[];

  int _polygonIdCounter =1;
  int _polylineIdCounter =1;
  /*static const _initialCameraPosition = CameraPosition(
    target:LatLng(37.773972,-122.431297),
    zoom: 11.5,
  );

  //late GoogleMapController _googleMapController;
  //late Marker _origin; //the value of the field '_origin' isn't used.
  //late Marker _destination; //the value of the filed '_destination' isn't used.
  @override
  void dispose(){
    _googleMapController.dispose();
    super.dispose();
  }

   */
  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);
  @override
  void initState(){
    super.initState();

    _setMarker(LatLng(37.43296265331129, -122.08832357078792));
  }

  void _setMarker(LatLng point)
  {
    setState((){
      _markers.add(
        Marker(
          markerId:MarkerId('marker'),
          position: point,
        ),
      );
    });
  }
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
        width:2,
        color:Colors.blue,
        points:points
            .map((point)=>LatLng(point.latitude,point.longitude),
        ).toList()
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text('Google Maps'),),
      body:Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(children: [
                    TextFormField(
                    controller:_originController,
                    decoration: InputDecoration(hintText:'Origin'),
                    onChanged:(value){
                      print(value);
                     },
                    ),
                    TextFormField(
                      controller:_destinationController,
                      decoration: InputDecoration(hintText:'Destination'),
                      onChanged:(value){
                        print(value);
                        },
                    ),
                ],
                ),
              ),

              IconButton(
                onPressed: () async {
                  var directions=await  LocationService().getDirection(
                      _originController.text, _destinationController.text
                  );
                  _goToPlace(directions['start_location']['lat'],directions['start_location']['lng']);

                  _setPolyline(directions['polyline_decoded']);
                },
                icon:Icon(Icons.search),),
            ],
          ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.hybrid,
              markers:_markers,
              polygons:_polygons,
              polylines: _polylines,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              initialCameraPosition: _kLake,
              onTap: (point){
                setState(() {
                  polygonLatLngs.add(point);
                  _setPolygon();
                });
              },
            ),
          ),
        ],
      )
    );

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
           CameraPosition(target:LatLng(lat,lng),zoom:12),
    ));

    _setMarker(LatLng(lat,lng));
  }

/*void _addMarker(LatLng pos)
  {
    if(_origin == null || (_origin != null && _destination !=null))
      {
        //origin is not set OR origin/destination are both set
        //set Origin
        setState(() {
          _origin=Marker(
            markerId:const MarkerId('origin'),
            infoWindow: const InfoWindow(title: 'Origin'),
            icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            position:pos,
          );
          //_destination=null;
        });
      }
    else
      {
          //origin is already set
        //set destination
        _destination=Marker(
          markerId:const MarkerId('destination'),
          infoWindow: const InfoWindow(title: 'Destination'),
          icon:
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          position:pos,
        );
      }
  }*/
}

