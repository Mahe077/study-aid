# Release Notes

## Version 1.0.3

**Release Date:** February 01, 2026

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
