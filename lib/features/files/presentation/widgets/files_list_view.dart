import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_aid/common/helpers/enums.dart';
import 'package:study_aid/common/widgets/tiles/content_tile.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';
import 'package:study_aid/features/files/presentation/providers/files_providers.dart';

class FilesListView extends ConsumerWidget {
  final String topicId;
  final String userId;
  final String sortBy;
  final ScrollController scrollController;
  final Color tileColor;

  const FilesListView({
    super.key,
    required this.topicId,
    required this.userId,
    required this.sortBy,
    required this.scrollController,
    required this.tileColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filesState = ref.watch(filesProvider(FilesParams(topicId: topicId, sortBy: sortBy)));

    return filesState.when(
      data: (state) {
        if (state.files.isEmpty && !state.isUploading) {
          return const Center(
            child: Text("No items to show"),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  if (state.isUploading)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppColors.grey.withOpacity(0.3),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Uploading file...',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ...state.files.map((file) => Column(
                        children: [
                          ContentTile(
                            userId: userId,
                            entity: file,
                            type: TopicType.file,
                            parentTopicId: topicId,
                            dropdownValue: sortBy,
                            tileColor: tileColor,
                          ),
                          const SizedBox(height: 10),
                        ],
                      )),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
