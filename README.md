# 🎙️ AudioTranscriptionIPA

**Live iOS Speech-to-Text Transcription**

![Platform](https://img.shields.io/badge/Platform-iOS-blue)
![Language](https://img.shields.io/badge/Language-Swift-orange)
![Framework](https://img.shields.io/badge/Framework-Speech%20%26%20AVFoundation-green)
![Baked By](https://img.shields.io/badge/Baked%20by-SnigBugz-firebrick)

A native iOS application that performs real-time speech-to-text transcription using Apple's **Speech Framework** (`SFSpeechRecognizer`) and **AVFoundation**. This project demonstrates how to capture live audio from the microphone and convert it into text instantly on the device.

---

### 🔥 Baked by [SnigBugz](https://github.com/snigbugz) 😉

---

## 🚀 Features

*   **Real-time Transcription:** Converts speech to text as you speak with minimal latency.
*   **Native Performance:** Uses Apple's internal `SFSpeechRecognizer` for high accuracy and battery efficiency.
*   **On-Device Capability:** Supports offline transcription (if language packs are installed on the device).
*   **Live UI:** Visual feedback indicating when the app is listening.

## 🛠 Tech Stack

*   **Language:** Swift
*   **Frameworks:** `Speech`, `AVFoundation`, `UIKit` / `SwiftUI`
*   **Minimum Target:** iOS 15.0+

## ⚖️ License & Usage

**© SnigBugz**

This project is open for educational purposes, code inspection, and personal testing. 

**Conditions of Use:**
*   You are free to view and test the code.
*   **Commercial use, redistribution, or publishing modified versions requires explicit permission from the owner.**
*   Please contact **SnigBugz** for usage rights beyond personal experimentation.

## ⚙️ Installation & Setup for Developers

1.  **Clone the repository**
    ```bash
    git clone https://github.com/snigbugz/AudioTranscriptionIPA.git
    cd AudioTranscriptionIPA
    ```

2.  **Open in Xcode**
    *   Open `AudioTranscriptionIPA.xcodeproj`.

3.  **Configure Signing**
    *   Select the Project Root > **Signing & Capabilities**.
    *   Select your **Team**.
    *   Update the **Bundle Identifier** (e.g., `com.snigbugz.transcription`).

4.  **Permissions**
    *   The app requires Microphone and Speech Recognition access. Ensure you click **"Allow"** when prompted on the first launch.

---
