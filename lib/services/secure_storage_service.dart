import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _keyMasterPassword = 'master_password';

  /// Saves the master password in the hardware-backed Keystore/Keychain.
  static Future<void> saveMasterPassword(String password) async {
    await _storage.write(key: _keyMasterPassword, value: password);
  }

  /// Retrieves the master password from secure storage.
  static Future<String?> getMasterPassword() async {
    return await _storage.read(key: _keyMasterPassword);
  }

  /// Deletes the master password (for resetting the vault).
  static Future<void> clearVault() async {
    await _storage.delete(key: _keyMasterPassword);
  }
}
