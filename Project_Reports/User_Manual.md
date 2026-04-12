# StegoVault: Operational User Manual

This manual provides detailed instructions on how to operate StegoVault (identified on the device as "System Tool"). It covers initial configuration, the core steganographic workflow, and advanced security features.

---

## 1. Initial Setup and Authentication

Upon the first launch of the application, the user must establish their secure identity.

1. **Master Password Configuration:** Set a strong Master Password. This password is required to access the application's administrative functions and is stored in the device's hardware-backed Secure Enclave.
2. **Biometric Enrollment:** If the device supports Fingerprint or FaceID, the application will prompt for biometric enrollment. Once enabled, the vault can be unlocked using the device's biometric sensor.
3. **Identity Verification:** On every subsequent launch, the user will be greeted by a biometric prompt or a password request. Access is denied if authentication fails three times consecutively.

---

## 2. Encoding: Hiding a Secret Message

The encoding process embeds an encrypted message within a carrier image.

1. **Select Carrier Image:** Tap "Select Image" in the Encode tab. Choose a high-quality PNG or high-resolution photo from the gallery. Note: Avoid using low-resolution images for long messages.
2. **Enter Secret Message:** Type the confidential information into the "Secret Message" field. The application will dynamically calculate the remaining capacity of the selected image.
3. **Set Encryption Passphrase:** Enter a unique passphrase for this specific message. This passphrase is used to derive the AES-256-GCM key.
4. **Initiate Encoding:** Tap "Encode and Save." The application will spawn a background thread (Isolate) to perform the LCG bit-scattering.
5. **Output:** The resulting "Stego-Image" will be saved to the device's gallery. The original image remains unmodified.

---

## 3. Decoding: Retrieving a Secret Message

The decoding process extracts and decrypts data from a previously encoded Stego-Image.

1. **Select Stego-Image:** Navigate to the Decode tab and select the image containing the hidden data.
2. **Enter Passphrase:** Provide the exact passphrase used during the encoding stage.
3. **Extracting Bits:** Tap "Decode Message." The application will follow the deterministic LCG path to collect the hidden bits and attempt AES decryption.
4. **Read and Clear:** If successful, the plaintext message will appear. After reading, the user should manually clear the screen.

---

## 4. Advanced Security Features

### 4.1 Bit-Scattering Heatmap
To verify the distribution of data, users can access the "Scattering Map" from the dashboard. This tool displays a visual representation of how the bits are spread across the image, confirming that the data does not form a detectable pattern.

### 4.2 Passive Clipboard Protection
If the user copies the decoded message to the system clipboard, StegoVault activates a 60-second countdown. After this period, the clipboard is automatically overwritten with a null value to prevent data leakage.

### 4.3 Format Integrity
StegoVault strictly utilizes the PNG format for output. Users must not convert these images to JPEG or other lossy formats, as the compression algorithms used by those formats will destroy the hidden bitstream.

---

## 5. Troubleshooting

- **"No Secret Message Found":** This occurs if the wrong passphrase is used, if the image has been compressed by a messaging app (like WhatsApp), or if the image was converted to JPEG.
- **"Capacity Exceeded":** The secret message is too large for the selected image's dimensions. Select a higher-resolution carrier image or shorten the message.
- **"Biometric Failure":** Ensure the sensor is clean. If biometrics fail repeatedly, use the Master Password fallback option.

---
**End of Manual**
