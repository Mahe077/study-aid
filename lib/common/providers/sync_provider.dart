import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_aid/features/authentication/domain/usecases/load_user.dart';
import 'package:study_aid/features/authentication/presentation/providers/user_providers.dart';
import 'package:study_aid/features/notes/domain/usecases/note.dart';
import 'package:study_aid/features/notes/presentation/providers/note_provider.dart';
import 'package:study_aid/features/topics/domain/usecases/topic.dart';
import 'package:study_aid/features/topics/presentation/providers/topic_provider.dart';
import 'package:study_aid/features/voice_notes/domain/usecases/audio.dart';
import 'package:study_aid/features/voice_notes/presentation/providers/audio_provider.dart';
import 'package:study_aid/features/files/domain/usecases/file_usecases.dart';
import 'package:study_aid/features/files/presentation/providers/files_providers.dart';

final syncProvider = Provider((ref) => SyncProvider(
      ref.read(syncTopicsUseCaseProvider),
      ref.read(syncUserUseCaseProvider),
      ref.read(syncNotesUseCaseProvider),
      ref.read(syncAudioRecodingsUseCaseProvider),
      ref.read(syncFilesUseCaseProvider),
    ));

class SyncProvider {
  final SyncTopicsUseCase syncTopics;
  final SyncUserUseCase syncUserData;
  final SyncNotesUseCase syncNotes;
  final SyncAudioRecordingsUseCase syncAudio;
  final SyncFilesUseCase syncFiles;

  SyncProvider(
    this.syncTopics,
    this.syncUserData,
    this.syncNotes,
    this.syncAudio,
    this.syncFiles,
  );

  Future<void> syncAll(String userId) async {
    await syncTopics.call(userId);
    await syncUserData.call(userId);
    await syncNotes.call(userId);
    await syncAudio.call(userId);
    await syncFiles.call(userId);
  }
}
