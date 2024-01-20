import 'package:flutter/material.dart';

class CompileResultPage extends StatelessWidget {
  final Image image;

  const CompileResultPage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compilation result'),
      ),
      body: Center(
        child: image,
      ),
    );
  }
}
