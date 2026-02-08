# Release Notes - Study Aid 🎓

## [1.0.0] - 2026-01-17

Welcome to the initial release of **Study Aid**! This version establishes the foundation for a powerful, cross-platform study companion designed to enhance your learning experience through multi-modal note-taking and smart cloud synchronization.

### ✨ Key Features

- **📝 Multi-modal Note Taking**
  - **Rich Text Editor**: Create structured notes with formatting using the integrated Flutter Quill editor.
  - **Voice Notes**: Record lectures or thoughts directly within the app with real-time waveform visualization.
  - **Drawings**: Capture ideas visually with a dedicated drawing board.
  - **Image Support**: Embed images into your notes for better context.

- **🔄 Smart Sync & Offline Support**
  - **Cloud Sync**: Seamlessly synchronize your data across devices using Firebase Firestore and Storage.
  - **Offline First**: Access and edit your notes even without an internet connection, powered by Hive local storage.
  - **Automatic Backups**: Your data is safely backed up to the cloud automatically.

- **🔐 Secure Authentication**
  - Multiple sign-in options including Email/Password, Google, and Facebook.
  - Secure credential management and password recovery flow.

- **📁 Organization**
  - Categorize your notes by topics with color-coding for easy retrieval.
  - Advanced search functionality to find your content quickly.

### 🛠 Technical Stack

- **Framework**: Flutter (Cross-platform support for iOS, Android, Web, and Desktop).
- **State Management**: Riverpod for robust and scalable state handling.
- **Backend**: Firebase (Auth, Firestore, Storage, App Check).
- **Local Database**: Hive for high-performance offline data storage.
- **Audio**: Just Audio & Audio Waveforms for high-quality audio processing.

## [1.0.3] - 2026-02-01

### 🚀 New Features

- **File Upload**: Added support for uploading files to create notes.
- **AI-Powered Summarization**: We've upgraded our summarization engine to use OpenAI for faster, high-quality document summaries.
  - Automatically extracts titles from the summary.
  - Formats content beautifully with headers, lists, and bold text.
  - Supports large documents with smart chunking.
- **File Counts**: Added a visual indicator for the number of files in each topic card.

### 🐛 Bug Fixes

- **iOS File Opening**: Fixed a critical issue where opening files on iOS would fail or open in a restricted preview. Files now open seamlessly in the default external application (Safari/Files app).

### 🔧 Improvements

- Updated `ContentTile` to display file counts accurately.
- Improved error handling for summarization service.
- Added tile colour change option

## [1.1.0] - 2026-02-07

### 🔊 Text-to-Speech (Pro)

- **High-Quality AI Voices**: Experience natural-sounding audio with OpenAI's advanced TTS engine.
- **Enhanced Player**:
  - Precision controls: Play, Pause, Restart, Seek (±15s).
  - Continuous playback for multiple notes.
  - Variable speed control (0.5x - 2.0x).
  - Background caching for smooth listening.
- **Voice Customization**: Choose your preferred AI voice in Settings.

### 🔄 Sync Improvements

- **Reliable File Sync**: Smarter handling of missing files reduces sync errors.
- **Offline Support**: Better detection and recovery when switching network states.

### 🐛 Bug Fixes

- **Player Stability**: Resolved crashes and state synchronization issues in the audio player.
- **Layout**: Optimized player positioning to work seamlessly with the Floating Action Button.

---

_Thank you for using Study Aid!_
