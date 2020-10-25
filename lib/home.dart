import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geofence_example/add_geofence.dart';
import 'package:huawei_location/geofence/geofence.dart';
import 'package:huawei_location/location/fused_location_provider_client.dart';
import 'package:huawei_location/location/location.dart';
import 'package:huawei_location/permission/permission_handler.dart';
import 'package:huawei_map/components/latLng.dart';
import 'package:huawei_map/map.dart';
import 'package:huawei_map/components/components.dart';
import 'package:huawei_site/model/coordinate.dart';
import 'package:huawei_site/model/location_type.dart';
import 'package:huawei_site/model/nearby_search_request.dart';
import 'package:huawei_site/model/nearby_search_response.dart';
import 'package:huawei_site/model/site.dart';
import 'package:huawei_site/search_service.dart';

import 'nearby_search.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with ChangeNotifier {
  LatLng center;
  PermissionHandler permissionHandler;
  FusedLocationProviderClient locationService;
  String infoText = "";

  HuaweiMapController mapController;
  ScreenCoordinate screenCoordinates;
  LatLng selectedCoordinates;

  static const double _zoom = 16;

  Marker marker;
  Circle circle;
  Geofence geofence = Geofence();
  Site site;

  Set<Marker> _markers = {};
  int _markerId = 1;
  final Set<Circle> _circles = {};
  int _circleId = 1;
  int _fenceId = 1;

  double radius = 50;
  bool clicked = false;

  SearchService searchService;

  @override
  void initState() {
    searchService = SearchService();
    permissionHandler = PermissionHandler();
    locationService = FusedLocationProviderClient();
    getCurrentLatLng();
    super.initState();
  }

  void updateClicked(bool newValue) {
    setState(() {
      clicked = newValue;
      _circles.clear();
    });
  }

  void getCurrentLatLng() async {
    await requestPermission();
    Location currentLocation = await locationService.getLastLocation();
    LatLng latLng = LatLng(currentLocation.latitude, currentLocation.longitude);
    setState(() {
      center = latLng;

      //mapController.animateCamera(CameraUpdate.newCameraPosition(
      //  CameraPosition(target: center, zoom: _zoom)));

      //CameraUpdate cameraUpdate = CameraUpdate.newLatLngZoom(center, _zoom);
      //mapController.animateCamera(cameraUpdate);
    });
  }

  addMarker(LatLng latLng) {
    radius = 50;
    if (_circles.isNotEmpty) _circles.clear();

    if (marker != null) marker = null;
    marker = Marker(
      markerId: MarkerId(_markerId.toString()),
      position: latLng,
      clickable: true,
      onClick: () {
        setState(() {
          // _markers.remove(marker); //???
          clicked = false;
        });
      },
      icon: BitmapDescriptor.defaultMarker,
    );
    setState(() {
      _markers.add(marker);
    });
    selectedCoordinates = latLng;
    _markerId++;
  }

  addCircle(LatLng latLng) {
    circle = Circle(
      circleId: CircleId(_circleId.toString()),
      fillColor: Colors.grey[400],
      strokeColor: Colors.red,
      center: latLng,
      clickable: false,
      radius: radius,
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
      clicked = false;
    });
  }

  Future<void> requestPermission() async {
    bool hasPermission = await permissionHandler.hasLocationPermission();
    if (!hasPermission) {
      try {
        bool status = await permissionHandler.requestLocationPermission();
        print("Is permission granted $status");
      } catch (e) {
        print(e.toString());
      }
    }
  }

  _onMapCreated(HuaweiMapController controller) {
    mapController = controller;
  }

  _getScreenCoordinates(LatLng latLng) async {
    screenCoordinates = await mapController.getScreenCoordinate(latLng);
    setState(() {});
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
      radius: radius,
    );
    _circles.add(circle);
  }

  placeSearch(LatLng latLng) async {
    NearbySearchRequest request = NearbySearchRequest();
    request.location = Coordinate(lat: latLng.lat, lng: latLng.lng);
    request.language = "en";
    request.poiType = LocationType.ADDRESS;
    request.pageIndex = 1;
    request.pageSize = 1;
    request.radius = 100;
    NearbySearchResponse response = await searchService.nearbySearch(request);
    try {
      print(response.sites);
      site = response.sites[0];
    } catch (e) {
      print(e.toString());
    }
  }

  final TextEditingController searchQueryController =
      TextEditingController(text: "Pharmacy");

  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Search Location"),
          content: Container(
            height: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                TextField(
                  controller: searchQueryController,
                ),
                MaterialButton(
                  color: Colors.blue,
                  child: Text(
                    "Search",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    _markers =
                        await nearbySearch(center, searchQueryController.text);
                    setState(() {});
                  },
                )
              ],
            ),
          ),
          actions: [
            FlatButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showToast(BuildContext context) {
    final scaffold = Scaffold.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(infoText),
        action: SnackBarAction(
            label: 'Close', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
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
                    placeSearch(latLng);
                    selectedCoordinates = latLng;
                    _getScreenCoordinates(latLng);
                    setState(() {
                      clicked = true;
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
                if (clicked)
                  Positioned(
                    left: screenCoordinates.x.toDouble() / 5,
                    top: screenCoordinates.y.toDouble() / 3,
                    child: RaisedButton(
                      child: Text("Add Geofence"),
                      onPressed: () async {
                        geofence.uniqueId = _fenceId.toString();
                        geofence.radius = radius;
                        geofence.latitude = selectedCoordinates.lat;
                        geofence.longitude = selectedCoordinates.lng;
                        _fenceId++;
                        final clickValue = await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => SingleChildScrollView(
                            child: Container(
                              padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom),
                              child: AddGeofenceScreen(
                                geofence: geofence,
                                site: site,
                              ),
                            ),
                          ),
                        );
                        updateClicked(clickValue);
                      },
                    ),
                  ),
                if (clicked)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    left: 10,
                    child: Slider(
                      min: 50,
                      max: 200,
                      value: radius,
                      onChanged: (newValue) {
                        setState(() {
                          radius = newValue;
                          _drawCircle(geofence);
                        });
                      },
                    ),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                      child: RaisedButton(
                          child: Text("Search Nearby Places"),
                          onPressed: _showAlertDialog),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
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
