// ignore_for_file: library_private_types_in_public_api, avoid_print, use_build_context_synchronously, unused_shown_name

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File, Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'image_classification_mobile.dart' if (dart.library.html) 'image_classification_web.dart' as platform;

class ImageClassificationPage extends StatefulWidget {
  const ImageClassificationPage({super.key});

  @override
  _ImageClassificationPageState createState() => _ImageClassificationPageState();
}

class _ImageClassificationPageState extends State<ImageClassificationPage> {
  XFile? _image;
  List<Map<String, dynamic>>? _recognitions;
  bool _isLoading = false;
  final platform.ImageClassifier _classifier = platform.ImageClassifier();

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      await _classifier.loadModel();
    } catch (e) {
      print('Failed to load model: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load model: $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    setState(() {
      _isLoading = true;
    });

    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
        _recognitions = null;
      });
      await _classifyImage();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _classifyImage() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await _classifier.classifyImage(_image!);
      setState(() {
        _recognitions = results;
      });
    } catch (e) {
      print('Error during classification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error classifying image: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Classification')),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image != null) ...[
              kIsWeb
                  ? Image.network(_image!.path, height: 200)
                  : Image.file(File(_image!.path), height: 200),
              const SizedBox(height: 20),
            ],
            ElevatedButton(
              onPressed: _isLoading ? null : _pickImage,
              child: Text(_isLoading ? 'Processing...' : 'Select an Image'),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            if (_recognitions != null) ...[
              const SizedBox(height: 20),
              for (var recognition in _recognitions!)
                ListTile(
                  title: Text(recognition['label']),
                  trailing: Text('${(recognition['confidence'] * 100).toStringAsFixed(2)}%'),
                ),
            ],
          ],
        ),
      ),
    );
  }
}