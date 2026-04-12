import 'package:image/image.dart' as img;

class CapacityCalculator {
  /// Calculates how many characters can be safely hidden in the image.
  /// Each character takes 8 bits. We use 3 bits per pixel (LSB of R, G, B).
  static int calculateMaxCharacters(img.Image image, {int bitsPerPixel = 3}) {
    final int totalPixels = image.width * image.height;
    final int totalBits = totalPixels * bitsPerPixel;
    
    // Reserve space for the delimiter "##STEGO_END##" (13 chars * 8 bits = 104 bits)
    // Plus some overhead for safety.
    const int delimiterBits = 120; 
    
    if (totalBits <= delimiterBits) return 0;
    
    return (totalBits - delimiterBits) ~/ 8;
  }

  /// Checks if a message (after possible encryption) will fit in the image.
  static bool willFit(img.Image image, String message, {int bitsPerPixel = 3}) {
    final int maxChars = calculateMaxCharacters(image, bitsPerPixel: bitsPerPixel);
    return message.length <= maxChars;
  }
  
  /// Returns a percentage of capacity used.
  static double getUsagePercent(img.Image image, int messageLength, {int bitsPerPixel = 3}) {
    final int maxChars = calculateMaxCharacters(image, bitsPerPixel: bitsPerPixel);
    if (maxChars == 0) return 1.0;
    return (messageLength / maxChars).clamp(0.0, 1.0);
  }
}
