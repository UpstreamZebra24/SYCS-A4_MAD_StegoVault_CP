# Spiral 4: Hardware Integration & Stealth Finalization

**Phase:** Final Deployment Cycle
**Theme:** Biometric Identity, Secure Enclave, and Obfuscated Presence

---

## 1. Executive Summary & Technical Scope
Spiral 4 was the final "polishing" phase, focusing on hardware-level security and making the app ready for a professional physical device demonstration. The team moved the app's security beyond software-only logic by integrating the device's TEE (Trusted Execution Environment). Additionally, we implemented a "Stealth Mode" to ensure that the app itself doesn't become a target for investigation.

### Technical Goals:
1.  **Biometric Lock:** Integrate Fingerprint and FaceID via the Android Biometric Prompt.
2.  **Hardware Storage:** Use the Secure Enclave (Keystore/Keychain) to store master credentials.
3.  **Identity Obfuscation:** Disguise the app as a "System Tool" to hide its true purpose.

---

## 2. Detailed Technical Breakdown

### 2.1 Biometric Authentication (TEE)
We implemented the `local_auth` package to communicate with the device's security hardware. 
- **Security:** When the user taps "Unlock Vault," the app sends a request to the Android OS. The OS handles the fingerprint scan inside a "Secure Enclave" (hardware isolated from the rest of the phone). 
- **Result:** The app never sees the user's actual fingerprint data; it only receives a "Success" or "Failure" token, ensuring maximum user privacy.

### 2.2 Secure Storage (Keystore)
Storing a Master Password in a standard file is dangerous. We implemented **Secure Storage**:
- **Android:** Uses the **Android Keystore**, which encrypts data at rest using hardware-backed keys.
- **Data:** We store the Vault's "Master Password" here. This ensures that even if the phone is "Rooted" or the storage is dumped, the password remains encrypted by the phone's CPU hardware.

### 2.3 "System Tool" Stealth Mode
For a steganography app, being named "StegoVault" is a liability. We performed a "Stealth Overhaul":
- **AndroidManifest.xml:** Changed the `android:label` to **"System Tool"**.
- **Launcher:** The app icon is now a generic gear/utility icon.
- **Task Switcher:** In the recent apps list, it identifies as "System Tool," making it invisible to casual snoopers or "shoulder surfers."

---

## 3. Team Contributions & Work Breakdown

### Member 1: Hardware-Security Lead (Device Integrity)
**Focus:** Biometric Prompt & Hardware Fallbacks
- Configured the `AuthService.dart` to handle complex biometric states (e.g., "Locked Out," "No Biometrics Enrolled," "Hardware Not Supported").
- Implemented the "Fallback to PIN" logic, ensuring that users can still access their vault if their fingerprint sensor is damaged.
- **Key Deliverable:** A rock-solid "Lock Screen" that serves as the first line of defense for the entire application.

### Member 2: Secure Enclave Architect (Data-at-Rest)
**Focus:** Encrypted Storage & Key Management
- Developed the `SecureStorageService.dart`. This required mapping the `flutter_secure_storage` API to the specific hardware requirements of Android 12+.
- Implemented the "Vault Initialization" flow: the first time the app runs, it prompts the user to "Initialize" their secure identity, which is then burned into the hardware keystore.
- **Key Deliverable:** A persistent, hardware-encrypted storage system for the app's master credentials.

### Member 3: UI Specialist (Obfuscation Design)
**Focus:** Deep Indigo Theme & App Identity
- Performed the "Stealth Transformation": modified the Android Manifest and app metadata to rename the project to **"System Tool"**.
- Finalized the **Deep Indigo Theme** (`0xFF1A237E`). This theme was chosen to give the app a "Premium/Secure" feel, moving away from the bland default Material look.
- Implemented "Visual Feedback" for the demo, such as the "Extracting Bits..." status messages that show off the isolate processing.
- **Key Deliverable:** A professional, polished, and disguised UI that is ready for a hardware-based presentation.

### Member 4: Project Lead & Simulation Tester (Verification)
**Focus:** Quality Control & Final Documentation
- Developed the **Full Project Simulation Suite** (`steganography_test.dart`). This script runs 5+ complex scenarios, including "Correct Passphrase," "Wrong Passphrase," and "Image Corruption."
- Authored the final **README.md** and the **Spiral Reports**, ensuring all technical milestones were clearly documented for the examiners.
- Conducted the "Physical Device Handover" test, verifying that the APK works perfectly on an actual Android 14 device (not just the emulator).
- **Key Deliverable:** A "Green-Lit" project with zero known bugs and comprehensive documentation.

---

## 4. Challenges & Engineering Solutions

| Challenge | Engineering Solution |
| :--- | :--- |
| **Auth Bypass** | During testing, we needed to skip biometrics. We implemented a `developerMode` ValueNotifier that is hidden in the production build but accessible for dev-testing. |
| **Storage Persistence** | If the app is uninstalled, the Keystore is wiped. We added a "Backup Warning" to the UI to inform users that their Master Password is tied to the physical device. |
| **The "System Tool" Name** | Changing the name in Flutter doesn't change it in Android. We had to manually edit the XML manifest to ensure the OS recognized the new name. |

---

## 5. Final Evaluation
The project has successfully completed all 4 spirals. StegoVault is no longer a simple student project; it is a feature-complete security application that demonstrates a deep understanding of mobile architecture, cryptography, and hardware integration.

**Final Status:** READY FOR PRESENTATION.
