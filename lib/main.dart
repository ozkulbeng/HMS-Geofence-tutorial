import 'package:flutter/material.dart';
import 'package:geofence_example/home.dart';
import 'package:huawei_map/map.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Home(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //PermissionHandler permissionHandler;
  String infoText = "";
  static const LatLng center = LatLng(50.585070, 8.713720);

@override
  void initState() {
  //permissionHandler = PermissionHandler();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: HuaweiMap(
          initialCameraPosition: CameraPosition(target: center, zoom: 12),
          mapType: MapType.normal,
          tiltGesturesEnabled: true,
          buildingsEnabled: true,
          compassEnabled: true,
          zoomControlsEnabled: false,
          rotateGesturesEnabled: true,
          myLocationButtonEnabled: false,
          myLocationEnabled: false,
          trafficEnabled: true,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        child: Icon(Icons.location_on),
      ),
    );
  }



}
