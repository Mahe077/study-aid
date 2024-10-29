import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:study_aid/core/utils/helpers/network_info.dart';
import 'package:study_aid/features/authentication/presentation/providers/user_providers.dart';
import 'package:study_aid/features/notes/data/datasources/note_local_datasource.dart';
import 'package:study_aid/features/notes/data/datasources/note_remote_datasource.dart';
import 'package:study_aid/features/notes/data/models/note.dart';
import 'package:study_aid/features/notes/data/repository/note_repository_impl.dart';
import 'package:study_aid/features/notes/domain/repository/note_repository.dart';
import 'package:study_aid/features/notes/domain/usecases/note.dart';
import 'package:study_aid/features/notes/presentation/notifiers/note_notifire.dart';
import 'package:study_aid/features/topics/presentation/providers/topic_provider.dart';

// Data source providers
final remoteDataSourceProvider =
    Provider<RemoteDataSource>((ref) => RemoteDataSourceImpl());
final localDataSourceProvider = Provider<LocalDataSource>(
    (ref) => LocalDataSourceImpl(Hive.box<NoteModel>('noteBox')));
final networkInfoProvider = Provider<NetworkInfo>((ref) => NetworkInfo());

// Repository provider
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  final remoteDataSource = ref.read(remoteDataSourceProvider);
  final localDataSource = ref.read(localDataSourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  final topicRepository = ref.read(topicRepositoryProvider);
  final userRepository = ref.read(userRepositoryProvider);
  return NoteRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      networkInfo: networkInfo,
      topicRepository: topicRepository,
      userRepository: userRepository);
});

// Use case providers
final createNoteProvider =
    Provider((ref) => CreateNote(ref.read(noteRepositoryProvider)));
final updateNoteProvider =
    Provider((ref) => UpdateNote(ref.read(noteRepositoryProvider)));
final deleteNoteProvider =
    Provider((ref) => DeleteNote(ref.read(noteRepositoryProvider)));
// final fetchAllTopicsProvider =
//     Provider((ref) => FetchAllTopics(ref.read(noteRepositoryProvider)));

final notesProvider = StateNotifierProvider.autoDispose
    .family<NotesNotifier, AsyncValue<NotesState>, String>((ref, topicId) {
  final repository = ref.read(noteRepositoryProvider);
  return NotesNotifier(repository, topicId, ref);
});

final syncNotesUseCaseProvider =
    Provider((ref) => SyncNotesUseCase(ref.read(noteRepositoryProvider)));
