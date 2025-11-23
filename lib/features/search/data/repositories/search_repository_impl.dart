import 'package:logger/logger.dart';
import 'package:study_aid/features/notes/domain/repository/note_repository.dart';
import 'package:study_aid/features/search/domain/repositories/search_repository.dart';
import 'package:study_aid/features/voice_notes/domain/repository/audio_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final NoteRepository noteRepository;
  final AudioRecordingRepository audioRecordingRepository;

  SearchRepositoryImpl(
      {required this.noteRepository, required this.audioRecordingRepository});

  @override
  Future<List<dynamic>> search(String query, String userId) async {
    List<dynamic> combinedResults = [];

    try {
      // Fetch notes from the note repository using tags
      final noteResult = await noteRepository.search(query, userId);
      noteResult.fold(
        (failure) {
          Logger().e('Error searching notes: $failure');
        },
        (notes) {
          // If successful, add notes to combined results
          combinedResults.addAll(notes);
        },
      );

      // Fetch audio recordings from the audio repository using tags
      final audioResult = await audioRecordingRepository.search(query, userId);
      audioResult.fold(
        (failure) {
          Logger().e('Error searching audio: $failure');
        },
        (audios) {
          // If successful, add audios to combined results
          combinedResults.addAll(audios);
        },
      );
    } on Exception catch (e) {
      Logger().e('Error fetching data from Firebase: $e');
    }

    return combinedResults; // Return the combined results after processing
  }
}
