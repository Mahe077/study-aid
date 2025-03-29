# Study Aid 🎓

[![Flutter](https://img.shields.io/badge/Flutter-3.16.9-blue)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-12.3.1-orange)](https://firebase.google.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A cross-platform study companion application with advanced note-taking and voice recording capabilities, integrated with cloud synchronization.

![Study Aid Demo](https://via.placeholder.com/800x400?text=Study+Aid+Demo) <!-- Add real screenshots -->

## ✨ Features

- **Multi-modal Note Taking**
  - Rich text editor with Flutter Quill
  - Voice note recording & playback
  - Image embedding with Firebase Storage
  - Color-coded topic organization

- **Smart Sync System**
  - Offline-first architecture with Hive
  - Conflict resolution for multi-device sync
  - Firebase Firestore backend
  - Automatic cloud backups

- **Authentication**
  - Email/password login
  - Google & Facebook OAuth
  - Secure credential storage
  - Password recovery flow

- **Audio Processing**
  - Waveform visualization
  - MP3 encoding/decoding
  - Background audio playback
  - File system management

## 🛠 Tech Stack

**Core Framework**  
- Flutter 3.16.9

**State Management**  
- Riverpod 2.3.6

**Backend Services**  
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Firebase App Check

**Local Storage**  
- Hive 2.2.3
- Shared Preferences

**Audio Processing**  
- audio_waveforms 1.0.5
- just_audio 0.9.41

**Rich Text Editing**  
- flutter_quill 10.8.2

## 🚀 Installation

1. **Clone Repository**
   ```bash
   git clone https://github.com/yourusername/study_aid.git
   cd study_aid
   ```

2. **Flutter Setup**
   ```bash
   flutter pub get
   flutter gen-l10n
   ```

3. **Firebase Configuration**
   - Add `google-services.json` to `android/app`
   - Add `GoogleService-Info.plist` to iOS Runner
   - Enable Authentication/Firestore in Firebase Console

4. **Run Application**
   ```bash
   flutter run -d chrome # For web
   flutter run # For mobile
   ```

## 📚 Documentation

- [Riverpod State Management Guide](https://riverpod.dev)
- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup)
- [Hive Local Storage Docs](https://docs.hivedb.dev)

## 🤝 Contributing

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

## 🙏 Acknowledgments

- Flutter Community
- Firebase Team
- Hive Maintainers
- Audio Waveforms Library Authors
