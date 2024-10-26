import 'package:flutter/material.dart';

class TimesheetHomePage extends StatefulWidget {
  @override
  _TimesheetHomePageState createState() => _TimesheetHomePageState();
}

class _TimesheetHomePageState extends State<TimesheetHomePage> {
  DateTime? _startTime;
  DateTime? _endTime;
  Duration? _elapsedTime;
  List<Map<String, DateTime>> _timestamps = [];

  void _logTime() {
    setState(() {
      if (_startTime == null) {
        _startTime = DateTime.now();
        _timestamps.add({'start': _startTime!});
      } else {
        _endTime = DateTime.now();
        _elapsedTime = _endTime!.difference(_startTime!);
        _timestamps.last['end'] = _endTime!;
        _startTime = null; // Reset for next use
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        title: Text('Timesheet App 2'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _logTime,
              child: Text(_startTime == null ? 'Start Work 2' : 'Stop Work'),
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
                          Text(
                            'Start: ${timestamp['start']}',
                            textAlign: TextAlign.center,
                          ),
                          if (timestamp.containsKey('end'))
                            Text(
                              'End: ${timestamp['end']}',
                              textAlign: TextAlign.center,
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