import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class GazController extends StatefulWidget {
  const GazController({Key? key}) : super(key: key);

  @override
  State<GazController> createState() => _GazControllerState();
}

class _GazControllerState extends State<GazController> {
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref();
  final CollectionReference _temperatureHumidityCollection =
      FirebaseFirestore.instance.collection('data');

  double gaz = 0.0;

  @override
  void initState() {
    super.initState();
    _databaseReference.child('gaz').onValue.listen((event) {
      final data = event.snapshot.value as double;
      setState(() {
        gaz = data;
      });

      // Ensure that 'gaz' node exists in your Firebase Realtime Database
      // Use 'FieldValue.serverTimestamp()' to obtain the server timestamp
      _temperatureHumidityCollection.add({
        'gaz': data,
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                buildCenteredContainer(
                  buildGauge('GAZ: $gaz %', gaz, 0, 100, Colors.blue),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCenteredContainer(Widget child) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(5.0),
        child: child,
      ),
    );
  }

  Widget buildGauge(
      String label, double value, double min, double max, Color color) {
    return Column(
      children: [
        SfRadialGauge(
          axes: <RadialAxis>[
            RadialAxis(
              minimum: min,
              maximum: max,
              ranges: <GaugeRange>[
                GaugeRange(
                  startValue: 0,
                  endValue: value,
                  color: color,
                ),
              ],
              pointers: <GaugePointer>[
                NeedlePointer(
                  value: value,
                  enableAnimation: true,
                ),
              ],
            ),
          ],
        ),
        Text(label),
      ],
    );
  }
}
