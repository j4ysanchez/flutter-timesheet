import 'package:flutter/material.dart';

class TimestampsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> timestamps;

  TimestampsScreen({required this.timestamps});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stored Timestamps'),
      ),
      body: ListView.builder(
        itemCount: timestamps.length,
        itemBuilder: (context, index) {
          final timestamp = timestamps[index];
          return ListTile(
            title: Text(timestamp.toString()),
          );
        },
      ),
    );
  }
}