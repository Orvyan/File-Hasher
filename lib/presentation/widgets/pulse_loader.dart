import 'package:flutter/material.dart';

class PulseLoader extends StatefulWidget {
  final double size;
  const PulseLoader({super.key, this.size = 96});

  @override
  State<PulseLoader> createState() => _PulseLoaderState();
}

class _PulseLoaderState extends State<PulseLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return ScaleTransition(
      scale: Tween(begin: 0.92, end: 1.05).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CircularProgressIndicator(strokeWidth: 6, color: color),
      ),
    );
  }
}
