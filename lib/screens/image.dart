import 'package:flutter/material.dart';

class ImageRecognitionScreen extends StatelessWidget {
  const ImageRecognitionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ImageRecognition'),
        backgroundColor: Colors.teal,
      ),
      body: const Center(
        child: Text('This is the ImageRecognitionScreen'),
      ),
    );
  }
}
