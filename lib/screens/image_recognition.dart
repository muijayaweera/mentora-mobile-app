import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ImageRecognitionScreen extends StatefulWidget {
  final File? imageFile;
  final Uint8List? webImage;

  const ImageRecognitionScreen({
    super.key,
    this.imageFile,
    this.webImage,
  });

  @override
  State<ImageRecognitionScreen> createState() => _ImageRecognitionScreenState();
}

class _ImageRecognitionScreenState extends State<ImageRecognitionScreen> {
  File? _imageFile;
  Uint8List? _webImage;

  final ImagePicker _picker = ImagePicker();

  Interpreter? _interpreter;
  List<String> _labels = [];

  bool _loadingModel = true;
  bool _running = false;

  String? _predLabel;
  double? _predConfidence;

  static const int _inputSize = 224;

  @override
  void initState() {
    super.initState();
    _imageFile = widget.imageFile;
    _webImage = widget.webImage;
    _initModel();
  }

  Future<void> _initModel() async {
    if (kIsWeb) {
      setState(() => _loadingModel = false);
      return;
    }

    try {
      final interpreter = await Interpreter.fromAsset(
        'assets/models/stoma_model_v2.tflite',
      );

      final labelsRaw = await rootBundle.loadString(
        'assets/models/labels_v2.txt',
      );

      final labels = labelsRaw
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      setState(() {
        _interpreter = interpreter;
        _labels = labels;
        _loadingModel = false;
      });

      if (_imageFile != null) {
        await _runInference();
      }
    } catch (e) {
      setState(() => _loadingModel = false);
      debugPrint("Model load error: $e");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 90,
    );
    if (picked == null) return;

    setState(() {
      _predLabel = null;
      _predConfidence = null;
      _running = false;
    });

    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _webImage = bytes;
        _imageFile = null;
      });
      return;
    }

    setState(() {
      _imageFile = File(picked.path);
      _webImage = null;
    });

    await _runInference();
  }

  Future<void> _runInference() async {
    if (kIsWeb) return;
    if (_interpreter == null || _imageFile == null) return;
    if (_labels.isEmpty) {
      debugPrint("Labels are empty");
      return;
    }

    setState(() => _running = true);

    try {
      final bytes = await _imageFile!.readAsBytes();
      final decoded = img.decodeImage(bytes);

      if (decoded == null) {
        setState(() => _running = false);
        debugPrint("Failed to decode image");
        return;
      }

      final resized = img.copyResize(
        decoded,
        width: _inputSize,
        height: _inputSize,
      );

      final input = List.generate(
        1,
            (_) => List.generate(
          _inputSize,
              (y) => List.generate(
            _inputSize,
                (x) {
              final pixel = resized.getPixel(x, y);

              final r = pixel.r.toDouble();
              final g = pixel.g.toDouble();
              final b = pixel.b.toDouble();

              return [r, g, b];
            },
          ),
        ),
      );

      final output = [List<double>.filled(_labels.length, 0.0)];

      _interpreter!.run(input, output);

      final scores = output[0];
      int bestIdx = 0;
      double bestScore = scores[0];

      for (int i = 1; i < scores.length; i++) {
        if (scores[i] > bestScore) {
          bestScore = scores[i];
          bestIdx = i;
        }
      }

      setState(() {
        _predLabel = bestIdx < _labels.length ? _labels[bestIdx] : "unknown";
        _predConfidence = bestScore;
        _running = false;
      });

      debugPrint("Prediction: $_predLabel");
      debugPrint("Confidence: $_predConfidence");
      debugPrint("Scores: $scores");
    } catch (e) {
      setState(() => _running = false);
      debugPrint("Inference error: $e");
    }
  }

  String _prettyLabel(String raw) {
    return raw
        .split('_')
        .map((w) => w.isEmpty ? w : (w[0].toUpperCase() + w.substring(1)))
        .join(' ');
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showImageWidget = () {
      if (_imageFile == null && _webImage == null) {
        return const Icon(Icons.image_outlined, size: 120, color: Colors.grey);
      }
      if (kIsWeb && _webImage != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.memory(_webImage!, height: 260),
        );
      }
      if (!kIsWeb && _imageFile != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(_imageFile!, height: 260),
        );
      }
      return const SizedBox.shrink();
    }();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Recognition"),
        backgroundColor: const Color(0xFFA822D9),
      ),
      backgroundColor: const Color(0xFF1C1C1C),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (_loadingModel)
                  const Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: CircularProgressIndicator(),
                  )
                else
                  showImageWidget,
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA822D9),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library, color: Colors.white),
                  label: const Text(
                    "Pick from Gallery",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                if (!kIsWeb)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA822D9),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text(
                      "Take a Photo",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                const SizedBox(height: 22),
                if (kIsWeb)
                  const Text(
                    "Prediction runs on mobile only (TFLite not supported on web).",
                    style: TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                if (_running) ...[
                  const SizedBox(height: 10),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  const Text(
                    "Analyzing image...",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
                if (_predLabel != null && _predConfidence != null) ...[
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B2B2B),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Prediction",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _prettyLabel(_predLabel!),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Confidence: ${(min(1.0, _predConfidence!) * 100).toStringAsFixed(1)}%",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}