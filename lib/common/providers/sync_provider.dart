import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_aid/features/authentication/domain/usecases/load_user.dart';
import 'package:study_aid/features/authentication/presentation/providers/user_providers.dart';
import 'package:study_aid/features/topics/domain/usecases/topic.dart';
import 'package:study_aid/features/topics/presentation/providers/topic_provider.dart';

final syncProvider = Provider((ref) => SyncProvider(
      ref.read(syncTopicsUseCaseProvider),
      ref.read(syncUserUseCaseProvider),
      // ref.read(syncNotesUseCaseProvider),
      // ref.read(syncAudioUseCaseProvider),
    ));

class SyncProvider {
  final SyncTopicsUseCase syncTopics;
  final SyncUserUseCase syncUserData;
  // final SyncNotesUseCase syncNotes;
  // final SyncAudioUseCase syncAudio;

  SyncProvider(
    this.syncTopics,
    this.syncUserData, //this.syncNotes, this.syncAudio
  );

  Future<void> syncAll(String userId) async {
    await syncTopics.call();
    await syncUserData.call(userId);
    // await syncNotes.execute();
    // await syncAudio.execute();
  }
}
