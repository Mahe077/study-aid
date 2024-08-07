import 'package:cloud_firestore/cloud_firestore.dart';

class PaginatedObj<T> {
  final List<T> items;
  final bool hasMore;
  final DocumentSnapshot? lastDocument;

  PaginatedObj({required this.items, required this.hasMore, this.lastDocument});
}
