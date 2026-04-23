# StegoVault Technical Dossier: Architecture, Implementation, and Security Protocols

## 1. Executive Summary

StegoVault is a sophisticated mobile security application designed to provide an undetectable layer of data protection through the integration of military-grade cryptography and advanced steganographic techniques. Codenamed "System Tool" to maintain operational stealth, the application allows users to conceal sensitive text-based information within common image files (PNG). Unlike standard encryption tools that merely lock data, StegoVault hides the very existence of the data itself. This document serves as a comprehensive technical guide detailing the internal mechanisms, mathematical foundations, and security philosophies implemented in the project.

---

## 2. Threat Model and Security Philosophy

### 2.1 The Concept of Plausible Deniability
In many security contexts, the presence of an encrypted file is enough to draw unwanted attention. StegoVault operates on the principle of Steganography, which aims for "Security through Obscurity" in addition to "Security through Cryptography." By hiding data within a carrier image, the user can plausibly deny that any sensitive information is being stored on the device.

### 2.2 Defense in Depth
StegoVault utilizes a five-layer security stack:
1. Identity Obfuscation (App renaming and icon masking).
2. Physical Access Control (Hardware-backed biometric authentication).
3. Data Confidentiality (AES-256-GCM encryption).
4. Statistical Hardening (LCG-based bit scattering).
5. Data Camouflage (3-bit LSB manipulation).

---

## 3. Cryptographic Architecture

### 3.1 Authenticated Encryption (AES-256-GCM)
The first step in the data pipeline is the transformation of plaintext into ciphertext. StegoVault utilizes the Advanced Encryption Standard (AES) with a 256-bit key. We have implemented the Galois/Counter Mode (GCM), which is an "Authenticated Encryption" mode.
- **Privacy:** AES-256 ensures that without the correct key, the message is mathematically unreadable.
- **Integrity:** GCM produces a 16-byte Authentication Tag. During the decoding process, the app recalculates this tag. If the image has been altered (even by a single pixel), the tags will not match, and the app will reject the data as "tampered."

### 3.2 Key Stretching via PBKDF2
User-provided passphrases are often weak. StegoVault employs PBKDF2 (Password-Based Key Derivation Function 2) to derive the actual 256-bit encryption key.
- **Salt:** A fixed 16-byte salt is appended to every passphrase to prevent rainbow table attacks.
- **Iterations:** The process runs for 100,000 iterations of the HMAC-SHA256 hash. This "hardens" the key, making brute-force attempts computationally expensive for an adversary while remaining instantaneous for the legitimate user.

---

## 4. Steganographic Engineering

### 4.1 Least Significant Bit (LSB) Manipulation
At the bitstream level, StegoVault modifies the 0th bit of the Red, Green, and Blue color channels of a pixel. Each color channel is represented by an 8-bit integer (0-255).
- Changing the LSB shifts the color value by only 1 unit.
- In a 24-bit color space (8 bits per RGB channel), this change represents less than 0.4% of the color's intensity.
- This shift is physically impossible for the human retina to distinguish, effectively making the data "invisible" in the visual spectrum.

### 4.2 Deterministic Bit-Scattering (The LCG Algorithm)
To prevent detection by computer-based statistical analysis (steganalysis), StegoVault does not hide data in a linear sequence. Instead, it "explodes" the message across the entire image using a Linear Congruential Generator (LCG).

#### The Mathematical Formula:
The path is calculated as: `(Multiplier * i + Offset) % Total_Pixels`

- **Multiplier:** Derived using the Golden Ratio (0.61803398875). This specific ratio provides the most uniform distribution of data points across the image grid.
- **Offset:** Generated from a seed based on the user's secret passphrase.
- **GCD Verification:** The system performs a Greatest Common Divisor check to ensure the Multiplier and Total Pixels are "coprime." This mathematical property guarantees that the algorithm visits every single pixel in the image exactly once, ensuring zero data collisions.

---

## 5. System Implementation and Performance

### 5.1 Multi-Threaded Isolates
Pixel manipulation is a CPU-bound task. For a 12-Megapixel image, the application must perform millions of bitwise and modular arithmetic operations.
- **Main Isolate:** Handles the UI rendering, user input, and animations at a smooth 60 FPS.
- **Background Isolate:** Spawns a secondary worker thread to handle the "Stego Engine." This prevents the UI from freezing during the encoding and decoding process, providing a professional-grade user experience.

### 5.2 Deterministic Decoding
Because the LCG scattering is based on a mathematical formula rather than random chance, it is 100% deterministic. As long as the user provides the correct passphrase, the decoder will follow the exact same scattered path through the image bits to reconstruct the original message.

---

## 6. Advanced Security Features

### 6.1 Stealth Mode Identity
The application manifest is configured to register the app as "System Tool." This obfuscates the app's presence in the device's app drawer and task switcher. The user interface utilizes a "Deep Indigo" color palette to maintain a professional, secure aesthetic.

### 6.2 Passive Clipboard Guardian
Data leakage often occurs after the data has been decrypted. If a user copies a revealed secret, StegoVault activates the Clipboard Guardian. A 60-second timer runs in the background. Once the timer expires, the application sends a signal to the Android system to overwrite the clipboard, effectively shredding the sensitive data.

### 6.3 Hardware-Backed Biometrics
StegoVault communicates with the device's Trusted Execution Environment (TEE). The Master Password is not stored in plain text but is protected by the phone's hardware security module. Access to the "Vault" requires a successful biometric match (Fingerprint/FaceID), ensuring that even if the device is stolen while unlocked, the StegoVault remains inaccessible.

---

## 7. Operational Guidelines and Constraints

### 7.1 Format Stability: PNG vs. JPEG
StegoVault strictly requires the use of PNG (Portable Network Graphics).
- **PNG:** A lossless format that preserves every bit exactly as it was written.
- **JPEG:** A lossy format that uses the Discrete Cosine Transform (DCT) to compress images. This compression "rounds off" small color differences, which would inadvertently delete the hidden LSB data.

### 7.2 The Delimiter Protocol
To identify where the message ends amidst the millions of pixels, the app appends a unique 12-byte sequence (`##STEGO_END##`) to the payload. The decoder reads the bitstream until it encounters this "Stop Sign," ensuring that no extraneous noise is included in the final output.

---

## 8. Group Contribution and Development Lifecycle

The development of StegoVault followed the Spiral Model, allowing for iterative refinement of the security protocols across four cycles:
- **Spiral 1:** Implementation of the 1-bit linear LSB foundation.
- **Spiral 2:** Development of the LCG scattering algorithm and multi-threaded Isolates.
- **Spiral 3:** Integration of AES-256-GCM and the PBKDF2 hardening layer.
- **Spiral 4:** Finalization of hardware-backed biometrics, Stealth Mode, and the Passive Clipboard Guardian.

### Team Roles:
- **Member 1 (Algorithm Lead):** Mathematical design of LCG scattering and bitwise logic.
- **Member 2 (Infrastructure Lead):** Multi-threading, Isolate management, and performance optimization.
- **Member 3 (Security & UX Lead):** Cryptographic integration, UI design, and Stealth Mode implementation.
- **Member 4 (QA & Systems Lead):** Capacity calculation engine, hardware biometric integration, and simulation testing.

---
**End of Document**
