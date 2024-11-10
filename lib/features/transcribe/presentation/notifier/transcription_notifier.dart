import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_aid/features/transcribe/domain/entities/transcription.dart';
import 'package:study_aid/features/transcribe/domain/usecases/start_transcription_usecase.dart';

class TranscriptionNotifier extends StateNotifier<AsyncValue<Transcription>> {
  final StartTranscriptionUseCase startTranscriptionUseCase;

  TranscriptionNotifier(this.startTranscriptionUseCase)
      : super(const AsyncValue.loading());

  Future<void> startTranscription(String filePath) async {
    try {
      final transcription = await startTranscriptionUseCase(filePath);
      state = AsyncValue.data(transcription);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
