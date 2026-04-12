# 🔐 Stegovault

**Stegovault** is a professional-grade, high-security offline vault for concealing encrypted messages within image files using advanced **Bit-Scattering Steganography**.

## 🚀 Key Features (Hardware Demonstration Ready)

*   **Entropy-Based Bit Scattering (Spiral 2):** Unlike traditional LSB which hides data in a straight line, Stegovault uses a **Multiplicative Hash Permutation (LCG)** to scatter bits across the entire image like random noise.
*   **Visual Scattering Heatmap:** A unique "Hub" feature allows users to visualize exactly where their data is hidden based on their specific passphrase's entropy.
*   **Authenticated AES-256-GCM:** Every message is encrypted with industry-standard AES-GCM and PBKDF2 key derivation before being hidden.
*   **Passive Clipboard Guardian:** To prevent data theft or accidental leaks, the app automatically wipes the system clipboard 60 seconds after a successful decode.
*   **Lossless PNG Engine:** Optimized image processing (uint8, 3-channel) ensures that no data is lost during the encoding or saving process.
*   **Modern "Security Vault" UI:** A premium, minimalist interface designed for clarity and ease of use during physical device demonstrations.
*   **Isolate-Driven Performance:** Heavy image processing is offloaded to background threads (Flutter Isolates) to ensure a smooth, 60 FPS user experience.

## 🛠️ Tech Stack

*   **Framework:** Flutter (3.24.x)
*   **Pixel Manipulation:** `image` (Native Dart)
*   **Cryptography:** `encrypt`, `pointycastle`
*   **Security:** `flutter_secure_storage`, `local_auth`
*   **Media:** `image_picker`

## 🧠 Technical Highlights

1.  **Bit Scattering Logic:** `(index * PRIME + SEED) % TOTAL_PIXELS`. This ensures every pixel is visited exactly once in a pseudo-random order.
2.  **LSB Implementation:** Modifies only the 0th bit of the Red, Green, and Blue channels for maximum stealth.
3.  **Secure Cleanup:** Active monitoring of the clipboard for 60 seconds post-decode to auto-wipe sensitive plaintexts.

## 🏁 Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/Adity/SYCS-A4_MAD_StegoVault_CP.git
    cd SYCS-A4_MAD_StegoVault_CP
    ```
2.  **Get dependencies:**
    ```bash
    flutter pub get
    ```
3.  **Run on Device:**
    ```bash
    flutter run --release
    ```

---
**Developed for the MAD (Mobile Application Development) Practical Demonstration.**
