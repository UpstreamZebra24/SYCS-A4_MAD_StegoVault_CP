import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/export.dart' as pc;

class CryptoService {
  /// Derives a 32-byte key from a passphrase using PBKDF2.
  /// This is much more secure than a simple SHA-256 hash.
  static Key _deriveKey(String passphrase, {Uint8List? salt}) {
    // Standard salt for steganography context (constant for the app)
    final saltBytes = salt ?? Uint8List.fromList(utf8.encode('stego_salt_fixed_16b')); 
    
    final pkcs = pc.PBKDF2KeyDerivator(pc.HMac(pc.SHA256Digest(), 64))
      ..init(pc.Pbkdf2Parameters(saltBytes, 100000, 32));

    final keyBytes = pkcs.process(Uint8List.fromList(utf8.encode(passphrase)));
    return Key(keyBytes);
  }

  /// Encrypts text using AES-GCM. 
  /// Returns a base64 string containing: IV (12 bytes) + Ciphertext.
  static String encrypt(String plaintext, String passphrase) {
    final key = _deriveKey(passphrase);
    final iv = IV.fromSecureRandom(12); // GCM standard IV size
    final encrypter = Encrypter(AES(key, mode: AESMode.gcm, padding: null));

    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    
    final combined = Uint8List(iv.bytes.length + encrypted.bytes.length);
    combined.setRange(0, iv.bytes.length, iv.bytes);
    combined.setRange(iv.bytes.length, combined.length, encrypted.bytes);
    
    return base64.encode(combined);
  }

  /// Decrypts a combined base64 string using AES-GCM.
  static String? decrypt(String combinedBase64, String passphrase) {
    try {
      final combined = base64.decode(combinedBase64);
      final key = _deriveKey(passphrase);
      
      final iv = IV(combined.sublist(0, 12));
      final ciphertext = combined.sublist(12);
      
      final encrypter = Encrypter(AES(key, mode: AESMode.gcm, padding: null));
      return encrypter.decrypt(Encrypted(ciphertext), iv: iv);
    } catch (e) {
      return null; // Signals wrong passphrase or corrupted data
    }
  }
}
