import 'package:flutter_test/flutter_test.dart';
import 'package:your_package_name/your_steganography_class.dart';
import 'dart:io';

void main() {
  group('LSB Steganography Tests', () {
    test('Test image embedding capacity', () {
      final image = File('test/image.png'); // Assuming this is your test image
      final capacity = calculateCapacity(image);
      expect(capacity, greaterThan(0), reason: 'Image should have a valid capacity');
    });

    test('Test LSB embedding', () {
      final inputImage = File('test/image.png'); // Input image
      final secretMessage = 'Secret'; // Example secret message
      final outputImage = embedMessage(inputImage, secretMessage);

      // Validate if the message is correctly embedded
      final extractedMessage = extractMessage(outputImage);
      expect(extractedMessage, secretMessage, reason: 'Extracted message should match the original');
    });
  });
}