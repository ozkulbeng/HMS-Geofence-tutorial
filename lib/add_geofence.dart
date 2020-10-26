import 'package:flutter/material.dart';
import 'package:geofence_example/global.dart';
import 'package:huawei_location/geofence/geofence.dart';
import 'package:huawei_location/geofence/geofence_request.dart';
import 'package:huawei_location/geofence/geofence_service.dart';
import 'package:huawei_site/model/site.dart';
import 'package:huawei_site/search_service.dart';



class AddGeofenceScreen extends StatefulWidget {
  final Geofence geofence;
  final Site site;

  const AddGeofenceScreen({Key key, this.geofence, this.site})
      : super(key: key);

  @override
  _AddGeofenceScreenState createState() => _AddGeofenceScreenState();
}

class _AddGeofenceScreenState extends State<AddGeofenceScreen> {
  GeofenceService geofenceService;
  int selectedConType = Geofence.GEOFENCE_NEVER_EXPIRE;
  SearchService searchService;

  @override
  void initState() {
    geofenceService = GeofenceService();
    searchService = SearchService();
    super.initState();
  }

  void addGeofence(Geofence geofence) async {
    geofence.dwellDelayTime = 10000;
    geofence.notificationInterval = 100;
    geofenceList.add(geofence);
    GeofenceRequest geofenceRequest = GeofenceRequest(geofenceList:
    geofenceList);
    try {
      int requestCode = await geofenceService.createGeofenceList
        (geofenceRequest);
      print(requestCode);
    } catch (e) {
      print(e.toString());
    }
    print(geofenceList);
  }

  @override
  Widget build(BuildContext context) {
    Geofence geofence = widget.geofence;
    Site site = widget.site;
    final boldStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
      color: Colors.white,
      height: 400,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text(
              "Address",
              style: boldStyle,
            ),
            Text(site.formatAddress),
            Text(
              "\nRadius",
              style: boldStyle,
            ),
            Text(geofence.radius.toInt().toString()),
            Text(
              "\nSelect Conversion Type",
              style: boldStyle,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                RadioListTile<int>(
                  dense: true,
                  title: Text(
                    "Enter",
                    style: TextStyle(fontSize: 14),
                  ),
                  value: Geofence.ENTER_GEOFENCE_CONVERSION,
                  groupValue: selectedConType,
                  onChanged: (int value) {
                    setState(() {
                      selectedConType = value;
                    });
                  },
                ),
                RadioListTile<int>(
                  dense: true,
                  title: Text("Exit"),
                  value: Geofence.EXIT_GEOFENCE_CONVERSION,
                  groupValue: selectedConType,
                  onChanged: (int value) {
                    setState(() {
                      selectedConType = value;
                    });
                  },
                ),
                RadioListTile<int>(
                  dense: true,
                  title: Text("Stay"),
                  value: Geofence.DWELL_GEOFENCE_CONVERSION,
                  groupValue: selectedConType,
                  onChanged: (int value) {
                    setState(() {
                      selectedConType = value;
                    });
                  },
                ),
                RadioListTile<int>(
                  dense: true,
                  title: Text("Never Expire"),
                  value: Geofence.GEOFENCE_NEVER_EXPIRE,
                  groupValue: selectedConType,
                  onChanged: (int value) {
                    setState(() {
                      selectedConType = value;
                    });
                  },
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: FlatButton(
                child: Text(
                  "SAVE",
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  geofence.conversions = selectedConType;
                  addGeofence(geofence);
                  Navigator.pop(context, false);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
