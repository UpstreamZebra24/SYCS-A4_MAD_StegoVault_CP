import 'dart:io';

// Function to calculate the capacity of an image for steganography
int calculateImageCapacity(File image, int bitsPerPixel) {
  final int imageSize = image.lengthSync();
  return (imageSize * 8) ~/ bitsPerPixel;
}

// Function to validate the image capacity against a message size
bool validateImageCapacity(File image, String message, int bitsPerPixel) {
  final int capacity = calculateImageCapacity(image, bitsPerPixel);
  return message.length * 8 <= capacity;
}