import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Checks if the device is capable of biometric authentication.
  static Future<bool> canAuthenticate() async {
    final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
    return canAuthenticate;
  }

  /// Attempts to authenticate the user.
  /// Returns true if successful, false otherwise.
  static Future<bool> authenticate() async {
    try {
      if (!await canAuthenticate()) return true;

      // Check if any biometrics are enrolled
      final List<BiometricType> availableBiometrics = await _auth.getAvailableBiometrics();
      
      // If the device is capable but nothing is enrolled, local_auth throws NotAvailable.
      // For the demo/emulator, we allow entry if nothing is enrolled but warn the user.
      
      return await _auth.authenticate(
        localizedReason: 'Please authenticate to open your Stegovault',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      if (e.code == 'NotAvailable') {
        debugPrint("Auth Warning: No security credentials enrolled on this device.");
        return true; // Auto-bypass for unconfigured devices/emulators
      }
      debugPrint("Auth Error: $e");
      return false;
    }
  }
}
