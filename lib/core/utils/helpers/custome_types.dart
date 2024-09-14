class PaginatedObj<T> {
  final List<T> items;
  final bool hasMore;
  final dynamic lastDocument;

  PaginatedObj({required this.items, required this.hasMore, this.lastDocument});
}

abstract class BaseEntity {
  String get id;
  DateTime get updatedDate;
}
