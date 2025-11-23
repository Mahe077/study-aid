import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/utils/helpers/custome_types.dart';
import 'package:study_aid/features/voice_notes/data/models/audio_recording.dart';

abstract class LocalDataSource {
  Future<void> createAudioRecording(AudioRecordingModel audio);
  Future<void> updateAudioRecording(AudioRecordingModel audio);
  Future<void> deleteAudioRecording(String audioId);
  Future<Either<Failure, PaginatedObj<AudioRecordingModel>>>
      fetchPeginatedAudioRecordings(
          int limit, List<dynamic> audioRefs, int startAfter, String sortBy);
  Future<AudioRecordingModel?> getCachedAudioRecording(String audioId);
  Future<List<AudioRecordingModel>> fetchAllAudioRecordings();
  bool audioExists(String audioId);
  Future<List<AudioRecordingModel>> searchFromLocal(String query);
}

class LocalDataSourceImpl extends LocalDataSource {
  final Box<AudioRecordingModel> _audioBox;

  LocalDataSourceImpl(this._audioBox);

  @override
  Future<Either<Failure, PaginatedObj<AudioRecordingModel>>>
      fetchPeginatedAudioRecordings(int limit, List<dynamic> audioRefs,
          int startAfter, String sortBy) async {
    try {
      int startIndex = startAfter;
      int endIndex = startIndex + limit;

      printAudioRecordingBoxContents();

      List<Future<AudioRecordingModel?>> futureAudios =
          audioRefs.map((audioId) {
        return getCachedAudioRecording(audioId);
      }).toList();

      List<AudioRecordingModel?> audios = await Future.wait(futureAudios);

      List<AudioRecordingModel> nonNullAudios = audios
          .where((audio) => audio != null)
          .cast<AudioRecordingModel>()
          .toList();

      final directory = await getApplicationDocumentsDirectory();
      // Update localPath for each audio
      nonNullAudios = nonNullAudios.map((audio) {
        final filename = audio.localpath.split('/').last;
        return audio.copyWith(localpath: '${directory.path}/$filename');
      }).toList();

      if (sortBy == 'updatedDate') {
        nonNullAudios.sort(
            (a, b) => b.updatedDate.compareTo(a.updatedDate)); // Descending
      } else if (sortBy == 'createdDate') {
        nonNullAudios.sort(
            (a, b) => b.createdDate.compareTo(a.createdDate)); // Descending
      } else if (sortBy == 'title') {
        nonNullAudios.sort((a, b) => a.titleLowerCase
            .compareTo(b.titleLowerCase)); // Ascending alphabetical order
      }

      final hasmore = audios.length > endIndex ? true : false;

      return Right(PaginatedObj(
          items: hasmore
              ? nonNullAudios.sublist(startIndex, endIndex)
              : nonNullAudios.sublist(startIndex),
          hasMore: hasmore,
          lastDocument: hasmore ? endIndex : audios.length));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<AudioRecordingModel?> getCachedAudioRecording(String audioId) async {
    try {
      return _audioBox.get(audioId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<AudioRecordingModel>> fetchAllAudioRecordings() async {
    return _audioBox.values.toList();
  }

  @override
  Future<void> createAudioRecording(AudioRecordingModel audio) async {
    try {
      await _audioBox.put(audio.id, audio);
      printAudioRecordingBoxContents();
    } catch (e) {
      Logger().e(e);
    }
  }

  @override
  Future<void> deleteAudioRecording(String audioId) async {
    await _audioBox.delete(audioId);
  }

  @override
  Future<void> updateAudioRecording(AudioRecordingModel audio) async {
    await _audioBox.put(audio.id, audio);
  }

  @override
  bool audioExists(String audioId) {
    return _audioBox.containsKey(audioId);
  }

  void printAudioRecordingBoxContents() {
    // Assuming _topicBox is your Hive box
    var allKeys = _audioBox.keys;
    Logger().d('All keys in AudioBox: $allKeys');

    var allAudio = _audioBox.values.toList();
    if (kDebugMode) {
      print('All items in AudioBox:');
    }
    for (var i = 0; i < allAudio.length; i++) {
      if (kDebugMode) {
        print('Item $i: ${allAudio[i]}');
      }
    }
  }

  @override
  Future<List<AudioRecordingModel>> searchFromLocal(String query) async {
    final lowerCaseQuery = query.toLowerCase();

    // Fetch all local notes
    final audios = _audioBox.values
        .where((audio) =>
            audio.tags
                .any((tag) => tag.toLowerCase().contains(lowerCaseQuery)) ||
            (audio.titleLowerCase.contains(lowerCaseQuery)))
        .toList();

    return audios;
  }
}
