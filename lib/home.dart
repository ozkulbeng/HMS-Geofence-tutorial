import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:huawei_location/location/fused_location_provider_client.dart';
import 'package:huawei_location/location/location.dart';
import 'package:huawei_location/permission/permission_handler.dart';
import 'package:huawei_map/components/latLng.dart';
import 'package:huawei_map/map.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  LatLng center = LatLng(0, 0);
  PermissionHandler permissionHandler;
  FusedLocationProviderClient locationService;
  String infoText = "";
  static const double _zoom = 12;
  HuaweiMapController mapController;

  final Set<Marker> _markers = {};
  int _markerId = 1;
  final Set<Circle> _circles = {};
  int _circleId = 1;
  double _radius = 30;
  bool _clicked = false;

  @override
  void initState() {
    permissionHandler = PermissionHandler();
    locationService = FusedLocationProviderClient();
    getCurrentLatLng();
    super.initState();
  }

  addMarker(LatLng latLng) {
    Marker marker = Marker(
      markerId: MarkerId(_markerId.toString()),
      position: latLng,
      clickable: false,
      icon: BitmapDescriptor.defaultMarker,
    );
    setState(() {
      _markers.add(marker);
    });
    _markerId++;
  }

  addCircle(LatLng latLng) {
    Circle circle = Circle(
      circleId: CircleId(_circleId.toString()),
      fillColor: Colors.grey[400],
      strokeColor: Colors.red,
      center: latLng,
      clickable: false,
      radius: _radius,
    );
    setState(() {
      _clicked = true;
      _circles.add(circle);
    });
    _circleId++;
  }

  clearWindow() {
    setState(() {
      _markers.clear();
      _circles.clear();
    });
  }

  void getCurrentLatLng() async {
    await requestPermission();
    Location currentLocation = await getLastLocation();
    LatLng latLng = LatLng(currentLocation.latitude, currentLocation.longitude);
    print(currentLocation.latitude.toString() +
        " , " +
        currentLocation.longitude.toString());
    setState(() {
      center = latLng;
      print("getcurrentcenter ${center.lat} , ${center.lng}");
      print("getcurrentlatlng ${latLng.lat} , ${latLng.lng}");

      //mapController.animateCamera(CameraUpdate.newCameraPosition(
      //  CameraPosition(target: center, zoom: _zoom)));

      CameraUpdate cameraUpdate = CameraUpdate.newLatLngZoom(center, _zoom);
      mapController.animateCamera(cameraUpdate);
    });
  }

  Future<void> requestPermission() async {
    bool hasPermission = await permissionHandler.hasLocationPermission();
    print("has permission: $hasPermission");
    if (!hasPermission) {
      try {
        bool status = await permissionHandler.requestLocationPermission();
        setState(() {
          infoText = "Is permission granted $status";
        });
      } catch (e) {
        setState(() {
          infoText = e.toString();
        });
      }
    }
  }

  Future<Location> getLastLocation() async {
    Location location;
    try {
      location = await locationService.getLastLocation();
      setState(() {
        infoText = location.toString();
      });
    } catch (e) {
      location = null;
      setState(() {
        infoText = e.toString();
      });
    }
    return location;
  }

  _onMapCreated(HuaweiMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    print("build ${center.toString()}");
    return Scaffold(
      appBar: AppBar(
        title: Text("HMS Geofence"),
      ),
      body: Stack(
        children: <Widget>[
          HuaweiMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: center, zoom: 20),
            mapType: MapType.normal,
            onClick: (LatLng latLng) {
              addMarker(latLng);
              addCircle(latLng);
            },
            markers: _markers,
            circles: _circles,
            tiltGesturesEnabled: true,
            buildingsEnabled: true,
            compassEnabled: true,
            zoomControlsEnabled: true,
            rotateGesturesEnabled: true,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            trafficEnabled: true,
          ),
          Column(
            children: <Widget>[
              Container(
                  padding: EdgeInsets.all(8.0),
                  child: RaisedButton(
                    onPressed: clearWindow,
                    child: Text("Clear Window"),
                  )),
            ],
          ),

        ],
      ),
    );
  }
}
