# Spiral 2: Advanced Bit-Scattering & Multi-Threading

**Phase:** Intermediate Development Cycle
**Theme:** Cryptographic Randomness, Performance Optimization, and Visual Entropy

---

## 1. Executive Summary & Technical Scope
Spiral 2 marked a significant evolution in StegoVault's security model. The transition was made from "Simple Linear LSB" to "Non-Linear Bit Scattering." This phase focused on ensuring that hidden data was statistically indistinguishable from random sensor noise. Additionally, the team addressed the "UI Freeze" problem identified in Spiral 1 by implementing multi-threaded execution.

### Technical Goals:
1.  **Bit Scattering Logic:** Implement a deterministic but pseudo-random pixel traversal path.
2.  **Concurrency (Isolates):** Offload millions of pixel-level operations to background threads.
3.  **Visual Entropy Map:** Create a "Heatmap" tool to verify the scattering pattern.

---

## 2. Detailed Technical Breakdown

### 2.1 The Linear Congruential Generator (LCG)
To hide data securely, we cannot simply use a `Random()` function, as the decoder must follow the *exact same path* as the encoder. We implemented a custom LCG:
- **Formula:** `(multiplier * i + offset) % totalPixels`
- **The Golden Ratio:** We used a multiplier derived from the Golden Ratio ($0.618$) and ensured it was coprime to the total number of pixels using a Greatest Common Divisor (`GCD`) check. This ensures a "perfect shuffle" where every pixel is visited exactly once.

### 2.2 Flutter Isolates & `compute`
Image processing is CPU-intensive. A 12MP image has 12,000,000 pixels, each requiring bitwise manipulation. Doing this on the main thread causes the UI to drop to 0 FPS.
- **Solution:** We implemented `Isolates`. By using Flutter's `compute` function, we spawned a separate background worker thread. The main thread only handles the "Loading" animation, while the Isolate handles the heavy pixel crunching.

### 2.3 The "Heatmap" Visualization
To prove the effectiveness of the scattering, we developed a "Heatmap" engine. It generates a black-and-white mask where each white pixel represents a bit of hidden data. This confirms that the message is "exploded" across the image like static, rather than concentrated in one corner.

---

## 3. Team Contributions & Work Breakdown

### Member 1: Algorithm Lead (The Math Brain)
**Focus:** Non-Linear Pathing & Determinism
- Developed the `_permuteIndex` logic. This required solving the mathematical problem of visiting $N$ pixels in a random-looking order without repeats.
- Implemented the `_gcd` function to verify coprimality between the LCG multiplier and the pixel count, which is the key to a successful "Perfect Shuffle."
- **Key Deliverable:** A robust, deterministic scattering engine that works on images of any dimension (square or rectangular).

### Member 2: Performance & Concurrency Specialist (Optimization)
**Focus:** Thread Management & Memory Efficiency
- Refactored the entire `StegoService` to be "Async-First."
- Implemented the `compute(_encodeTask, params)` logic. This involved creating `EncodeParams` and `DecodeParams` data classes to safely pass large chunks of memory between isolates.
- Optimized memory usage by using `Uint8List` (byte arrays) instead of high-level objects during the transfer process.
- **Key Deliverable:** A 500% improvement in perceived UI performance during large image encoding.

### Member 3: UI Specialist (Data Visualization)
**Focus:** Visual Verification & The "Hub"
- Developed the "Heatmap" screen (internally known as "The Hub").
- Implemented the logic to render the LCG path as a PNG overlay, allowing the user to "see" their encryption entropy.
- Designed the "Processing" overlay with real-time status updates (e.g., "Calculating Entropy...", "Scattering Bits...").
- **Key Deliverable:** The Bit-Scattering Map dialog, providing a unique "Security Visual" for the MAD presentation.

### Member 4: Resource Manager (System Stability)
**Focus:** Capacity Planning & Error Handling
- Developed the `CapacityCalculator.dart` engine. This prevents "Index Out of Bounds" errors by calculating the exact bit-capacity of an image *before* the user starts typing.
- Implemented the "Capacity Meter" UI, which changes from green to red as the user nears the image's storage limit.
- Researched "Pixel Format Stability" and ensured the app only works with 8-bit per channel images (standard RGB).
- **Key Deliverable:** A foolproof validation system that protects the app from crashing due to large payloads.

---

## 4. Challenges & Engineering Solutions

| Challenge | Engineering Solution |
| :--- | :--- |
| **Non-Bijective Mapping** | Early hash-based scattering skipped some pixels. We switched to an LCG formula which is mathematically guaranteed to hit every pixel once. |
| **Isolate Data Transfer** | Copying large images between threads caused memory spikes. We optimized by decoding the image *inside* the isolate instead of passing a pre-decoded object. |
| **Sync Issues** | If the multiplier changed by 1 between encode and decode, the message was lost. We fixed this by using a shared `Random(seed)` to generate the offset. |

---

## 5. Evaluation of Spiral 2
Spiral 2 successfully solved the "Performance" and "Pattern" vulnerabilities. We moved from a simple "toy" app to a technically sophisticated system capable of handling high-resolution imagery.

**Conclusion:** The project is now stable enough to integrate high-level security: AES-256 and Biometrics in Spiral 3.
