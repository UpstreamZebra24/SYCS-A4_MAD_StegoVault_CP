import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:cp/core/lsb_core.dart';
import 'package:cp/services/crypto_service.dart';

void main() {
  group('LSB Core Simulation Tests', () {
    test('Should encode and decode a simple message without passphrase', () {
      // 1. Create a dummy image (100x100)
      final image = img.Image(width: 100, height: 100);
      for (var pixel in image) {
        pixel.r = 100; pixel.g = 150; pixel.b = 200;
      }

      final secret = "Hello World!";
      
      // 2. Encode
      final stegoImage = LsbCore.encodeText(image, secret);
      
      // 3. Decode
      final extracted = LsbCore.decodeText(stegoImage);
      
      expect(extracted, secret);
    });

    test('Should encode and decode with a seed (simulated passphrase)', () {
      final image = img.Image(width: 50, height: 50);
      final secret = "Secret Protocol 42";
      final seed = 123456789;

      final stegoImage = LsbCore.encodeText(image, secret, seed: seed);
      
      // Correct seed
      final extractedSuccess = LsbCore.decodeText(stegoImage, seed: seed);
      expect(extractedSuccess, secret);

      // Wrong seed should fail to find message
      final extractedFailure = LsbCore.decodeText(stegoImage, seed: 99999);
      expect(extractedFailure.startsWith("No secret message"), isTrue);
    });

    test('Should work with encrypted payloads (CryptoService integration)', () {
      final image = img.Image(width: 150, height: 150);
      final plaintext = "This is a top secret encrypted message.";
      final pass = "my_strong_password";

      // 1. Encrypt
      final encrypted = CryptoService.encrypt(plaintext, pass);
      
      // 2. Generate seed from pass (to simulate StegoService logic)
      final seedBytes = utf8.encode(pass);
      int seed = 0;
      for (int i = 0; i < seedBytes.length && i < 4; i++) {
        seed |= (seedBytes[i] << (8 * i));
      }

      // 3. Embed
      final stegoImage = LsbCore.encodeText(image, encrypted, seed: seed);
      
      // 4. Extract
      final extractedEncrypted = LsbCore.decodeText(stegoImage, seed: seed);
      expect(extractedEncrypted, encrypted);

      // 5. Decrypt
      final decrypted = CryptoService.decrypt(extractedEncrypted, pass);
      expect(decrypted, plaintext);
    });

    test('Should survive PNG encoding/decoding cycle (Lossless check)', () {
      final image = img.Image(width: 80, height: 80);
      final secret = "Check if PNG compression breaks me!";
      
      final stegoImage = LsbCore.encodeText(image, secret);
      
      // Simulate saving to PNG and loading back
      final pngBytes = img.encodePng(stegoImage, level: 0);
      final reloadedImage = img.decodeImage(pngBytes);
      
      expect(reloadedImage, isNotNull);
      final extracted = LsbCore.decodeText(reloadedImage!);
      expect(extracted, secret);
    });
  });
}
