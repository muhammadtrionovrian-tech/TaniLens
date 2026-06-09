import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

enum ModelType { mobileNetV2, resNet50 }

class TfliteService {
  static final TfliteService _instance = TfliteService._internal();
  factory TfliteService() => _instance;
  TfliteService._internal();

  // ==========================================
  // === DUAL BUILD CONFIGURATION SWITCHER ===
  // ==========================================
  // To build MobileNetV2 APK: set this to ModelType.mobileNetV2
  // To build ResNet50 APK: set this to ModelType.resNet50
  static const ModelType activeModel = ModelType.mobileNetV2;

  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  // The 9 specific classes the models were trained on (alphabetically sorted)
  final List<String> _labels = [
    'Early Blight Leaf',
    'Healthy Fruit',
    'Healthy Leaf',
    'Healthy Stem',
    'Late Blight Leaf',
    'Mold Leaf',
    'Septoria Leaf Spot',
    'Symptomatic Stem',
    'Target Spot Fruit',
  ];

  List<String> get labels => _labels;

  // Get current active model configuration details
  String get activeModelName => activeModel == ModelType.mobileNetV2 ? 'MobileNetV2' : 'ResNet50';
  String get activeModelFile => activeModel == ModelType.mobileNetV2 ? 'Best_Trio_MobileNetV2_adam.tflite' : 'Best_Trio_v3_ResNet50_adam.tflite';

  // Initialize and load the TFLite model from assets
  Future<void> loadModel() async {
    if (_isModelLoaded) return;
    try {
      // Configure options for optimal thread usage
      final options = InterpreterOptions()..threads = 4;
      final modelAssetPath = 'assets/tflite/$activeModelFile';
      _interpreter = await Interpreter.fromAsset(
        modelAssetPath,
        options: options,
      );
      _isModelLoaded = true;
      debugPrint("TFLite Model ($activeModelName) loaded successfully from $modelAssetPath.");
    } catch (e) {
      debugPrint("Failed to load TFLite Model ($activeModelName): $e");
    }
  }

  // Preprocess the input image and run inference using MobileNetV2
  Future<Map<String, dynamic>> classifyImage(File imageFile) async {
    await loadModel();
    if (_interpreter == null) {
      throw Exception("TFLite interpreter is not initialized. Please check asset model path.");
    }

    // 1. Decode image bytes
    final Uint8List imageBytes = await imageFile.readAsBytes();
    final img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) {
      throw Exception("Failed to decode image bytes.");
    }

    // 2. Center crop the image to 1:1 square ratio to avoid distortion (squishing) and resize to 224x224
    final int origWidth = originalImage.width;
    final int origHeight = originalImage.height;
    final int size = origWidth < origHeight ? origWidth : origHeight;
    final int cropX = (origWidth - size) ~/ 2;
    final int cropY = (origHeight - size) ~/ 2;

    final img.Image croppedImage = img.copyCrop(
      originalImage,
      x: cropX,
      y: cropY,
      width: size,
      height: size,
    );

    final img.Image resizedImage = img.copyResize(croppedImage, width: 224, height: 224);

    // 3. Prepare Float32 input tensor: shape [1, 224, 224, 3]
    // Normalized to [0.0, 1.0] as expected by standard MobileNetV2
    var input = List.generate(
      1,
      (_) => List.generate(
        224,
        (_) => List.generate(
          224,
          (_) => List.filled(3, 0.0),
        ),
      ),
    );

