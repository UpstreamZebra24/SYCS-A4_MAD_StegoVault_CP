import 'package:image/image.dart' as img;
import 'dart:convert';

class LsbCore {
  // A strict delimiter so the decoder knows exactly when to stop extracting
  static const String _delimiter = "##STEGO_END##";

  /// Spiral 1: Encodes a plaintext string sequentially into the LSB of an image.
  static img.Image encodeText(img.Image image, String text) {
    String message = text + _delimiter;
    List<int> bytes = utf8.encode(message);
    
    // Convert bytes into a flat list of bits (0s and 1s)
    List<int> bits = [];
    for (int byte in bytes) {
      for (int i = 7; i >= 0; i--) {
        bits.add((byte >> i) & 1);
      }
    }

    int bitIndex = 0;
    int totalBits = bits.length;

    // Clone the image to prevent mutating the original UI image
    img.Image stegoImage = image.clone();

    // Iterate through every pixel sequentially (Spiral 1 logic)
    for (var pixel in stegoImage) {
      if (bitIndex >= totalBits) break; // Stop if all bits are hidden

      // Clear the LSB (AND with 254 / 0xFE) and insert the message bit (OR)
      if (bitIndex < totalBits) {
        pixel.r = (pixel.r & 0xFE) | bits[bitIndex++];
      }
      if (bitIndex < totalBits) {
        pixel.g = (pixel.g & 0xFE) | bits[bitIndex++];
      }
      if (bitIndex < totalBits) {
        pixel.b = (pixel.b & 0xFE) | bits[bitIndex++];
      }
    }

    return stegoImage;
  }

  /// Spiral 1: Decodes plaintext from a stego-image until it hits the delimiter.
  static String decodeText(img.Image stegoImage) {
    List<int> extractedBits = [];
    List<int> extractedBytes = [];

    for (var pixel in stegoImage) {
      // Extract the lowest bit from RGB channels
      extractedBits.add(pixel.r.toInt() & 1);
      extractedBits.add(pixel.g.toInt() & 1);
      extractedBits.add(pixel.b.toInt() & 1);

      // Once we have 8 bits, reconstruct the byte
      while (extractedBits.length >= 8) {
        int byteValue = 0;
        for (int i = 0; i < 8; i++) {
          byteValue = (byteValue << 1) | extractedBits.removeAt(0);
        }
        extractedBytes.add(byteValue);

        // Attempt to decode to string and check for the delimiter
        try {
          String currentString = utf8.decode(extractedBytes, allowMalformed: true);
          if (currentString.endsWith(_delimiter)) {
            // Delimiter found! Return the secret message without the delimiter.
            return currentString.substring(0, currentString.length - _delimiter.length);
          }
        } catch (e) {
          // Ignore partial UTF-8 decoding errors until a full character is formed
        }
      }
    }

    // Failsafe: Return whatever was found if the delimiter was missing or corrupted
    return utf8.decode(extractedBytes, allowMalformed: true).replaceAll(_delimiter, "");
  }
}
