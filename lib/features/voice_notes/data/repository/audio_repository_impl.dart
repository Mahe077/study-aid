import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/utils/constants/constant_strings.dart';
import 'package:study_aid/core/utils/helpers/custome_types.dart';
import 'package:study_aid/core/utils/helpers/network_info.dart';
import 'package:study_aid/features/authentication/domain/repositories/user_repository.dart';
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
  final UserRepository userRepository;

  AudioRecordingRepositoryImpl(
      {required this.remoteDataSource,
      required this.localDataSource,
      required this.networkInfo,
      required this.topicRepository,
      required this.userRepository});

  @override
  Future<Either<Failure, AudioRecording>> createAudioRecording(
      AudioRecording audio, String topicId, String userId) async {

    // Convert AudioRecording domain entity to AudioRecordingModel
    AudioRecordingModel audioRecording = AudioRecordingModel.fromDomain(audio);

    try {
      if (await networkInfo.isConnected) {
        // Upload audio recording to remote
        final result = await remoteDataSource.createAudioRecording(audioRecording);

        return await result.fold(
              (failure) => Left(failure),
              (remoteAudio) async {
            // Store remote audio locally and update references
            await localDataSource.createAudioRecording(remoteAudio);
            await topicRepository.updateAudioOfParent(topicId, remoteAudio.id);
            await userRepository.updateRecentItems(
                userId, remoteAudio.id, ConstantStrings.audio);
            return Right(remoteAudio.toDomain());
          },
        );
      } else {
        // Store audio locally when offline
        await localDataSource.createAudioRecording(audioRecording);
        await topicRepository.updateAudioOfParent(topicId, audioRecording.id);
        await userRepository.updateRecentItems(
            userId, audioRecording.id, ConstantStrings.audio);
        return Right(audioRecording.toDomain());
      }
    } catch (e) {
      return Left(Failure('AudioRecordingRepositoryImpl:: Error in creating audio recording: $e'));
    }
  }


  @override
  Future<Either<Failure, PaginatedObj<AudioRecording>>> fetchAudioRecordings(
      String topicId, int limit, int startAfter) async {
    try {
      final localTopic = await topicRepository.getTopic(topicId);

      return localTopic.fold((failure) => Left(failure), (items) async {
        if (items == null) {
          return Left(Failure('Audio: Topic was not found'));
        } else if (items.audioRecordings.isEmpty) {
          return Right(
              PaginatedObj(items: [], hasMore: false, lastDocument: 0));
        } else {
          final audioRefs = List.from(items.audioRecordings);

          for (var id in audioRefs) {
            if (!localDataSource.audioExists(id)) {
              final topicOrFailure =
                  await remoteDataSource.getAudioRecordingById(id);

              await topicOrFailure.fold(
                (failure) async {
                  // Handle the failure (e.g., log it or return a failure response)
                  Logger().e('Failed to fetch topic with ID $id: $failure');
                },
                (audio) async {
                  // Step 1: Download the audio file from the remote source
                  final file = await remoteDataSource.downloadFile(
                      audio.url, audio.localpath);
                  // Save the fetched topic to the local data source
                  if (file != null) {
                    await localDataSource.createAudioRecording(audio);
                  } else {
                    // If the file download fails, raise an error
                    return Left(Failure("Failed to download audio file."));
                  }
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
      AudioRecording audio, String topicId, String userId) async {
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
      await userRepository.updateRecentItems(
          userId, audio.id, ConstantStrings.audio);
      return Right(audioRecording);
    } on Exception catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncAudioRecordings() async {
    try {
      // Fetch all local audio recordings
      var localAudioRecordings =
          await localDataSource.fetchAllAudioRecordings();

      for (var localAudio in localAudioRecordings) {
        // Fetch the remote audio recording if it exists
        final remoteAudioOrFailure =
            await remoteDataSource.getAudioRecordingById(localAudio.id);

        await remoteAudioOrFailure.fold((failure) async {
          // If the audio recording doesn't exist on the remote source, create it remotely
          final newAudioResult =
              await remoteDataSource.createAudioRecording(localAudio);
          newAudioResult.fold((failure) => Left(Failure(failure.toString())),
              (newAudio) async {
            // Replace the old local audio with the newly created one
            await localDataSource.deleteAudioRecording(localAudio.id);
            await localDataSource.createAudioRecording(newAudio);
          });
        }, (remoteAudio) async {
          // Compare updatedDate to decide whether to sync
          if (localAudio.updatedDate.isAfter(remoteAudio.updatedDate)) {
            // Local audio is newer, update the remote audio
            await remoteDataSource.updateAudioRecording(localAudio);
            // Update the local copy to ensure sync status is correct
            await localDataSource.updateAudioRecording(
                localAudio.copyWith(syncStatus: ConstantStrings.synced));
          } else if (remoteAudio.updatedDate.isAfter(localAudio.updatedDate)) {
            // Remote audio is newer, update the local audio
            await localDataSource.updateAudioRecording(
                remoteAudio.copyWith(syncStatus: ConstantStrings.synced));
          }
        });
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
  Future<void> deleteAudioRecording(
      String parentId, String audioId, String userId) async {
    try {
      await localDataSource.deleteAudioRecording(audioId);

      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteAudioRecording(audioId);
        await updateAudioOfParent(parentId, audioId);
      }
      await userRepository.updateRecentItems(
          userId, audioId, ConstantStrings.audio,
          isDelete: true);
    } catch (e) {
      Logger().d("deleteAudioRecording:: Error Deleting file: $e");
    }
  }

  @override
  Future<File?> downloadFile(String url, String filePath) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        return file;
      }
    } catch (e) {
      Logger().d("Error downloading file: $e");
    }
    return null;
  }

  @override
  Future<Either<Failure, AudioRecording?>> getAudio(String audioId) async {
    try {
      // Check if the audioRecording exists locally
      final localAudioRecording =
          await localDataSource.getCachedAudioRecording(audioId);
      if (localAudioRecording != null) {
        return Right(localAudioRecording);
      }

      // Proceed to check remotely if the device is connected
      if (await networkInfo.isConnected) {
        // Fetch audioRecording remotely if not found locally
        final remoteAudioRecordingResult =
            await remoteDataSource.getAudioRecordingById(audioId);

        return remoteAudioRecordingResult.fold(
          (failure) => Left(failure),
          (remoteAudioRecording) async {
            // Cache the remote audioRecording locally
            await localDataSource.createAudioRecording(remoteAudioRecording);
            return Right(remoteAudioRecording);
          },
        );
      } else {
        // If not connected and no local data, return null
        return Right(null);
      }
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateAudioOfParent(
      String parentId, String audioId) async {
    try {
      final result = await topicRepository.getTopic(parentId);

      result.fold(
        (failure) => Left(failure),
        (topic) async {
          if (topic != null) {
            if (topic.audioRecordings.contains(audioId)) {
              topic.audioRecordings.remove(audioId);
            } else {
              topic.audioRecordings.add(audioId);
            }
            await topicRepository.updateTopic(topic);
          }
        },
      );

      return const Right(null);
    } on Exception catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
