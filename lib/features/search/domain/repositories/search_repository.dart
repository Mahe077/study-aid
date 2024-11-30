abstract class SearchRepository {
  Future<List<dynamic>> search(String query, String userId);
}
