import 'package:image/image.dart' as img;
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';

class LsbCore {
  static const String _delimiter = "##STEGO_END##";
  static final List<int> _delimiterBytes = utf8.encode(_delimiter);

  /// Spiral 2: Encodes text by scattering bits across the image.
  static img.Image encodeText(img.Image image, String text, {int? seed}) {
    // 1. Force image to uint8 RGB format to ensure LSB stability.
    img.Image stegoImage = image.convert(format: img.Format.uint8, numChannels: 3);
    
    // 2. Prepare bit stream (Message + Delimiter)
    List<int> bits = [];
    final List<int> payloadBytes = utf8.encode(text + _delimiter);
    for (int byte in payloadBytes) {
      for (int i = 7; i >= 0; i--) {
        bits.add((byte >> i) & 1);
      }
    }

    final int totalPixels = stegoImage.width * stegoImage.height;
    final int effectiveSeed = (seed ?? 0x1337BEEF).abs();
    
    // 3. Deterministic LCG parameters for bit scattering
    // Using a fixed Random with seed ensures same offset/multiplier every time
    final random = Random(effectiveSeed);
    final int offset = random.nextInt(totalPixels > 0 ? totalPixels : 1);
    
    int multiplier = (totalPixels * 0.61803398875).toInt();
    if (multiplier < 1) multiplier = 1;
    while (_gcd(multiplier, totalPixels) != 1) {
      multiplier++;
      if (multiplier >= totalPixels) multiplier = 1;
    }

    // 4. Scatter bits
    int bitIndex = 0;
    for (int i = 0; i < totalPixels; i++) {
      if (bitIndex >= bits.length) break;
      
      int scatteredIdx = (multiplier * i + offset) % totalPixels;
      int x = scatteredIdx % stegoImage.width;
      int y = scatteredIdx ~/ stegoImage.width;
      
      var pixel = stegoImage.getPixel(x, y);

      int r = pixel.r.toInt();
      int g = pixel.g.toInt();
      int b = pixel.b.toInt();

      pixel.r = (r & 0xFE) | (bitIndex < bits.length ? bits[bitIndex++] : 0);
      pixel.g = (g & 0xFE) | (bitIndex < bits.length ? bits[bitIndex++] : 0);
      pixel.b = (b & 0xFE) | (bitIndex < bits.length ? bits[bitIndex++] : 0);
    }
    
    return stegoImage;
  }

  /// Spiral 2: Decodes text by following the same scattered path.
  static String decodeText(img.Image stegoImage, {int? seed}) {
    img.Image image = stegoImage.convert(format: img.Format.uint8, numChannels: 3);
    final int totalPixels = image.width * image.height;
    final int effectiveSeed = (seed ?? 0x1337BEEF).abs();

    final random = Random(effectiveSeed);
    final int offset = random.nextInt(totalPixels > 0 ? totalPixels : 1);
    
    int multiplier = (totalPixels * 0.61803398875).toInt();
    if (multiplier < 1) multiplier = 1;
    while (_gcd(multiplier, totalPixels) != 1) {
      multiplier++;
      if (multiplier >= totalPixels) multiplier = 1;
    }

    List<int> extractedBits = [];
    List<int> extractedBytes = [];

    for (int i = 0; i < totalPixels; i++) {
      int scatteredIdx = (multiplier * i + offset) % totalPixels;
      int x = scatteredIdx % image.width;
      int y = scatteredIdx ~/ image.width;
      
      var pixel = image.getPixel(x, y);

      extractedBits.add(pixel.r.toInt() & 1);
      extractedBits.add(pixel.g.toInt() & 1);
      extractedBits.add(pixel.b.toInt() & 1);

      while (extractedBits.length >= 8) {
        int byteValue = 0;
        for (int j = 0; j < 8; j++) {
          byteValue = (byteValue << 1) | extractedBits.removeAt(0);
        }
        extractedBytes.add(byteValue);

        if (extractedBytes.length >= _delimiterBytes.length) {
          bool matched = true;
          for (int k = 0; k < _delimiterBytes.length; k++) {
            if (extractedBytes[extractedBytes.length - _delimiterBytes.length + k] != _delimiterBytes[k]) {
              matched = false;
              break;
            }
          }
          
          if (matched) {
            final resultBytes = extractedBytes.sublist(0, extractedBytes.length - _delimiterBytes.length);
            try {
              return utf8.decode(resultBytes);
            } catch (e) {
              // Ignore false matches
            }
          }
        }
      }
      if (extractedBytes.length > 1024 * 1024) break; 
    }
    
    return "No secret message found. (Check your passphrase or image selection)";
  }

  /// Generates a visual representation of where bits are scattered.
  static img.Image generateHeatmap(int width, int height, int messageLength, {int? seed}) {
    img.Image heatmap = img.Image(width: width, height: height);
    for (var pixel in heatmap) {
      pixel.r = 0; pixel.g = 0; pixel.b = 0;
    }

    final int totalPixels = width * height;
    final int effectiveSeed = (seed ?? 0x1337BEEF).abs();
    int totalBitsNeeded = (messageLength + _delimiter.length) * 8;

    final random = Random(effectiveSeed);
    final int offset = random.nextInt(totalPixels > 0 ? totalPixels : 1);
    
    int multiplier = (totalPixels * 0.61803398875).toInt();
    if (multiplier < 1) multiplier = 1;
    while (_gcd(multiplier, totalPixels) != 1) {
      multiplier++;
      if (multiplier >= totalPixels) multiplier = 1;
    }

    int bitCount = 0;
    for (int i = 0; i < totalPixels; i++) {
      if (bitCount >= totalBitsNeeded) break;

      int scatteredIdx = (multiplier * i + offset) % totalPixels;
      int x = scatteredIdx % width;
      int y = scatteredIdx ~/ width;
      
      var pixel = heatmap.getPixel(x, y);
      pixel.r = 255; pixel.g = 255; pixel.b = 255;
      
      bitCount += 3; 
    }
    return heatmap;
  }

  static int _gcd(int a, int b) {
    while (b != 0) {
      int t = b;
      b = a % b;
      a = t;
    }
    return a;
  }
}
