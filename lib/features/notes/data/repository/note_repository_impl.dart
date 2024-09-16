import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/core/error/failures.dart';
import 'package:study_aid/core/utils/constants/constant_strings.dart';
import 'package:study_aid/core/utils/helpers/custome_types.dart';
import 'package:study_aid/core/utils/helpers/network_info.dart';
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

  NoteRepositoryImpl(
      {required this.remoteDataSource,
      required this.localDataSource,
      required this.networkInfo,
      required this.topicRepository});

  @override
  Future<Either<Failure, Note>> createNote(Note note, String topicId) async {
    NoteModel noteModel = NoteModel.fromDomain(note);

    if (await networkInfo.isConnected) {
      final result = await remoteDataSource.createNote(noteModel);
      await localDataSource.createNote(noteModel);
      return result.fold((failure) => Left(failure), (note) async {
        await topicRepository.updateNoteOfParent(topicId, note.id);
        return Right(note);
      });
    } else {
      await localDataSource.createNote(noteModel);
      await topicRepository.updateNoteOfParent(topicId, noteModel.id);
    }
    return Right(noteModel);
  }

  @override
  Future<Either<Failure, PaginatedObj<Note>>> fetchNotes(
      String topicId, int limit, int startAfter) async {
    try {
      final localTopic = await topicRepository.getTopic(topicId);

      return localTopic.fold((failure) => Left(failure), (items) async {
        if (items == null || items.notes.isEmpty) {
          return Left(
              Failure('Topic was not found or has no created sub topics'));
        } else {
          final noteRefs = List.from(items.notes);

          for (var id in noteRefs) {
            if (!localDataSource.noteExists(id)) {
              final topicOrFailure = await remoteDataSource.getNoteById(id);

              topicOrFailure.fold(
                (failure) {
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
  Future<Either<Failure, Note>> updateNote(Note note, String topicId) async {
    try {
      final now = DateTime.now();
      NoteModel noteModel = NoteModel.fromDomain(note);
      noteModel = noteModel.copyWith(
          updatedDate: now,
          localChangeTimestamp: now,
          syncStatus: ConstantStrings.pending);

      if (await networkInfo.isConnected) {
        final result = await remoteDataSource.updateNote(noteModel);

        await localDataSource.updateNote(noteModel);

        return result.fold((failure) => Left(failure), (note) async {
          return Right(note);
        });
      } else {
        await localDataSource.updateNote(noteModel);
      }
      return Right(noteModel);
    } on Exception catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> syncNotes() async {
    try {
      var localTopics = await localDataSource.fetchAllNotes();
      localTopics = localTopics
          .where((note) => note.syncStatus == ConstantStrings.pending)
          .toList();

      for (var note in localTopics) {
        note = note.copyWith(syncStatus: ConstantStrings.synced);
        if (await remoteDataSource.noteExists(note.id)) {
          await remoteDataSource.updateNote(note);
          await localDataSource.updateNote(note);
        } else {
          final newTopicResult = await remoteDataSource.createNote(note);
          newTopicResult.fold((failure) => Left(Failure(failure.toString())),
              (newTopic) async {
            await localDataSource.deleteNote(note.id);
            await localDataSource.createNote(newTopic);
          });
        }
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
            topic.notes.add(noteId);
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
  Future<void> deleteNote(String noteId) async {
    await localDataSource.deleteNote(noteId);

    if (await networkInfo.isConnected) {
      await remoteDataSource
          .deleteNote(noteId); //TODO:update parent or user references
    }
  }
}
