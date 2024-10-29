import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:study_aid/features/search/domain/repositories/search_repository.dart';

class SearchState {
  final bool isLoading;
  final List<dynamic> searchResults;
  final bool isSearchActive;

  SearchState({
    required this.isLoading,
    required this.searchResults,
    required this.isSearchActive,
  });

  factory SearchState.initial() {
    return SearchState(
      isLoading: false,
      searchResults: [],
      isSearchActive: false,
    );
  }

  SearchState copyWith({
    bool? isLoading,
    List<dynamic>? searchResults,
    bool? isSearchActive,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      searchResults: searchResults ?? this.searchResults,
      isSearchActive: isSearchActive ?? this.isSearchActive,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final SearchRepository searchRepository;

  SearchNotifier(this.searchRepository) : super(SearchState.initial());

  // Perform search with simulated loading
  Future<void> performSearch(String query) async {
    state =
        SearchState(isLoading: true, searchResults: [], isSearchActive: true);

    try {
      final results = await searchRepository.search(query);
      state = state.copyWith(searchResults: results);
    } catch (e) {
      Logger().e('Error during search: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Reset the search and go back to the default view
  void resetSearch() {
    state = SearchState.initial();
  }
}
