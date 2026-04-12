// File: stego_result.dart

/// This class represents the result of the steganography operations.
class StegoResult {
    final String message; // Encoded message
    final bool success; // Success flag
    final String? error; // Error message if any

    StegoResult({required this.message, required this.success, this.error});

    @override
    String toString() {
        return 'StegoResult(message: \$message, success: \$success, error: \$error)';
    }
}