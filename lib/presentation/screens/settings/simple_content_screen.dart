import 'package:flutter/material.dart';

/// Generic reusable screen for static text content (Disclaimer, DL Process,
/// Forms list, etc.) so we don't need a separate widget file per page.
class SimpleContentScreen extends StatelessWidget {
  final String title;
  final String body;

  const SimpleContentScreen({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Text(body, style: const TextStyle(fontSize: 15, height: 1.5)),
      ),
    );
  }
}
