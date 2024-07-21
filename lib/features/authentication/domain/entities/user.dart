class User {
  final String id;
  final String username;
  final String email;
  final DateTime createdDate;
  final DateTime updatedDate;
  final List<String> createdTopics;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.createdDate,
    required this.updatedDate,
    required this.createdTopics,
  });
}
