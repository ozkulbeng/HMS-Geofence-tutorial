import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geofence_example/add_geofence.dart';
import 'package:huawei_location/geofence/geofence.dart';
import 'package:huawei_location/geofence/geofence_service.dart';
import 'package:huawei_location/location/fused_location_provider_client.dart';
import 'package:huawei_location/location/location.dart';
import 'package:huawei_location/permission/permission_handler.dart';
import 'package:huawei_map/components/latLng.dart';
import 'package:huawei_map/constants/method.dart';
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
  HuaweiMapController mapController;
  ScreenCoordinate screenCoordinates;
  LatLng selectedCoordinates;

  static const double _zoom = 18;

  Marker marker;
  Circle circle;
  Geofence geofence;

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

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
  }

  void getCurrentLatLng() async {
    await requestPermission();
    Location currentLocation = await locationService.getLastLocation();
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
    if (_circles.isNotEmpty) _circles.clear();

    if (marker != null) marker = null;
    marker = Marker(
      markerId: MarkerId(_markerId.toString()),
      position: latLng,
      clickable: true,
      infoWindow: InfoWindow(
          title: 'Marker Title $_markerId',
          onClick: () => print("infoWindow clicked")),
      onClick: () {
        setState(() {
          // _markers.remove(marker); //???
          _clicked = false;
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
    circle = Circle(
      circleId: CircleId(_circleId.toString()),
      fillColor: Colors.grey[400],
      strokeColor: Colors.red,
      center: latLng,
      clickable: false,
      radius: _radius,
    );
    setState(() {
      _circles.add(circle);
    });
    _circleId++;
  }

  clearWindow() {
    setState(() {
      _markers.clear();
      _circles.clear();
      _clicked = false;
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

  _onMapCreated(HuaweiMapController controller) {
    mapController = controller;
  }

  _getScreenCoordinates(LatLng latLng) async {
    screenCoordinates = await mapController.getScreenCoordinate(latLng);
    setState(() {});
    print("SCREEN " + screenCoordinates.x.toString());
    print("SCREEN " + screenCoordinates.y.toString());
  }

  _drawCircle(Geofence geofence) {
    this.geofence = geofence;
    if (circle != null) circle = null;
    circle = Circle(
      circleId: CircleId(_circleId.toString()),
      fillColor: Colors.grey[400],
      strokeColor: Colors.red,
      center: selectedCoordinates,
      clickable: false,
      radius: _radius,
    );
    _circles.add(circle);
  }

  @override
  Widget build(BuildContext context) {
    print("build center: ${center.toString()}");
    return Scaffold(
      appBar: AppBar(
        title: Text("HMS Geofence"),
      ),
      body: center == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                HuaweiMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition:
                      CameraPosition(target: center, zoom: _zoom),
                  mapType: MapType.normal,
                  onClick: (LatLng latLng) {
                    selectedCoordinates = latLng;
                    _getScreenCoordinates(latLng);
                    setState(() {
                      _clicked = true;
                      addMarker(latLng);
                      addCircle(latLng);
                    });
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
                if (_clicked)
                  Positioned(
                    left: screenCoordinates.x.toDouble() / 5,
                    top: screenCoordinates.y.toDouble() / 3,
                    child: RaisedButton(
                      child: Text("Add Geofence"),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => SingleChildScrollView(
                            child: Container(
                              padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom),
                              child: AddGeofenceScreen(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                if (_clicked)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    left: 10,
                    child: Slider(
                      min: 15,
                      max: 70,
                      value: _radius,
                      onChanged: (newValue) {
                        setState(() {
                          _radius = newValue;
                          _drawCircle(geofence);
                        });
                      },
                    ),
                  ),
                Column(
                  children: <Widget>[
                    if (_clicked)
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
    );
  }
}
