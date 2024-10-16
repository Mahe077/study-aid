import 'package:flutter/material.dart';

Widget buildLoadingMask() {
  return const Center(child: CircularProgressIndicator());
}

class FullScreenLoader extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const FullScreenLoader({
    super.key,
    required this.child,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading) buildLoadingMask(),
      ],
    );
  }
}
