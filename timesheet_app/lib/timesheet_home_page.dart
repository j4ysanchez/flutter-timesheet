import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'timesheet_screen.dart';

class TimesheetHomePage extends StatefulWidget {
  @override
  _TimesheetHomePageState createState() => _TimesheetHomePageState();
}

class _TimesheetHomePageState extends State<TimesheetHomePage> {
  DateTime? _startTime;
  DateTime? _endTime;
  Duration? _elapsedTime;
  List<Map<String, dynamic>> _timestamps = [];

  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _checkConnectivity();
    _loadTimestamps();
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  Future<Position> _getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void _logTime() async {
    Position position = await _getCurrentLocation();
    setState(() {
      if (_startTime == null) {
        _startTime = DateTime.now();
        _timestamps.add({
          'start': _startTime!,
          'startLocation': position,
        });
      } else {
        _endTime = DateTime.now();
        _elapsedTime = _endTime!.difference(_startTime!);
        _timestamps.last['end'] = _endTime!;
        _timestamps.last['endLocation'] = position;
        _startTime = null; // Reset for next use
      }
      _saveTimestamps();
    });
  }

  void _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
    });
  }

Future<void> _saveTimestamps() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> timestamps = _timestamps.map((timestamp) {
    // Convert DateTime to string
    timestamp['startTime'] = (timestamp['startTime'] as DateTime).toIso8601String();
    timestamp['endTime'] = (timestamp['endTime'] as DateTime).toIso8601String();
    return jsonEncode(timestamp);
  }).toList();
  await prefs.setStringList('timestamps', timestamps);
}

Future<void> _loadTimestamps() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? timestamps = prefs.getStringList('timestamps');
  if (timestamps != null) {
    setState(() {
      _timestamps = timestamps.map((timestamp) {
        Map<String, dynamic> decoded = jsonDecode(timestamp) as Map<String, dynamic>;
        // Convert string back to DateTime
        decoded['startTime'] = DateTime.parse(decoded['startTime']);
        decoded['endTime'] = DateTime.parse(decoded['endTime']);
        return decoded;
      }).toList();
    });
  }
}

  void _showTimestamps() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TimestampsScreen(timestamps: _timestamps)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timesheet App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _showTimestamps,
              child: Text('Show Timestamps'),
            ),
            ElevatedButton(
              onPressed: _logTime,
              child: Text(_startTime == null ? 'Start Work' : 'Stop Work'),
            ),
            if (!_isConnected)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'No internet connection',
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            if (_timestamps.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _timestamps.length,
                  itemBuilder: (context, index) {
                    final timestamp = _timestamps[index];
                    return ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Start: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: '${timestamp['start']}',
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Start Location: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text:
                                      '${timestamp['startLocation'].latitude}, ${timestamp['startLocation'].longitude}',
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (timestamp.containsKey('end'))
                            Column(
                              children: [
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'End: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: '${timestamp['end']}',
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'End Location: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text:
                                            '${timestamp['endLocation'].latitude}, ${timestamp['endLocation'].longitude}',
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
