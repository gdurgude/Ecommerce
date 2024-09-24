// ignore_for_file: unused_import, unnecessary_import, avoid_print

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:cross_file/cross_file.dart';
import 'package:flutter/services.dart';

class ImageClassifier {
  Interpreter? _interpreter;
  List<String>? _labels;
  late int inputSize;

  Future<void> loadModel() async {
    try {
      final interpreterOptions = InterpreterOptions()..threads = 4;
      _interpreter = await Interpreter.fromAsset('assets/ml_models/mobilenet_v1_1.0_224.tflite', options: interpreterOptions);
      
      final labelsData = await rootBundle.loadString('assets/ml_models/labels.txt');
      _labels = labelsData.split('\n');
      
      if (_labels!.isEmpty) {
        throw Exception('No labels loaded from labels.txt');
      }

      final inputShape = _interpreter!.getInputTensor(0).shape;
      inputSize = inputShape[1]; // Assuming square input
      
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      final numClasses = outputShape[outputShape.length - 1];
      
      if (numClasses != _labels!.length) {
        print('Warning: Number of model outputs ($numClasses) does not match number of labels (${_labels!.length})');
      }
      
      if (kDebugMode) {
        print('Model and labels loaded successfully');
        print('Number of labels: ${_labels!.length}');
        print('Input shape: $inputShape');
        print('Output shape: $outputShape');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load model or labels: $e');
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> classifyImage(XFile image) async {
    try {
      if (_interpreter == null || _labels == null) {
        throw Exception('Model or labels not loaded');
      }

      final bytes = await image.readAsBytes();
      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) {
        throw Exception('Failed to decode image');
      }

      final resizedImage = img.copyResize(decodedImage, width: inputSize, height: inputSize);
      final input = imageToByteListFloat32(resizedImage, inputSize, 127.5, 127.5);

      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;

      final reshapedInput = input.reshape(inputShape);

      // Fix: Ensure output is a 2D list (if model produces multiple outputs)
      final output = List<List<double>>.filled(
        outputShape[0], List<double>.filled(outputShape[1], 0.0));

      // Run inference
      _interpreter!.run(reshapedInput, output);

      if (kDebugMode) {
        print('Model output size: ${output[0].length}');
      }

      // Process results
      final results = output[0]
          .asMap()
          .entries
          .map((entry) => {
                'label': _labels![entry.key],
                'confidence': entry.value,
              })
          .toList();

      results.sort((a, b) =>
          (b['confidence'] as double).compareTo(a['confidence'] as double));

      final classifications = results.take(5).toList();

      if (classifications.isEmpty) {
        throw Exception('No valid classifications found');
      }

      return classifications;
    } catch (e) {
      if (kDebugMode) {
        print('Error classifying image: $e');
      }
      rethrow;
    }
  }

  Float32List imageToByteListFloat32(
      img.Image image, int inputSize, double mean, double std) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (pixel.r.toDouble() - mean) / std;
        buffer[pixelIndex++] = (pixel.g.toDouble() - mean) / std;
        buffer[pixelIndex++] = (pixel.b.toDouble() - mean) / std;
      }
    }

    return convertedBytes;
  }
}