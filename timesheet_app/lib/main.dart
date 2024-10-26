import 'package:flutter/material.dart';
import 'timesheet_home_page.dart';

void main() {
  runApp(TimesheetApp());
}

class TimesheetApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TimesheetHomePage(),
    );
  }
}

