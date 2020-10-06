import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:huawei_location/geofence/geofence.dart';
import 'package:huawei_location/geofence/geofence_service.dart';
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
  LatLng center;

  PermissionHandler permissionHandler;
  FusedLocationProviderClient locationService;
  String infoText = "";
  GeofenceService geofenceService;
  static const double _zoom = 18;
  HuaweiMapController mapController;

  final Set<Marker> _markers = {};
  int _markerId = 1;
  final Set<Circle> _circles = {};
  int _circleId = 1;
  final Set<Geofence> _geofences = {};
  double _radius = 30;
  bool _clicked = false;

  @override
  void initState() {
    permissionHandler = PermissionHandler();
    locationService = FusedLocationProviderClient();
    getCurrentLatLng();
    geofenceService = GeofenceService();
    super.initState();
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

      //CameraUpdate cameraUpdate = CameraUpdate.newLatLngZoom(center, _zoom);
      //mapController.animateCamera(cameraUpdate);
    });
  }

  addMarker(LatLng latLng) {
    Marker marker = Marker(
      markerId: MarkerId(_markerId.toString()),
      position: latLng,
      clickable: true,
      infoWindow: InfoWindow(
          title: 'Marker Title $_markerId',
          onClick: () => print("infoWindow clicked")),
      onClick: () {
        setState(() {
          _markers.remove(_markerId.toString()); //not sure
        });
      },
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

  double posx = 100.0;
  double posy = 100.0;

  void onTapDown(BuildContext context, TapDownDetails details) {
    final RenderBox box = context.findRenderObject();
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    setState(() {
      posx = localOffset.dx;
      posy = localOffset.dy;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("build center: ${center.toString()}");
    return Scaffold(
      appBar: AppBar(
        title: Text("HMS Geofence"),
      ),
      body: center == null
          ? CircularProgressIndicator()
          : GestureDetector(
              onTapDown: (TapDownDetails details) =>
                  onTapDown(context, details),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  HuaweiMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition:
                        CameraPosition(target: center, zoom: _zoom),
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
                    trafficEnabled: false,
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(8.0),
                        child: RaisedButton(
                          onPressed: clearWindow,
                          child: Text("Clear Window"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
