import 'dart:convert';
import 'package:crypto/crypto.dart';

/// A simple implementation of Key Derivation Function (KDF) for password-based key derivation.
class PasswordBasedKeyDerivation {
  /// Derives a key from a password using PBKDF2.
  /// 
  /// [password]: The password to derive the key from.
  /// [salt]: A random value that is unique to this password.
  /// [iterations]: The number of iterations to perform.
  /// [length]: The desired length of the derived key.
  /// 
  /// Returns the derived key as a list of bytes.
  static List<int> deriveKey(String password, List<int> salt, int iterations, int length) {
    final key = utf8.encode(password);
    var hmac = Hmac(sha256, key);
    var derivedKey = List<int>.empty(growable: true);

    var blockCount = (length / hmac.macSize).ceil();
    for (int block = 1; block <= blockCount; block++) {
      var blockBytes = List<int>.from(salt);
      blockBytes.addAll(utf8.encode(block.toString()));
      var u = hmac.convert(blockBytes).bytes;
      var t = u;

      for (int i = 1; i < iterations; i++) {
        u = hmac.convert(u).bytes;
        t = _xor(t, u);
      }

      derivedKey.addAll(t);
    }

    return derivedKey.take(length).toList();
  }

  /// Performs a bitwise XOR operation on two byte arrays.
  static List<int> _xor(List<int> a, List<int> b) {
    if (a.length != b.length) {
      throw ArgumentError('XOR operation requires arrays of equal length.');
    }
    return List.generate(a.length, (i) => a[i] ^ b[i]);
  }
}