    // Apply model-specific channel ordering and preprocessing formula
    if (activeModel == ModelType.mobileNetV2) {
      // MobileNetV2: RGB order with [-1.0, 1.0] scaling
      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resizedImage.getPixel(x, y);
          
          // Extract RGB values and normalize ekuivalen dengan tf.keras.applications.mobilenet_v2.preprocess_input
          final double r = (pixel.r.toDouble() - 127.5) / 127.5;
          final double g = (pixel.g.toDouble() - 127.5) / 127.5;
          final double b = (pixel.b.toDouble() - 127.5) / 127.5;

          input[0][y][x][0] = r;
          input[0][y][x][1] = g;
          input[0][y][x][2] = b;
        }
      }
    } else {
      // ResNet50: BGR order with ImageNet mean subtraction (no division)
      // Blue mean: 103.939, Green mean: 116.779, Red mean: 123.680
      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resizedImage.getPixel(x, y);
          
          final double b = pixel.b.toDouble() - 103.939; // Blue first
          final double g = pixel.g.toDouble() - 116.779; // Green second
          final double r = pixel.r.toDouble() - 123.680; // Red third

          input[0][y][x][0] = b;
          input[0][y][x][1] = g;
          input[0][y][x][2] = r;
        }
      }
    }

    // 4. Prepare Float32 output tensor: shape [1, 9] for the 9 classes
    var output = List.generate(1, (_) => List.filled(9, 0.0));

    // 5. Run inference
    final stopwatch = Stopwatch()..start();
    _interpreter!.run(input, output);
    stopwatch.stop();
    final int inferenceTimeMs = stopwatch.elapsedMilliseconds;

    // 6. Post-process: Extract logits / class probabilities
    final List<double> probabilities = List<double>.from(output[0]);
    
    // Find class with the maximum probability score
    double maxProb = -1.0;
    int maxIndex = -1;
    for (int i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > maxProb) {
        maxProb = probabilities[i];
        maxIndex = i;
      }
    }

    final String detectedDisease = _labels[maxIndex];
    final double confidence = maxProb * 100.0;

    return {
      'diseaseName': detectedDisease,
      'confidence': double.parse(confidence.toStringAsFixed(1)),
      'probabilities': probabilities,
      'inferenceTime': inferenceTimeMs,
      'modelName': activeModelName,
    };
  }

  // Preprocess the input asset image and run inference using MobileNetV2
  Future<Map<String, dynamic>> classifyAsset(String assetPath) async {
    await loadModel();
    if (_interpreter == null) {
      throw Exception("TFLite interpreter is not initialized. Please check asset model path.");
    }

    // 1. Load image bytes from assets using rootBundle
    final ByteData assetData = await rootBundle.load(assetPath);
    final Uint8List imageBytes = assetData.buffer.asUint8List();

    final img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) {
      throw Exception("Failed to decode asset image bytes.");
    }

    // 2. Center crop the image to 1:1 square ratio to avoid distortion (squishing) and resize to 224x224
    final int origWidth = originalImage.width;
    final int origHeight = originalImage.height;
    final int size = origWidth < origHeight ? origWidth : origHeight;
    final int cropX = (origWidth - size) ~/ 2;
    final int cropY = (origHeight - size) ~/ 2;

    final img.Image croppedImage = img.copyCrop(
      originalImage,
      x: cropX,
      y: cropY,
      width: size,
      height: size,
    );

    final img.Image resizedImage = img.copyResize(croppedImage, width: 224, height: 224);

    // 3. Prepare Float32 input tensor: shape [1, 224, 224, 3]
    var input = List.generate(
      1,
      (_) => List.generate(
        224,
        (_) => List.generate(
          224,
          (_) => List.filled(3, 0.0),
        ),
      ),
    );

    // Apply model-specific channel ordering and preprocessing formula
    if (activeModel == ModelType.mobileNetV2) {
      // MobileNetV2: RGB order with [-1.0, 1.0] scaling
      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resizedImage.getPixel(x, y);
          
          final double r = (pixel.r.toDouble() - 127.5) / 127.5;
          final double g = (pixel.g.toDouble() - 127.5) / 127.5;
          final double b = (pixel.b.toDouble() - 127.5) / 127.5;

          input[0][y][x][0] = r;
          input[0][y][x][1] = g;
          input[0][y][x][2] = b;
        }
      }
    } else {
      // ResNet50: BGR order with ImageNet mean subtraction (no division)
      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resizedImage.getPixel(x, y);
          
          final double b = pixel.b.toDouble() - 103.939; // Blue first
          final double g = pixel.g.toDouble() - 116.779; // Green second
          final double r = pixel.r.toDouble() - 123.680; // Red third

          input[0][y][x][0] = b;
          input[0][y][x][1] = g;
          input[0][y][x][2] = r;
        }
      }
    }

    // 4. Prepare Float32 output tensor: shape [1, 9] for the 9 classes
    var output = List.generate(1, (_) => List.filled(9, 0.0));

    // 5. Run inference
    final stopwatch = Stopwatch()..start();
    _interpreter!.run(input, output);
    stopwatch.stop();
    final int inferenceTimeMs = stopwatch.elapsedMilliseconds;

    // 6. Post-process: Extract logits / class probabilities
    final List<double> probabilities = List<double>.from(output[0]);
    
    double maxProb = -1.0;
    int maxIndex = -1;
    for (int i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > maxProb) {
        maxProb = probabilities[i];
        maxIndex = i;
      }
    }

    final String detectedDisease = _labels[maxIndex];
    final double confidence = maxProb * 100.0;

    return {
      'diseaseName': detectedDisease,
      'confidence': double.parse(confidence.toStringAsFixed(1)),
      'probabilities': probabilities,
      'inferenceTime': inferenceTimeMs,
      'modelName': activeModelName,
    };
  }

  // Dispose resources when done
  void close() {
    _interpreter?.close();
    _isModelLoaded = false;
  }
}
