# 🔐 Stegovault

**Stegovault** is a secure, fully offline mobile application built with Flutter that conceals encrypted text messages within image files. It combines authenticated cryptography (AES-GCM) with advanced, randomized steganography (LSB manipulation) to ensure secure and undetectable communication.

## 🚀 Core Features

* **100% Offline Architecture:** Designed with zero network calls for encryption or key generation, ensuring maximum resistance to remote interception.
* **Authenticated Cryptography:** Utilizes a Key Derivation Function (PBKDF2/Argon2) paired with **AES-GCM** to encrypt messages. This ensures payloads are not only hidden but mathematically protected against tampering.
* **Randomized Steganography:** Employs Pseudo-Random Number Generation (PRNG) seeded by the encryption key to scatter message bits across the image's Least Significant Bits (LSB), preventing visual or statistical detection.
* **Smart Capacity Validation:** Automatically calculates the maximum payload size of the selected image before encoding to prevent data loss or application crashes.
* **Lossless Export:** Strictly enforces PNG/BMP image exports to guarantee the hidden payload survives local transfer without being destroyed by compression.
* **Hardware-Backed Security:** Integrates local biometric authentication (Fingerprint/FaceID) and the device's Secure Enclave/Keystore to safely manage the offline password.

## 🛠️ Tech Stack

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **Target Platforms:** Android & iOS (Cross-platform)
* **Cryptography:** `encrypt`, `pointycastle` packages
* **Image Processing:** `image` package (Native Dart pixel manipulation)
* **Local Security:** `flutter_secure_storage`, `local_auth`

## 🧠 System Workflow

1. **Unlock:** User authenticates via Biometrics.
2. **Key Generation:** Offline password is fed into a KDF to derive a 256-bit key.
3. **Encrypt:** Plaintext message is encrypted via AES-GCM.
4. **Evaluate:** App validates if the selected image has sufficient capacity for the ciphertext.
5. **Encode:** Ciphertext is randomly scattered into the image's LSB.
6. **Export:** A lossless `Stego-Image.png` is generated for the user to securely transmit.

## 🏁 Getting Started (For Developers)

### Prerequisites
* [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
* [Android Studio](https://developer.android.com/studio) or VS Code with the Flutter extension.
* An Android Emulator or physical device for testing.

### Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/YOUR-USERNAME/Stegovault.git](https://github.com/YOUR-USERNAME/Stegovault.git)
   cd Stegovault
