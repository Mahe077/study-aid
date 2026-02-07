import 'dart:async';

/// Manages a queue of audio file paths for sequential playback
class AudioQueueManager {
  final List<String> _audioFilePaths = [];
  int _currentIndex = 0;
  String? _preloadedNextPath;

  final _indexController = StreamController<int>.broadcast();
  final _queueChangedController = StreamController<void>.broadcast();

  /// Stream of current queue index changes
  Stream<int> get indexStream => _indexController.stream;

  /// Stream of queue changes
  Stream<void> get queueChangedStream => _queueChangedController.stream;

  /// Current queue index
  int get currentIndex => _currentIndex;

  /// Total number of items in queue
  int get totalItems => _audioFilePaths.length;

  /// Whether there is a next item in the queue
  bool get hasNext => _currentIndex < _audioFilePaths.length - 1;

  /// Whether there is a previous item in the queue
  bool get hasPrevious => _currentIndex > 0;

  /// Whether queue is empty
  bool get isEmpty => _audioFilePaths.isEmpty;

  /// Gets the current audio file path
  String? get currentPath =>
      _currentIndex < _audioFilePaths.length ? _audioFilePaths[_currentIndex] : null;

  /// Gets the next audio file path (for preloading)
  String? get nextPath =>
      hasNext ? _audioFilePaths[_currentIndex + 1] : null;

  /// Initializes the queue with audio file paths
  void initialize(List<String> filePaths) {
    _audioFilePaths.clear();
    _audioFilePaths.addAll(filePaths);
    _currentIndex = 0;
    _preloadedNextPath = null;

    _queueChangedController.add(null);
    _indexController.add(_currentIndex);
  }

  /// Appends a single audio file path to the queue
  void addPath(String filePath) {
    _audioFilePaths.add(filePath);
    _queueChangedController.add(null);
  }

  /// Appends multiple audio file paths to the queue
  void addPaths(List<String> filePaths) {
    if (filePaths.isEmpty) return;
    _audioFilePaths.addAll(filePaths);
    _queueChangedController.add(null);
  }

  /// Advances to the next audio file in the queue
  /// Returns true if successfully advanced, false if at end
  bool next() {
    if (hasNext) {
      _currentIndex++;
      _indexController.add(_currentIndex);
      return true;
    }
    return false;
  }

  /// Goes back to the previous audio file in the queue
  /// Returns true if successfully moved back, false if at beginning
  bool previous() {
    if (hasPrevious) {
      _currentIndex--;
      _indexController.add(_currentIndex);
      return true;
    }
    return false;
  }

  /// Jumps to a specific index in the queue
  /// Returns true if successful, false if index is out of bounds
  bool jumpTo(int index) {
    if (index >= 0 && index < _audioFilePaths.length) {
      _currentIndex = index;
      _indexController.add(_currentIndex);
      return true;
    }
    return false;
  }

  /// Restarts the queue from the beginning
  void restart() {
    _currentIndex = 0;
    _preloadedNextPath = null;
    _indexController.add(_currentIndex);
  }

  /// Marks the next path as preloaded
  void markNextAsPreloaded() {
    _preloadedNextPath = nextPath;
  }

  /// Checks if the next path needs preloading
  bool shouldPreloadNext() {
    return hasNext && _preloadedNextPath != nextPath;
  }

  /// Clears the queue
  void clear() {
    _audioFilePaths.clear();
    _currentIndex = 0;
    _preloadedNextPath = null;
    _queueChangedController.add(null);
    _indexController.add(0);
  }

  /// Disposes the queue manager
  void dispose() {
    _indexController.close();
    _queueChangedController.close();
  }
}
