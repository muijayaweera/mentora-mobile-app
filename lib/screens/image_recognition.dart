import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageRecognitionScreen extends StatefulWidget {
  const ImageRecognitionScreen({super.key});

  @override
  State<ImageRecognitionScreen> createState() => _ImageRecognitionScreenState();
}

class _ImageRecognitionScreenState extends State<ImageRecognitionScreen> {
  File? _imageFile;
  Uint8List? _webImage;
  final ImagePicker _picker = ImagePicker();
  String? _resultText;

  @override
  void initState() {
    super.initState();

    // Automatically pick from gallery when this page opens
    Future.delayed(Duration(milliseconds: 200), () {
      _pickImage(ImageSource.gallery);
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
          _imageFile = null;
          _resultText = null;
        });
      } else {
        setState(() {
          _imageFile = File(pickedFile.path);
          _webImage = null;
          _resultText = null;
        });
      }
    } else {
      // If user cancels, go back automatically
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Recognition"),
        backgroundColor: const Color(0xFFA822D9),
      ),
      backgroundColor: const Color(0xFF1C1C1C),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_imageFile == null && _webImage == null)
                const Icon(Icons.image_outlined, size: 120, color: Colors.grey)
              else if (kIsWeb && _webImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(_webImage!, height: 250),
                )
              else if (!kIsWeb && _imageFile != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(_imageFile!, height: 250),
                  ),

              const SizedBox(height: 20),

              if (_resultText != null)
                Text(
                  _resultText!,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
