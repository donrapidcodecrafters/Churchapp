import 'package:flutter/material.dart';

class PresentationScreen extends StatelessWidget {
  final String content;
  PresentationScreen({required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Text(
          content,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 48),
        ),
      ),
    );
  }
}