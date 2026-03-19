package com.example.stegovault.core // Update this package name to match your project

import android.graphics.Bitmap
import android.graphics.Color

object LsbCore {

    // A delimiter to let the decoder know when to stop reading bits
    private const val DELIMITER = "##STEGO_END##"

    /**
     * Spiral 1: Encodes a plaintext string sequentially into the LSB of a Bitmap.
     * Member 3 will pass the Bitmap here, and Member 4 will tie it to the UI text input.
     */
    fun encodeText(bitmap: Bitmap, text: String): Bitmap {
        val messageWithDelimiter = text + DELIMITER
        val messageBytes = messageWithDelimiter.toByteArray(Charsets.UTF_8)

        // Convert the message bytes into a flat list of bits (0s and 1s)
        val messageBits = mutableListOf<Int>()
        for (byte in messageBytes) {
            for (i in 7 downTo 0) {
                messageBits.add((byte.toInt() ushr i) and 1)
            }
        }

        // Create a mutable copy of the original bitmap to manipulate pixels
        val stegoBitmap = bitmap.copy(Bitmap.Config.ARGB_8888, true)
        val width = stegoBitmap.width
        val height = stegoBitmap.height

        var bitIndex = 0
        val totalBits = messageBits.size

        // Loop through the image pixels sequentially
        for (y in 0 until height) {
            for (x in 0 until width) {
                if (bitIndex >= totalBits) return stegoBitmap // Stop when all bits are hidden

                val pixel = stegoBitmap.getPixel(x, y)

                val a = Color.alpha(pixel)
                var r = Color.red(pixel)
                var g = Color.green(pixel)
                var b = Color.blue(pixel)

                // Clear the LSB (AND with 254 / 0xFE) and insert the message bit (OR)
                if (bitIndex < totalBits) {
                    r = (r and 0xFE) or messageBits[bitIndex]
                    bitIndex++
                }
                if (bitIndex < totalBits) {
                    g = (g and 0xFE) or messageBits[bitIndex]
                    bitIndex++
                }
                if (bitIndex < totalBits) {
                    b = (b and 0xFE) or messageBits[bitIndex]
                    bitIndex++
                }

                // Write the modified pixel back to the image
                stegoBitmap.setPixel(x, y, Color.argb(a, r, g, b))
            }
        }
        return stegoBitmap
    }

    /**
     * Spiral 1: Decodes plaintext from a stego-image until it hits the delimiter.
     */
    fun decodeText(stegoBitmap: Bitmap): String {
        val width = stegoBitmap.width
        val height = stegoBitmap.height

        val extractedBits = mutableListOf<Int>()
        val extractedBytes = mutableListOf<Byte>()

        for (y in 0 until height) {
            for (x in 0 until width) {
                val pixel = stegoBitmap.getPixel(x, y)

                // Extract the lowest bit (AND with 1) from RGB channels
                extractedBits.add(Color.red(pixel) and 1)
                extractedBits.add(Color.green(pixel) and 1)
                extractedBits.add(Color.blue(pixel) and 1)

                // Once we have 8 bits, reconstruct the byte (character)
                while (extractedBits.size >= 8) {
                    var byteValue = 0
                    for (i in 0 until 8) {
                        byteValue = (byteValue shl 1) or extractedBits.removeAt(0)
                    }
                    extractedBytes.add(byteValue.toByte())

                    // Convert current bytes to string and check if we found the delimiter
                    val currentString = String(extractedBytes.toByteArray(), Charsets.UTF_8)
                    if (currentString.endsWith(DELIMITER)) {
                        return currentString.removeSuffix(DELIMITER)
                    }
                }
            }
        }
        
        // Failsafe: return whatever was found if the delimiter is missing
        return String(extractedBytes.toByteArray(), Charsets.UTF_8).removeSuffix(DELIMITER)
    }
}
