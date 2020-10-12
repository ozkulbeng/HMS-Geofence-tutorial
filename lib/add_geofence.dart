import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:huawei_location/geofence/geofence.dart';

class AddGeofenceScreen extends StatefulWidget {
  @override
  _AddGeofenceScreenState createState() => _AddGeofenceScreenState();
}

class _AddGeofenceScreenState extends State<AddGeofenceScreen> {
  bool checked = false;
  List<String> _checked = [];

  @override
  Widget build(BuildContext context) {
    final boldStyle = TextStyle(fontWeight: FontWeight.bold);

    List<String> conType = ["Enter", "Exit", "Stay", "Never Expire"];
    return Container(
      //padding: EdgeInsets.all(20),
      color: Colors.white,
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            "38A 36. Sokak",
            style: boldStyle,
          ),
          Text("Address: 38A, 36. Sokak\nBornova, İzmir, 35040\nTürkiye"),
          Text("Radius: 30"),
          Text(
            "Select Conversion Type",
            style: boldStyle,
          ),
          CheckboxGroup(
            labels: conType,
            checked: _checked,
            onChange: (bool isChecked, String label, int index) =>
                print("isChecked: $isChecked   label: $label  index: $index"),
            onSelected: (List selected) => setState(() {
              if (selected.length > 1) {
                selected.removeAt(0);
                print('selected length  ${selected.length}');
              } else {
                print("only one");
              }
              _checked = selected;
            }),
          ),
          FlatButton(
            child: Text("Add"),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}
