// lsb_steganography.dart

class LSBSteganography {
  // Encode a message into an image using LSB steganography
  static List<int> encode(List<int> imageBytes, String message) {
    List<int> messageBytes = message.codeUnits;
    int messageLength = messageBytes.length;

    for (int i = 0; i < messageLength; i++) {
      // Set the LSB of each byte in the image to the message bit
      imageBytes[3 * i] = (imageBytes[3 * i] & ~1) | (messageBytes[i] & 1);
      imageBytes[3 * i + 1] = (imageBytes[3 * i + 1] & ~1) | ((messageBytes[i] >> 1) & 1);
      imageBytes[3 * i + 2] = (imageBytes[3 * i + 2] & ~1) | ((messageBytes[i] >> 2) & 1);
    }
    // Return the modified image bytes
    return imageBytes;
  }

  // Decode a hidden message from an image using LSB steganography
  static String decode(List<int> imageBytes, int messageLength) {
    List<int> messageBytes = [];
    for (int i = 0; i < messageLength; i++) {
      int byte = 0;
      // Retrieve the message from the LSBs of the image
      byte |= (imageBytes[3 * i] & 1);
      byte |= ((imageBytes[3 * i + 1] & 1) << 1);
      byte |= ((imageBytes[3 * i + 2] & 1) << 2);
      messageBytes.add(byte);
    }
    return String.fromCharCodes(messageBytes);
  }
} 

void main() {
  // Example usage
  List<int> image = [255, 255, 255, 255, 255, 255]; // Sample image bytes
  String message = 'Hi';
  List<int> encoded = LSBSteganography.encode(image, message);

  String decoded = LSBSteganography.decode(encoded, message.length);
  print('Decoded message: $decoded');
}