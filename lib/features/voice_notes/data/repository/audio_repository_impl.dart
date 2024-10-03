import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/utils/constants/constant_strings.dart';
import 'package:study_aid/core/utils/helpers/custome_types.dart';
import 'package:study_aid/core/utils/helpers/network_info.dart';
import 'package:study_aid/features/topics/domain/repositories/topic_repository.dart';
import 'package:study_aid/features/voice_notes/data/datasources/audio_remote_datasource.dart';
import 'package:study_aid/features/voice_notes/data/datasources/audio_local_datasource.dart';
import 'package:study_aid/features/voice_notes/data/models/audio_recording.dart';
import 'package:study_aid/features/voice_notes/domain/entities/audio_recording.dart';
import 'package:study_aid/features/voice_notes/domain/repository/audio_repository.dart';

class AudioRecordingRepositoryImpl extends AudioRecordingRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final TopicRepository topicRepository;

  AudioRecordingRepositoryImpl(
      {required this.remoteDataSource,
      required this.localDataSource,
      required this.networkInfo,
      required this.topicRepository});

  @override
  Future<Either<Failure, AudioRecording>> createAudioRecording(
      AudioRecording audio, String topicId) async {
    AudioRecordingModel audioRecording = AudioRecordingModel.fromDomain(audio);

    if (await networkInfo.isConnected) {
      final result =
          await remoteDataSource.createAudioRecording(audioRecording);

      return result.fold((failure) => Left(failure), (audio) async {
        await localDataSource.createAudioRecording(audio);
        await topicRepository.updateAudioOfParent(topicId, audio.id);
        return Right(audio);
      });
    } else {
      await localDataSource.createAudioRecording(audioRecording);
      await topicRepository.updateAudioOfParent(topicId, audioRecording.id);
    }
    return Right(audioRecording);
  }

  @override
  Future<Either<Failure, PaginatedObj<AudioRecording>>> fetchAudioRecordings(
      String topicId, int limit, int startAfter) async {
    try {
      final localTopic = await topicRepository.getTopic(topicId);

      return localTopic.fold((failure) => Left(failure), (items) async {
        if (items == null) {
          return Left(Failure('Topic was not found'));
        } else if (items.audioRecordings.isEmpty) {
          return Right(
              PaginatedObj(items: [], hasMore: false, lastDocument: 0));
        } else {
          final audioRefs = List.from(items.audioRecordings);

          for (var id in audioRefs) {
            if (!localDataSource.audioExists(id)) {
              final topicOrFailure =
                  await remoteDataSource.getAudioRecordingById(id);

              topicOrFailure.fold(
                (failure) {
                  // Handle the failure (e.g., log it or return a failure response)
                  Logger().e('Failed to fetch topic with ID $id: $failure');
                },
                (audio) async {
                  // Save the fetched topic to the local data source
                  await localDataSource.createAudioRecording(audio);
                },
              );
            }
          }

          final audioRecordings =
              await localDataSource.fetchPeginatedAudioRecordings(
            limit,
            audioRefs,
            startAfter,
          );

          return audioRecordings.fold(
              (failure) => Left(failure), (items) => Right(items));
        }
      });
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AudioRecording>> updateAudioRecording(
      AudioRecording audio, String topicId) async {
    try {
      final now = DateTime.now();
      AudioRecordingModel audioRecording =
          AudioRecordingModel.fromDomain(audio);
      audioRecording = audioRecording.copyWith(
          updatedDate: now,
          localChangeTimestamp: now,
          syncStatus: ConstantStrings.pending);

      if (await networkInfo.isConnected) {
        final result =
            await remoteDataSource.updateAudioRecording(audioRecording);

        await localDataSource.updateAudioRecording(audioRecording);

        return result.fold((failure) => Left(failure), (audio) async {
          return Right(audio);
        });
      } else {
        await localDataSource.updateAudioRecording(audioRecording);
      }
      return Right(audioRecording);
    } on Exception catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncAudioRecordings() async {
    try {
      var localTopics = await localDataSource.fetchAllAudioRecordings();
      localTopics = localTopics
          .where((audio) => audio.syncStatus == ConstantStrings.pending)
          .toList();

      for (var audio in localTopics) {
        audio = audio.copyWith(syncStatus: ConstantStrings.synced);
        if (await remoteDataSource.audioExists(audio.id)) {
          await remoteDataSource.updateAudioRecording(audio);
          await localDataSource.updateAudioRecording(audio);
        } else {
          final newTopicResult =
              await remoteDataSource.createAudioRecording(audio);
          newTopicResult.fold((failure) => Left(Failure(failure.toString())),
              (newTopic) async {
            await localDataSource.deleteAudioRecording(audio.id);
            await localDataSource.createAudioRecording(newTopic);
          });
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateAudioRecordingOfParent(
      String parentId, String audioId) async {
    try {
      final result = await topicRepository.getTopic(parentId);

      result.fold(
        (failure) => Left(failure),
        (topic) async {
          if (topic != null) {
            topic.audioRecordings.add(audioId);
            await topicRepository.updateTopic(topic);
          }
        },
      );

      return const Right(null);
    } on Exception catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<void> deleteAudioRecording(String audioId) async {
    await localDataSource.deleteAudioRecording(audioId);

    if (await networkInfo.isConnected) {
      await remoteDataSource.deleteAudioRecording(
          audioId); //TODO:update parent or user references
    }
  }
}
