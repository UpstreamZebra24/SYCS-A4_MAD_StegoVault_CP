import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:aes_gcm/aes_gcm.dart';

class EncryptionService {
  final FlutterSecureStorage _storage;

  EncryptionService(this._storage);

  Future<String> encrypt(String plaintext) async {
    // Generate a random 256-bit key
    final key = AesGcm.generateKey();
    final iv = AesGcm.generateNonce(); // Generate a random nonce
    final cipher = AesGcm.with256bits();

    // Encrypt the plaintext message
    final ciphertext = await cipher.encrypt(plaintext.codeUnits, key, nonce: iv);
    // Store the key securely
    await _storage.write(key: 'encryption_key', value: base64.encode(key));

    // Return the ciphertext along with the IV
    return base64.encode(iv) + ':' + base64.encode(ciphertext);
  }

  Future<String?> decrypt(String encrypted) async {
    // Retrieve the key
    final keyBase64 = await _storage.read(key: 'encryption_key');
    if (keyBase64 == null) {
      throw Exception('Encryption key not found');
    }
    final key = base64.decode(keyBase64);

    // Split the IV and ciphertext
    final parts = encrypted.split(':');
    if (parts.length != 2) {
      throw Exception('Invalid encrypted data');
    }
    final iv = base64.decode(parts[0]);
    final ciphertext = base64.decode(parts[1]);
    final cipher = AesGcm.with256bits();

    // Decrypt the message
    final plaintextBytes = await cipher.decrypt(ciphertext, key, nonce: iv);
    return String.fromCharCodes(plaintextBytes);
  }
}