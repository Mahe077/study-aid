import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:study_aid/core/utils/helpers/network_info.dart';
import 'package:study_aid/features/authentication/presentation/providers/user_providers.dart';
import 'package:study_aid/features/topics/presentation/providers/topic_provider.dart';
import 'package:study_aid/features/transcribe/domain/usecases/start_transcription_usecase.dart';
import 'package:study_aid/features/transcribe/presentation/provider/transcription_provider.dart';
import 'package:study_aid/features/voice_notes/data/datasources/audio_local_datasource.dart';
import 'package:study_aid/features/voice_notes/data/datasources/audio_remote_datasource.dart';
import 'package:study_aid/features/voice_notes/data/models/audio_recording.dart';
import 'package:study_aid/features/voice_notes/data/repository/audio_repository_impl.dart';
import 'package:study_aid/features/voice_notes/domain/repository/audio_repository.dart';
import 'package:study_aid/features/voice_notes/domain/usecases/audio.dart';
import 'package:study_aid/features/voice_notes/presentation/notifiers/audio_notifire.dart';

// Data source providers
final remoteDataSourceProvider = Provider<RemoteDataSource>((ref) {
  final transcribeAudioUseCase = ref.read(transcribeAudioUseCaseProvider);
  return RemoteDataSourceImpl(transcribeAudioUseCase);
});
final localDataSourceProvider = Provider<LocalDataSource>(
    (ref) => LocalDataSourceImpl(Hive.box<AudioRecordingModel>('audioBox')));
final networkInfoProvider = Provider<NetworkInfo>((ref) => NetworkInfo());

// Repository provider
final audioRepositoryProvider = Provider<AudioRecordingRepository>((ref) {
  final remoteDataSource = ref.read(remoteDataSourceProvider);
  final localDataSource = ref.read(localDataSourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  final topicRepository = ref.read(topicRepositoryProvider);
  final userRepository = ref.read(userRepositoryProvider);
  return AudioRecordingRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      networkInfo: networkInfo,
      topicRepository: topicRepository,
      userRepository: userRepository);
});

// Use case providers
final createAudioRecodingProvider =
    Provider((ref) => CreateAudioRecording(ref.read(audioRepositoryProvider)));
final updateAudioRecodingProvider =
    Provider((ref) => UpdateAudioRecording(ref.read(audioRepositoryProvider)));
final deleteAudioRecodingProvider =
    Provider((ref) => DeleteAudioRecording(ref.read(audioRepositoryProvider)));
final transcribeAudioUseCaseProvider =
    Provider<StartTranscriptionUseCase>((ref) {
  final transcriptionRepository = ref.read(transcriptionRepositoryProvider);
  return StartTranscriptionUseCase(transcriptionRepository);
});
// final fetchAllTopicsProvider =
//     Provider((ref) => FetchAllTopics(ref.read(audioRepositoryProvider)));

final audioProvider = StateNotifierProvider.autoDispose
    .family<AudioNotifier, AsyncValue<AudioState>, String>((ref, topicId) {
  final repository = ref.read(audioRepositoryProvider);
  return AudioNotifier(repository, topicId, ref);
});

final syncAudioRecodingsUseCaseProvider = Provider(
    (ref) => SyncAudioRecordingsUseCase(ref.read(audioRepositoryProvider)));
