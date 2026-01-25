import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_aid/common/providers/sync_provider.dart';
import 'package:study_aid/common/widgets/bannerbars/base_bannerbar.dart';

class SyncButton extends ConsumerStatefulWidget {
  final String userId;
  const SyncButton({super.key, required this.userId});

  @override
  ConsumerState<SyncButton> createState() => _SyncButtonState();
}

class _SyncButtonState extends ConsumerState<SyncButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _triggerSync() async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
      _controller.repeat();
    });

    final toast = CustomToast(context: context);
    toast.showInfo(title: "Sync Started", description: "Syncing data with cloud...");

    try {
      await ref.read(syncProvider).syncAll(widget.userId);
      if (mounted) {
        toast.showSuccess(description: "Sync completed successfully.");
      }
    } catch (e) {
      if (mounted) {
        toast.showFailure(description: "Sync failed: ${e.toString()}");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _controller.stop();
          _controller.reset();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _triggerSync,
      icon: RotationTransition(
        turns: _controller,
        child: const Icon(
          Icons.sync,
          color: Colors.black, // Matching BasicAppbar icon color
        ),
      ),
      tooltip: 'Sync Now',
    );
  }
}
