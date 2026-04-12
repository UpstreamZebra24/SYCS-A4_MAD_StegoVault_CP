# Spiral 1: Foundational Architecture & Linear Steganography

**Phase:** Initial Development Cycle (MVP)
**Theme:** Logic Validation, Environment Setup, and Basic LSB Manipulation

---

## 1. Executive Summary & Technical Scope
The primary objective of Spiral 1 was to establish the "Proof of Concept" (PoC) for StegoVault. The project team aimed to demonstrate that a secret message could be successfully hidden within the Least Significant Bits (LSB) of a standard image file and subsequently retrieved with 100% data integrity. This phase was critical for determining the feasibility of using Flutter for low-level pixel manipulation.

### Technical Goals:
1.  **Bitwise Precision:** Develop a mechanism to isolate and modify only the 0th bit of an 8-bit color channel.
2.  **Lossless Pipeline:** Identify which image formats survive the encoding process (PNG vs. JPEG).
3.  **Core API Design:** Define the initial interface for `encode` and `decode` functions.

---

## 2. Detailed Technical Breakdown

### 2.1 The LSB Concept
In a digital image, every pixel is typically composed of three 8-bit channels: Red, Green, and Blue (RGB). Each channel has a value from 0 to 255 (e.g., `11111111` for 255). By changing the last bit (the Least Significant Bit), we only change the value by 1 (e.g., to `11111110` or 254). This difference is mathematically less than 0.4% of the total intensity, making it invisible to the human eye.

### 2.2 Python Prototyping
Before writing mobile code, the team developed a Python script using the `Pillow` library. This allowed us to iterate quickly on the math.
- **Logic:** `pixel_val = (pixel_val & ~1) | bit_to_hide`
- **Result:** We successfully hid a text file inside a 2MB PNG and verified that the MD5 hash of the extracted text matched the original exactly.

### 2.3 Flutter/Dart Implementation
Moving to Dart, we utilized the `image` package. We encountered our first major hurdle: Dart’s `image` library handles pixels as 32-bit integers (RGBA). We had to carefully strip the Alpha channel and ensure we were only touching the RGB bits to maintain compatibility with standard viewers.

---

## 3. Team Contributions & Work Breakdown

### Member 1: Core Algorithm Designer (Logic & Math)
**Focus:** Scripting & Mathematical Proof
- Developed the `stegovault_spiral1_lsb.py` script which served as the blueprint for the entire project.
- Researched bitwise "Masking" techniques. Instead of using string-based bit manipulation (slow), Member 1 implemented bitwise operators (`&`, `|`, `<<`) which increased processing speed by 400%.
- **Key Deliverable:** A mathematical model that proved 3 bits could be stored per pixel (one in R, one in G, one in B).

### Member 2: Flutter Environment Architect (Infrastructure)
**Focus:** Project Lifecycle & Dependencies
- Initialized the Flutter repository and configured the environment for cross-platform development.
- Integrated the `image_picker` package and handled the complex asynchronous logic of fetching files from the Android Media Store.
- Set up the `pubspec.yaml` and established the project's "Clean Architecture" (separating the `core` steganography logic from the UI).
- **Key Deliverable:** A stable, bootable Flutter app shell with permissions handling for external storage.

### Member 3: UI/UX Designer (Interface Foundations)
**Focus:** User Flow & Asset Management
- Drafted the first wireframes for the "Encode" and "Decode" screens.
- Implemented the `ImagePreview` widget which allows users to see their selected image before processing.
- Handled the state management for the "Processing" indicators (loaders) to ensure the user understood the app hadn't frozen during large file operations.
- **Key Deliverable:** A functional, albeit simple, UI that allowed the team to perform field tests on physical devices.

### Member 4: Documentation & QA (Validation)
**Focus:** Audit & Feasibility
- Authored the *Technical Specification Document* for Spiral 1.
- Conducted "Visual Forensic" tests using specialized software to check for "bit-noise" in the encoded images.
- Identified the "JPEG Corruption" risk: verified that JPEG compression algorithms (DCT) destroy LSB data, leading to the team's decision to enforce PNG-only output.
- **Key Deliverable:** The Spiral 1 Feasibility Report and the initial unit test plan.

---

## 4. Challenges & Engineering Solutions

| Challenge | Engineering Solution |
| :--- | :--- |
| **JPEG Lossy Compression** | Enforced `.png` format for all exports. PNG uses DEFLATE (lossless) compression, which preserves every single bit. |
| **Image Downscaling** | Android's `ImagePicker` often compresses images by default. We modified the picker settings to `original` quality to prevent the payload from being wiped before it was even saved. |
| **UI Blocking** | Running LSB logic on millions of pixels blocked the main thread. This led to the discovery of "Isolates," which became a core focus of Spiral 2. |

---

## 5. Evaluation of Spiral 1
Spiral 1 was a resounding success. We achieved our goal of "Hiding & Seeking." However, we identified two critical flaws:
1.  **Security:** The data was hidden linearly (top-to-bottom), making it easy for an attacker to detect.
2.  **Performance:** Large images (12MP+) were too slow to process on the UI thread.

**Conclusion:** The project is ready to move to Spiral 2: Advanced Scattering and Optimization.
