import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Screen')),
      body: Center(child: Text('You made it here!')),
    );
  }
}
