import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_aid/features/notes/presentation/providers/summarization_provider.dart';

class SummarizationDialog extends ConsumerStatefulWidget {
  final String content;
  final String topicId;
  final String userId;
  final String? title;
  final Color? noteColor;

  const SummarizationDialog({
    Key? key,
    required this.content,
    required this.topicId,
    required this.userId,
    this.title,
    this.noteColor,
  }) : super(key: key);

  @override
  ConsumerState<SummarizationDialog> createState() => _SummarizationDialogState();
}

class _SummarizationDialogState extends ConsumerState<SummarizationDialog> {
  @override
  void initState() {
    super.initState();
    // Start summarization immediately when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(summarizationNotifierProvider.notifier).summarizeAndSave(
            content: widget.content,
            topicId: widget.topicId,
            userId: widget.userId,
            title: widget.title,
            noteColor: widget.noteColor,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(summarizationNotifierProvider);

    return AlertDialog(
      title: const Text('AI Summarization'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.isLoading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 16),
            ],
            Text(
              state.statusMessage,
              style: TextStyle(
                color: state.isError ? Colors.red : Colors.black87,
                fontWeight: state.isError ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (state.accumulatedSummary.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Preview:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: Text(state.accumulatedSummary),
                ),
              ),
            ],
            if (state.isSuccess) ...[
              const SizedBox(height: 16),
              const Center(
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (state.isSuccess || state.isError)
          TextButton(
            onPressed: () => Navigator.of(context).pop(state.createdNote),
            child: const Text('Close'),
          ),
      ],
    );
  }
}
