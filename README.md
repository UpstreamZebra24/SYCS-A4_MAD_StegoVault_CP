# StegoVault: Professional Steganography System Tool

StegoVault is a high-security, hardware-backed Android application designed for concealing encrypted data within image files. By combining military-grade cryptography with advanced bit-scattering steganography, StegoVault ensures that sensitive information remains both hidden and unreadable to unauthorized parties.

Developed as a "System Tool" for the Mobile Application Development (MAD) course, the application prioritizes stealth, data integrity, and local device security.

---

## 1. Core Security Architecture

StegoVault employs a multi-layered security model to protect data at rest and during the encoding/decoding process.

### 1.1 Authenticated Encryption (AES-256-GCM)
Before any data is hidden, it is encrypted using AES-256 in Galois/Counter Mode (GCM). This provides both confidentiality and integrity. The inclusion of an Authentication Tag ensures that if the carrier image is tampered with or corrupted, the application will detect the change and prevent the decryption of garbled data.

### 1.2 PBKDF2 Key Derivation
To protect against brute-force and dictionary attacks, user passphrases are not used directly as keys. StegoVault utilizes Password-Based Key Derivation Function 2 (PBKDF2) with 100,000 iterations of HMAC-SHA256 and a unique salt. This significantly increases the computational cost for an attacker attempting to guess the vault password.

### 1.3 Deterministic Bit-Scattering (LCG)
Unlike traditional Least Significant Bit (LSB) methods that hide data linearly from the first pixel, StegoVault utilizes a Linear Congruential Generator (LCG) to scatter bits across the entire image.
- **Algorithm:** The pixel traversal path is determined by a multiplicative hash: `(multiplier * i + offset) % total_pixels`.
- **Entropy:** The path is unique to the specific image dimensions and the user's secret key, making statistical detection (steganalysis) nearly impossible.

---

## 2. Key Features

### 2.1 Stealth Mode (Identity Obfuscation)
The application is disguised on the Android system as "System Tool" with a generic utility icon. This prevents casual observers from identifying the app as a secure vault, providing security through obscurity.

### 2.2 Passive Clipboard Guardian
To mitigate the risk of background "clipboard listener" malware, StegoVault monitors the system clipboard after a message is decoded. Exactly 60 seconds after the data is revealed, the application performs a secure wipe of the clipboard to ensure no sensitive plaintext remains in memory.

### 2.3 Hardware-Backed Biometrics
StegoVault integrates with the Android Trusted Execution Environment (TEE) to provide biometric authentication. Users can secure their vault using Fingerprint or FaceID, ensuring that only the authorized owner can access the interface, even if the device itself is unlocked.

### 2.4 Isolate-Driven Performance
To maintain a responsive 60 FPS user interface, all heavy computational tasks—including image encoding, bit-scattering, and AES encryption—are offloaded to Flutter Isolates. This prevents "Application Not Responding" (ANR) errors during the processing of high-resolution 4K imagery.

---

## 3. Technical Implementation Details

- **Language:** Dart / Flutter
- **Image Engine:** Native Dart `image` package (lossless PNG processing)
- **Crypto Engine:** AES-256-GCM via PointyCastle
- **Storage:** Flutter Secure Storage (Android Keystore / iOS Keychain)
- **Auth:** Local Auth (Biometric API)

---

## 4. Development Methodology (Spiral Model)

The project was developed across four distinct spirals, each adding a layer of complexity and hardening:

- **Spiral 1:** Foundation. Establishment of LSB logic and PNG-lossless pipeline.
- **Spiral 2:** Optimization. Implementation of LCG scattering and multi-threaded Isolates.
- **Spiral 3:** Hardening. Integration of AES-256-GCM and the Clipboard Guardian.
- **Spiral 4:** Finalization. Biometric hardware integration and Stealth Mode deployment.

Detailed reports for each spiral can be found in the `Project_Reports/` directory.

---

## 5. Installation and Setup

### Prerequisites
- Flutter SDK (3.24.x or higher)
- Android Studio / VS Code
- Android Device with Fingerprint sensor (recommended for full feature testing)

### Build Instructions
1. Clone the repository:
   ```bash
   git clone https://github.com/UpstreamZebra24/SYCS-A4_MAD_StegoVault_CP.git
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Build the Debug APK:
   ```bash
   flutter build apk --debug
   ```

---

## 6. Usage Guide

1. **Initialization:** Set a Master Password and enroll biometrics upon first launch.
2. **Encoding:** Select a carrier image, enter your secret message, and provide an encryption passphrase. The resulting "Stego-Image" will be saved to your gallery.
3. **Decoding:** Select a Stego-Image, enter the correct passphrase, and the hidden message will be revealed.
4. **Cleanup:** After reading the message, the clipboard will be automatically wiped after 60 seconds if the content was copied.

---

## 7. Group Information
Developed by the SYCS-A4 MAD Project Group (4 Members).
This project is for academic demonstration purposes only.
