import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/utils/constants/constant_strings.dart';
import 'package:study_aid/core/utils/helpers/custome_types.dart';
import 'package:study_aid/core/utils/helpers/network_info.dart';
import 'package:study_aid/features/authentication/domain/repositories/user_repository.dart';
import 'package:study_aid/features/notes/data/datasources/note_local_datasource.dart';
import 'package:study_aid/features/notes/data/datasources/note_remote_datasource.dart';
import 'package:study_aid/features/notes/data/models/note.dart';
import 'package:study_aid/features/notes/domain/entities/note.dart';
import 'package:study_aid/features/notes/domain/repository/note_repository.dart';
import 'package:study_aid/features/topics/domain/repositories/topic_repository.dart';

class NoteRepositoryImpl extends NoteRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final TopicRepository topicRepository;
  final UserRepository userRepository;

  NoteRepositoryImpl(
      {required this.remoteDataSource,
      required this.localDataSource,
      required this.networkInfo,
      required this.topicRepository,
      required this.userRepository});

  @override
  Future<Either<Failure, Note>> createNote(
      Note note, String topicId, String userId) async {
    NoteModel noteModel = NoteModel.fromDomain(note);
    try {
      if (await networkInfo.isConnected) {
        final result = await remoteDataSource.createNote(noteModel);
        return result.fold((failure) => Left(failure), (N) async {
          await localDataSource.createNote(N);
          await topicRepository.updateNoteOfParent(topicId, N.id);
          await userRepository.updateRecentItems(
              userId, N.id, ConstantStrings.note);

          return Right(N);
        });
      } else {
        await localDataSource.createNote(noteModel);
        await topicRepository.updateNoteOfParent(topicId, noteModel.id);
        await userRepository.updateRecentItems(
            userId, noteModel.id, ConstantStrings.note);
      }

      return Right(noteModel);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaginatedObj<Note>>> fetchNotes(
      String topicId, int limit, int startAfter) async {
    try {
      final localTopic = await topicRepository.getTopic(topicId);

      return localTopic.fold((failure) => Left(failure), (items) async {
        if (items == null) {
          return Left(Failure('Note: Topic was not found'));
        } else if (items.notes.isEmpty) {
          return Right(
              PaginatedObj(items: [], hasMore: false, lastDocument: 0));
        } else {
          final noteRefs = List.from(items.notes);

          for (var id in noteRefs) {
            if (!localDataSource.noteExists(id)) {
              final topicOrFailure = await remoteDataSource.getNoteById(id);

              await topicOrFailure.fold(
                (failure) async {
                  // Handle the failure (e.g., log it or return a failure response)
                  Logger().e('Failed to fetch topic with ID $id: $failure');
                },
                (note) async {
                  // Save the fetched topic to the local data source
                  await localDataSource.createNote(note);
                },
              );
            }
          }

          final notes = await localDataSource.fetchPeginatedNotes(
            limit,
            noteRefs,
            startAfter,
          );

          return notes.fold(
              (failure) => Left(failure), (items) => Right(items));
        }
      });
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Note>> updateNote(
      Note note, String topicId, String userId) async {
    try {
      final now = DateTime.now();
      NoteModel noteModel = NoteModel.fromDomain(note);
      noteModel = noteModel.copyWith(
          updatedDate: now,
          localChangeTimestamp: now,
          syncStatus: ConstantStrings.pending);

      if (await networkInfo.isConnected) {
        final result = await remoteDataSource.updateNote(noteModel);

        return result.fold((failure) => Left(failure), (N) async {
          await localDataSource.updateNote(noteModel);

          await userRepository.updateRecentItems(
              userId, noteModel.id, ConstantStrings.note);
          return Right(N);
        });
      } else {
        await localDataSource.updateNote(noteModel);
      }
      await userRepository.updateRecentItems(
          userId, noteModel.id, ConstantStrings.note);
      return Right(noteModel);
    } on Exception catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncNotes() async {
    try {
      // Fetch all local notes
      var localNotes = await localDataSource.fetchAllNotes();

      for (var localNote in localNotes) {
        // Fetch the remote note if it exists
        final remoteNoteOrFailure =
            await remoteDataSource.getNoteById(localNote.id);

        await remoteNoteOrFailure.fold((failure) async {
          // If the note doesn't exist on the remote source, create it remotely
          final newNoteResult = await remoteDataSource.createNote(localNote);
          newNoteResult.fold((failure) => Left(Failure(failure.toString())),
              (newNote) async {
            // Replace the old local note with the newly created one
            await localDataSource.deleteNote(localNote.id);
            await localDataSource.createNote(newNote);
          });
        }, (remoteNote) async {
          // Compare updatedDate to decide whether to sync
          if (localNote.updatedDate.isAfter(remoteNote.updatedDate)) {
            // Local note is newer, update the remote note
            await remoteDataSource.updateNote(localNote);
            // Update the local copy to ensure sync status is correct
            await localDataSource.updateNote(
                localNote.copyWith(syncStatus: ConstantStrings.synced));
          } else if (remoteNote.updatedDate.isAfter(localNote.updatedDate)) {
            // Remote note is newer, update the local note
            await localDataSource.updateNote(
                remoteNote.copyWith(syncStatus: ConstantStrings.synced));
          }
        });
      }
      return const Right(null);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateNoteOfParent(
      String parentId, String noteId) async {
    try {
      final result = await topicRepository.getTopic(parentId);

      result.fold(
        (failure) => Left(failure),
        (topic) async {
          if (topic != null) {
            if (topic.notes.contains(noteId)) {
              topic.notes.remove(noteId);
            } else {
              topic.notes.add(noteId);
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

  @override
  Future<void> deleteNote(String parentId, String noteId, String userId) async {
    await localDataSource.deleteNote(noteId);

    if (await networkInfo.isConnected) {
      await remoteDataSource
          .deleteNote(noteId); //TODO:update parent or user references
      await updateNoteOfParent(parentId, noteId);
    }
    await userRepository.updateRecentItems(userId, noteId, ConstantStrings.note,
        isDelete: true);
  }

  @override
  Future<Either<Failure, Note?>> getNote(String noteId) async {
    try {
      // Check if the note exists locally
      final localNote = await localDataSource.getCachedNote(noteId);
      if (localNote != null) {
        return Right(localNote);
      }

      // Proceed to check remotely if the device is connected
      if (await networkInfo.isConnected) {
        // Fetch note remotely if not found locally
        final remoteNoteResult = await remoteDataSource.getNoteById(noteId);

        return remoteNoteResult.fold(
          (failure) => Left(failure),
          (remoteNote) async {
            // Cache the remote note locally
            await localDataSource.createNote(remoteNote);
            return Right(remoteNote);
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
  Future<Either<Failure, List<NoteModel>>> searchFromTags(String query) async {
    try {
      if (await networkInfo.isConnected) {
        final remoteNoteResult = await remoteDataSource.searchFromRemote(query);
        return remoteNoteResult.fold((failure) => Left(failure),
            (remoteNote) async {
          return Right(remoteNote);
        });
      } else {
        final localNoteResult = await localDataSource.searchFromLocal(query);
        return Right(localNoteResult);
      }
    } on Exception catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
