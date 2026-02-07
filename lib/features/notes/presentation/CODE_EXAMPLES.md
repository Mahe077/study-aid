# OpenAI TTS Implementation - Code Example Snippets

This document provides concrete code examples for the TTS implementation.

## Text Chunking Example

```dart
final chunker = TextChunker();
final chunks = chunker.chunkText(
  title: "Understanding Quantum Physics",
  content: """
Quantum physics is a fundamental theory in physics that provides
a description of the physical properties of nature at the scale
of atoms and subatomic particles.

The theory is based on several key principles including wave-particle
duality, quantum entanglement, and the uncertainty principle.
""",
);

// Result: 2 chunks (if content is large enough)
// Chunk 0: "Understanding Quantum Physics.\n\nQuantum physics is..."
// Chunk 1: "The theory is based on..."
```

## OpenAI API Call Example

```dart
final client = OpenAITtsClient(apiKey: 'your-api-key');

try {
  final audioPath = await client.generateSpeech(
    text: "Understanding Quantum Physics. Quantum physics is a fundamental theory...",
    voice: TtsVoice.alloy,
    speed: 1.0,
    noteId: 'note-123',
    chunkIndex: 0,
  );

  print('Audio saved to: $audioPath');
  // Example: /Documents/tts_cache/note-123_0_alloy_1.0.mp3
} catch (e) {
  print('Error: $e');
}
```

## Complete TTS Service Usage

```dart
// In your widget or provider
final ttsService = TtsService();

// Initialize for a note
await ttsService.initialize(
  note,
  TtsConfig(
    voice: TtsVoice.nova,
    speed: 1.25,
    continuousPlay: true,
  ),
);

// Listen to state changes
ttsService.stateStream.listen((state) {
  print('Status: ${state.status}');
  print('Position: ${state.currentPosition}');
  print('Chunk: ${state.currentChunkIndex}/${state.totalChunks}');
});

// Control playback
await ttsService.play();
await ttsService.pause();
await ttsService.seekForward(Duration(seconds: 15));
await ttsService.changeSpeed(1.5);

// Cleanup
await ttsService.dispose();
```

## Riverpod Provider Usage

```dart
// In your widget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(ttsPlaybackProvider);
    final notifier = ref.read(ttsPlaybackProvider.notifier);

    return Column(
      children: [
        Text('Status: ${playbackState.status}'),
        Text('Progress: ${playbackState.currentPosition}/${playbackState.totalDuration}'),

        ElevatedButton(
          onPressed: () => notifier.togglePlayPause(),
          child: Text(playbackState.isPlaying ? 'Pause' : 'Play'),
        ),

        ElevatedButton(
          onPressed: () => notifier.changeSpeed(1.5),
          child: Text('1.5x Speed'),
        ),
      ],
    );
  }
}
```

## Testing the Chunking Algorithm

```dart
void main() {
  final chunker = TextChunker();

  // Test 1: Small note (single chunk)
  final smallChunks = chunker.chunkText(
    title: "Quick Note",
    content: "This is a short note with minimal content.",
  );
  assert(smallChunks.length == 1);
  assert(smallChunks[0].isFirst == true);

  // Test 2: Large note (multiple chunks)
  final largeContent = List.generate(100, (i) =>
    "This is paragraph $i with some meaningful content that discusses various topics."
  ).join('\n\n');

  final largeChunks = chunker.chunkText(
    title: "Comprehensive Study Guide",
    content: largeContent,
  );

  assert(largeChunks.length > 1);
  assert(largeChunks[0].isFirst == true);
  assert(largeChunks[1].isFirst == false);

  // Test 3: Title normalization
  final specialTitleChunks = chunker.chunkText(
    title: "Math: ∑ & Δ - Special @#\$ Chars!!!",
    content: "Content here.",
  );

  final formattedText = specialTitleChunks[0].getFormattedText(
    chunker._normalizeTitle("Math: ∑ & Δ - Special @#\$ Chars!!!")
  );
  // Should normalize to something like: "Math:  & Δ - Special  Chars."

  print('All tests passed!');
}
```

## Cache Management Example

```dart
final cacheService = AudioCacheService();

// Check cache before generating
final cachedPath = await cacheService.getCachedAudio(
  noteId: 'note-123',
  chunkIndex: 0,
  voice: 'alloy',
  speed: 1.0,
);

if (cachedPath != null) {
  print('Using cached audio: $cachedPath');
} else {
  print('Generating new audio...');
  // Generate and it will be automatically cached
}

// Clear specific note cache (e.g., when voice/speed changes)
await cacheService.clearNoteCache('note-123');

// Get cache statistics
final cacheSize = await cacheService.getCacheSize();
print('Cache size: ${(cacheSize / 1024 / 1024).toStringAsFixed(2)} MB');

// Evict old cache if needed
await cacheService.evictOldCacheIfNeeded();
```

## Error Handling Example

```dart
try {
  await ttsService.initialize(note, config);
} on TtsApiException catch (e) {
  if (e.statusCode == 401) {
    print('Authentication error: Invalid API key');
  } else if (e.statusCode == 429) {
    print('Rate limit exceeded');
  } else {
    print('API error: ${e.message}');
  }
} catch (e) {
  print('Unexpected error: $e');
}
```

## Environment Setup

### Option 1: Using --dart-define

```bash
flutter run --dart-define=OPENAI_API_KEY=sk-your-api-key-here
```

### Option 2: Using .env file (with flutter_dotenv)

```env
# .env file
OPENAI_API_KEY=sk-your-api-key-here
```

```dart
// Load in main.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

  // Pass to OpenAITtsClient
  final client = OpenAITtsClient(apiKey: apiKey);

  runApp(MyApp());
}
```

### Option 3: Using Firebase Remote Config

```dart
final remoteConfig = FirebaseRemoteConfig.instance;
await remoteConfig.setConfigSettings(RemoteConfigSettings(
  fetchTimeout: const Duration(minutes: 1),
  minimumFetchInterval: const Duration(hours: 1),
));

await remoteConfig.fetchAndActivate();
final apiKey = remoteConfig.getString('openai_api_key');

final client = OpenAITtsClient(apiKey: apiKey);
```
