import 'package:flutter/material.dart';

class SupportHomeScreen extends StatelessWidget {
  const SupportHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دعم فني')),
      body: const Center(child: Text('مرحباً دعم فني')),
    );
  }
}