import 'package:flutter/material.dart';

class LoaderOverlay extends StatelessWidget {
  final double progress;
  final String label;
  const LoaderOverlay({super.key, required this.progress, this.label = 'Processing...'});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 250),
      child: Container(
        alignment: Alignment.center,
        color: Colors.black.withOpacity(0.45),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.9, end: 1.05),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeInOut,
                builder: (context, v, child) => Transform.scale(scale: v, child: child),
                child: const CircularProgressIndicator(strokeWidth: 6),
              ),
            ),
            const SizedBox(height: 12),
            Text('$label ${(progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
