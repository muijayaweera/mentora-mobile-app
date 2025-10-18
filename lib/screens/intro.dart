import 'package:flutter/material.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intro'),
        backgroundColor: Colors.teal,
      ),
      body: const Center(
        child: Text('This is the Intro screen'),
      ),
    );
  }
}
