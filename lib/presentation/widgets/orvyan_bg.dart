import 'package:flutter/material.dart';

class OrvyanBackground extends StatefulWidget {
  final Widget child;
  const OrvyanBackground({super.key, required this.child});

  @override
  State<OrvyanBackground> createState() => _OrvyanBackgroundState();
}

class _OrvyanBackgroundState extends State<OrvyanBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(reverse: true);
    _a = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (_, __) {
        final t = _a.value;
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.3 - t * 0.6, -0.2 + t * 0.4),
              radius: 1.2,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.18),
                Theme.of(context).colorScheme.secondary.withOpacity(0.12),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
