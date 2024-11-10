import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:study_aid/features/transcribe/data/datasources/transcription_remote_data_source.dart';
import 'package:study_aid/features/transcribe/data/repositories/transcription_repository_impl.dart';
import 'package:study_aid/features/transcribe/domain/entities/transcription.dart';
import 'package:study_aid/features/transcribe/domain/repositories/transcription_repository.dart';
import 'package:study_aid/features/transcribe/domain/usecases/start_transcription_usecase.dart';
import 'package:study_aid/features/transcribe/presentation/notifier/transcription_notifier.dart';

// 1. Create a provider for the HTTP client (can be reused in other places).
final httpClientProvider = Provider<http.Client>((ref) => http.Client());

// 2. Create a provider for the Remote Data Source.
final transcriptionRemoteDataSourceProvider =
    Provider<TranscriptionRemoteDataSource>(
  (ref) => TranscriptionRemoteDataSourceImpl(ref.read(httpClientProvider)),
);

// 3. Create a provider for the Repository.
final transcriptionRepositoryProvider = Provider<TranscriptionRepository>(
  (ref) => TranscriptionRepositoryImpl(
      ref.read(transcriptionRemoteDataSourceProvider)),
);

// 4. Create a provider for the Use Case.
final startTranscriptionUseCaseProvider = Provider<StartTranscriptionUseCase>(
  (ref) => StartTranscriptionUseCase(ref.read(transcriptionRepositoryProvider)),
);

final transcriptionProvider =
    StateNotifierProvider<TranscriptionNotifier, AsyncValue<Transcription>>(
  (ref) => TranscriptionNotifier(ref.read(startTranscriptionUseCaseProvider)),
);
