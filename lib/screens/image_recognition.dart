import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../constants/ui_constants.dart';

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
  static const double _invalidThreshold = 0.70;

  @override
  void initState() {
    super.initState();
    _imageFile = widget.imageFile;
    _webImage = widget.webImage;
    _initModel();
  }

  Future<void> _saveImageReview({
    required File imageFile,
    required String prediction,
    required double confidence,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      final fileName =
          'image_reviews/${user?.uid ?? "unknown"}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final ref = FirebaseStorage.instance.ref().child(fileName);

      await ref.putFile(imageFile);

      final imageUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('imageReviews').add({
        'imageUrl': imageUrl,

        // uploader details
        'uploadedBy': user?.email ?? 'Unknown user',
        'uploadedByName': user?.displayName ?? 'Unknown Nurse',
        'uploadedByUid': user?.uid,

        'prediction': _prettyLabel(prediction),
        'confidence': (confidence * 100).round(),
        'status': 'Pending Review',
        'notes': prediction == 'invalid_image'
            ? 'Image was marked as unrecognized by the model.'
            : 'Submitted from mobile image analysis.',
        'uploadedOn': FieldValue.serverTimestamp(),
        'adminLabel': '',
      });

      debugPrint("Image review saved successfully");
    } catch (e) {
      debugPrint("Failed to save image review: $e");
    }
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
        if (bestScore < _invalidThreshold) {
          _predLabel = "invalid_image";
        } else {
          _predLabel = bestIdx < _labels.length ? _labels[bestIdx] : "unknown";
        }
        _predConfidence = bestScore;
        _running = false;
      });

      debugPrint("Prediction: $_predLabel");
      debugPrint("Confidence: $_predConfidence");
      debugPrint("Scores: $scores");

      if (_imageFile != null &&
          _predLabel != null &&
          _predConfidence != null &&
          _predLabel != "invalid_image") {
        await _saveImageReview(
          imageFile: _imageFile!,
          prediction: _predLabel!,
          confidence: _predConfidence!,
        );
      }

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
        return Container(
          height: 260,
          width: double.infinity,
          decoration: BoxDecoration(
            color: surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderLight),
          ),
          child: const Center(
            child: Icon(
              Icons.image_outlined,
              size: 90,
              color: iconLight,
            ),
          ),
        );
      }

      if (kIsWeb && _webImage != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.memory(
            _webImage!,
            height: 260,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      }

      if (!kIsWeb && _imageFile != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.file(
            _imageFile!,
            height: 260,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      }

      return const SizedBox.shrink();
    }();

    final confidencePercent =
    _predConfidence != null ? min(1.0, _predConfidence!) * 100 : 0.0;

    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        colors: [Color(0xFFC514C2), Color(0xFFA822D9)],
                      ).createShader(bounds);
                    },
                    child: Text(
                      "mentora.",
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Analysis Result",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "AI-assisted image assessment",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: subTextLight,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: showImageWidget,
                  ),
                  const SizedBox(height: 24),
                  if (_loadingModel)
                    const Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 8),
                      child: CircularProgressIndicator(),
                    ),
                  if (kIsWeb)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surfaceLight,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: borderLight),
                      ),
                      child: Text(
                        "Prediction runs on mobile only (TFLite not supported on web).",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: subTextLight,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  if (_running) ...[
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: surfaceLight,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: borderLight),
                      ),
                      child: Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 14),
                          Text(
                            "Analyzing image...",
                            style: GoogleFonts.poppins(
                              color: subTextLight,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_predLabel != null && _predConfidence != null) ...[
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4E8FA),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _predLabel == "invalid_image"
                                  ? "Image Check"
                                  : "Detected Condition",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFA822D9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _predLabel == "invalid_image"
                                ? "Unrecognized image"
                                : _prettyLabel(_predLabel!),
                            style: GoogleFonts.poppins(
                              color: textDark,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _predLabel == "invalid_image"
                                    ? "Model confidence"
                                    : "Confidence",
                                style: GoogleFonts.poppins(
                                  color: subTextLight,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                "${confidencePercent.toStringAsFixed(1)}%",
                                style: GoogleFonts.poppins(
                                  color: textDark,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: confidencePercent / 100,
                              minHeight: 10,
                              backgroundColor: const Color(0xFFEDE7F6),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFA822D9),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _predLabel == "invalid_image"
                                ? "Please upload a clear stoma image for analysis."
                                : "This result is generated by the AI model and should be used as a learning aid.",
                            style: GoogleFonts.poppins(
                              color: subTextLight,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 22),
                  GestureDetector(
                    onTap: () => _pickImage(ImageSource.gallery),
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: buttonGradient,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Center(
                        child: Text(
                          "Try Another Image",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}