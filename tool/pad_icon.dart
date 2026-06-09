// ignore_for_file: avoid_print
// Script to add padding to the app logo for Android adaptive icon foreground
// Run: dart run tool/pad_icon.dart

import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final inputPath = 'assets/logo/app_logo.png';
  final outputPath = 'assets/logo/app_logo_foreground.png';

  print('Reading $inputPath...');
  final inputFile = File(inputPath);
  final inputBytes = inputFile.readAsBytesSync();
  final original = img.decodePng(inputBytes);

  if (original == null) {
    print('ERROR: Could not decode image.');
    exit(1);
  }

  print('Original size: ${original.width}x${original.height}');

  // Android adaptive icon safe zone is the inner 66% of the canvas.
  // We want the logo to fit within ~52% of the canvas so it has breathing room.
  // Canvas size = 1024x1024 (standard), logo scaled to ~532px centered.
  final canvasSize = 1024;
  final logoSize = (canvasSize * 0.52).toInt(); // ~532px

  // Resize the original logo to the target size
  final resized = img.copyResize(original, width: logoSize, height: logoSize, interpolation: img.Interpolation.cubic);

  // Create a transparent canvas
  final canvas = img.Image(width: canvasSize, height: canvasSize, numChannels: 4);
  // Fill with transparent
  img.fill(canvas, color: img.ColorRgba8(0, 0, 0, 0));

  // Calculate offset to center the logo
  final offsetX = (canvasSize - logoSize) ~/ 2;
  final offsetY = (canvasSize - logoSize) ~/ 2;

  // Paste the resized logo onto the center of the canvas
  img.compositeImage(canvas, resized, dstX: offsetX, dstY: offsetY);

  // Save the padded foreground
  final outputFile = File(outputPath);
  outputFile.writeAsBytesSync(img.encodePng(canvas));
  print('Saved padded foreground to $outputPath (${canvasSize}x$canvasSize)');
  print('Done! Now update pubspec.yaml adaptive_icon_foreground to point to this file.');
}
