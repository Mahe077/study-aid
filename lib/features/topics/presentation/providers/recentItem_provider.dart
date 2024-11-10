import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_aid/features/topics/presentation/notifiers/recentItem_notifier.dart';

final recentItemProvider = StateNotifierProvider.autoDispose
    .family<RecentitemNotifier, AsyncValue<RecentItemState>, String>(
        (ref, userId) {
  return RecentitemNotifier(ref, userId);
});
