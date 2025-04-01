import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;

  const LoadingWidget({
    super.key,
    this.size = 40.0,
    this.strokeWidth = 4.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? Theme.of(context).colorScheme.primary, // Use primary color from theme if not specified
          ),
        ),
      ),
    );
  }
}