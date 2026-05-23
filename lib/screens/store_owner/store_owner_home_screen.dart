import 'package:flutter/material.dart';

class StoreOwnerHomeScreen extends StatelessWidget {
  const StoreOwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('صاحب متجر')),
      body: const Center(child: Text('مرحباً صاحب متجر')),
    );
  }
}