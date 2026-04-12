import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../core/lsb_core.dart';
import 'crypto_service.dart';

/// Data class for background processing
class EncodeParams {
  final String message;
  final String imagePath;
  final String? passphrase;
  EncodeParams(this.message, this.imagePath, this.passphrase);
}

class DecodeParams {
  final String imagePath;
  final String? passphrase;
  DecodeParams(this.imagePath, this.passphrase);
}

class HeatmapParams {
  final int width;
  final int height;
  final int messageLength;
  final String? passphrase;
  HeatmapParams(this.width, this.height, this.messageLength, this.passphrase);
}

class StegoService {
  // Image loading with downscaling.
  static img.Image? _loadAndOptimizeImage(Uint8List bytes) {
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return null;

    // Downscale if too large to prevent OOM
    if (image.width > 2000 || image.height > 2000) {
      double ratio = image.width > image.height ? 2000 / image.width : 2000 / image.height;
      image = img.copyResize(image, width: (image.width * ratio).toInt(), height: (image.height * ratio).toInt());
    }
    
    // Explicitly convert to 8-bit RGB (no alpha) to ensure LSB stability
    if (image.format != img.Format.uint8 || image.numChannels != 3) {
      image = image.convert(format: img.Format.uint8, numChannels: 3);
    }
    return image;
  }

  // Background Encoding
  Future<String?> encode(String message, String imagePath, {String? passphrase}) async {
    try {
      return await compute(_encodeTask, EncodeParams(message, imagePath, passphrase));
    } catch (e) {
      debugPrint("StegoService Encode Error: $e");
      return null;
    }
  }

  static Future<String?> _encodeTask(EncodeParams params) async {
    final bytes = await File(params.imagePath).readAsBytes();
    final originalImage = _loadAndOptimizeImage(bytes);
    if (originalImage == null) return null;

    String payload = params.message;
    int? seed;

    if (params.passphrase != null && params.passphrase!.isNotEmpty) {
      payload = CryptoService.encrypt(params.message, params.passphrase!);
      final seedBytes = sha256.convert(utf8.encode(params.passphrase!)).bytes;
      seed = seedBytes[0] | (seedBytes[1] << 8) | (seedBytes[2] << 16) | (seedBytes[3] << 24);
    }

    final stegoImage = LsbCore.encodeText(originalImage, payload, seed: seed);
    
    // level 0 = no compression (fastest, safest for stego)
    final stegoBytes = img.encodePng(stegoImage, level: 0);

    final directory = Directory('/sdcard/Download');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    
    final fileName = 'stego_${DateTime.now().millisecondsSinceEpoch}.png';
    final stegoFile = File('${directory.path}/$fileName');
    await stegoFile.writeAsBytes(stegoBytes, flush: true);
    return stegoFile.path;
  }

  // Background Decoding
  Future<String?> decode(String imagePath, {String? passphrase}) async {
    try {
      return await compute(_decodeTask, DecodeParams(imagePath, passphrase));
    } catch (e) {
      debugPrint("StegoService Decode Error: $e");
      return null;
    }
  }

  static Future<String?> _decodeTask(DecodeParams params) async {
    final bytes = await File(params.imagePath).readAsBytes();
    final stegoImage = img.decodeImage(bytes);
    if (stegoImage == null) return "Error: Failed to decode image file.";

    int? seed;
    if (params.passphrase != null && params.passphrase!.isNotEmpty) {
      final seedBytes = sha256.convert(utf8.encode(params.passphrase!)).bytes;
      seed = seedBytes[0] | (seedBytes[1] << 8) | (seedBytes[2] << 16) | (seedBytes[3] << 24);
    }

    final extractedPayload = LsbCore.decodeText(stegoImage, seed: seed);

    if (params.passphrase != null && params.passphrase!.isNotEmpty && !extractedPayload.startsWith("No secret message")) {
      try {
        return CryptoService.decrypt(extractedPayload, params.passphrase!);
      } catch (e) {
        return "Authentication Failed: Incorrect passphrase.";
      }
    }
    return extractedPayload;
  }

  // Heatmap generation
  Future<Uint8List?> generateHeatmap(int width, int height, int messageLength, {String? passphrase}) async {
    try {
      return await compute(_heatmapTask, HeatmapParams(width, height, messageLength, passphrase));
    } catch (e) {
      return null;
    }
  }

  static Future<Uint8List?> _heatmapTask(HeatmapParams params) async {
    int? seed;
    if (params.passphrase != null && params.passphrase!.isNotEmpty) {
      final seedBytes = sha256.convert(utf8.encode(params.passphrase!)).bytes;
      seed = seedBytes[0] | (seedBytes[1] << 8) | (seedBytes[2] << 16) | (seedBytes[3] << 24);
    }
    
    final heatmap = LsbCore.generateHeatmap(params.width, params.height, params.messageLength, seed: seed);
    return Uint8List.fromList(img.encodePng(heatmap));
  }
}
