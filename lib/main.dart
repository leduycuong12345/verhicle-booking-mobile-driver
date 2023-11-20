import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
      home:const MapSample(),
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
  }*/
  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 11.5,
  );
  static const Marker _kGooglePlexMarker=Marker(
    markerId:MarkerId ('_kGooglePlex'),
    infoWindow: InfoWindow(title:'Google Plex'),
    icon:BitmapDescriptor.defaultMarker,
    position: LatLng(37.43296265331129, -122.08832357078792),
  );
  static const Marker _kLakeMarker=Marker(
    markerId:MarkerId ('_kLakeMarker'),
    infoWindow: InfoWindow(title:'Google Plex'),
    icon:BitmapDescriptor.defaultMarker,
    position: LatLng(37.43296265331129, -122),
  );
  static final Polyline _kPolyline=Polyline(
      polylineId: PolylineId('_kPolyline'),
      points:[
        LatLng(37.43296265331129, -122.08832357078792),
        LatLng(37.43296265331129, -122),
      ],
      width:5,
  );
  static final Polygon _kPolygon=Polygon(
      polygonId:PolygonId('_kPolygon'),
      points:[
        LatLng(37.43296265331129, -122.08832357078792),
        LatLng(37.43296265331129, -122),
        LatLng(37.41, -122.082),
        LatLng(37.435, -122.083),
      ],
      strokeWidth: 5,
      fillColor: Colors.transparent,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text('Google Maps'),),
      body:Column(
        children: [
          Row(children: [
            Expanded(child: TextFormField()),
            IconButton(onPressed: (){},icon:Icon(Icons.search),),
          ],),
          Expanded(
            child: GoogleMap(
              mapType: MapType.hybrid,
              initialCameraPosition: _kGooglePlex,
              /*markers: {
                const Marker(
                  markerId: MarkerId('Sydney'),
                  position: LatLng(37.43296265331129, -122.08832357078792),
                )},*/
              markers:{
                _kGooglePlexMarker,
                //_kLakeMarker
              },
              polylines:{
                _kPolyline,
              },
              polygons:{
                _kPolygon,
              },
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
          /*floatingActionButton: FloatingActionButton.extended(
            onPressed: _goToTheLake,
            label: const Text('To the lake!'),
            icon: const Icon(Icons.directions_boat),
          ),*/
        ],
      )
    );

  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
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

