import 'package:flutter/material.dart';

class ScheduledScreen extends StatelessWidget {
  const ScheduledScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Lists'),
      ),
      body: const Center(
        child: Text('No set lists yet.'),
      ),
    );
  }
}
