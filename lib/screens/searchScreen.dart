import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  final String userId;

  const SearchScreen({Key? key, required this.userId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: Center(
        child: Text('Search screen coming soon!'),
      ),
    );
  }
}
