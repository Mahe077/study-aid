import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_aid/core/utils/theme/app_colors.dart';
import 'package:study_aid/features/files/presentation/providers/files_providers.dart';

class FileUploadButton extends ConsumerWidget {
  final String topicId;
  final String userId;
  final String sortBy;

  const FileUploadButton({
    super.key,
    required this.topicId,
    required this.userId,
    required this.sortBy,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filesState = ref.watch(filesProvider(FilesParams(topicId: topicId, sortBy: sortBy)));
    final isUploading = filesState.value?.isUploading ?? false;

    return FloatingActionButton.extended(
      onPressed: isUploading
          ? null
          : () async {
              final result = await ref
                  .read(filesProvider(FilesParams(topicId: topicId, sortBy: sortBy)).notifier)
                  .uploadFile(userId: userId, dropdownValue: sortBy);
              
              result.fold(
                (failure) => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(failure.message)),
                ),
                (success) => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('File uploaded successfully')),
                ),
              );
            },
      label: Text(isUploading ? 'Uploading...' : 'Upload File'),
      icon: isUploading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : const Icon(Icons.file_upload),
      backgroundColor: AppColors.primary,
    );
  }
}
