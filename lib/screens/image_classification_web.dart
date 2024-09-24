// ignore_for_file: avoid_web_libraries_in_flutter, avoid_print

import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:cross_file/cross_file.dart';
import 'package:image/image.dart' as img;

@JS('classifyImage')
external dynamic _classifyImage(dynamic imgElement);

class ImageClassifier {
  // Add the missing loadModel method
  Future<void> loadModel() async {
    // For web, you might not need to load anything explicitly, so this can be a no-op
    print('No model loading required for the web version.');
  }

  Future<List<Map<String, dynamic>>> classifyImage(XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) {
        throw Exception('Failed to decode image');
      }

      final resizedImage = img.copyResize(decodedImage, width: 224, height: 224);
      final resizedBytes = img.encodeJpg(resizedImage);

      final blob = html.Blob([Uint8List.fromList(resizedBytes)]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      final imgElement = html.ImageElement();
      imgElement.src = url;

      // Wait for the image to load
      await imgElement.onLoad.first;

      final result = await promiseToFuture(_classifyImage(imgElement));

      html.Url.revokeObjectUrl(url);

      if (kDebugMode) {
        print('Raw classification result: $result');
      }

      if (result == null || result is! List) {
        throw Exception('Unexpected classification result format');
      }

      final List<Map<String, dynamic>> classifications = result.map((item) {
        if (item == null) {
          if (kDebugMode) {
            print('Null item in classification result');
          }
          return null;
        }

        final className = getProperty(item, 'className');
        final probability = getProperty(item, 'probability');

        if (className == null || probability == null) {
          if (kDebugMode) {
            print('Missing className or probability in item: $item');
          }
          return null;
        }

        return {
          'label': className as String,
          'confidence': (probability as num).toDouble(),
        };
      }).whereType<Map<String, dynamic>>().toList();

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
}
