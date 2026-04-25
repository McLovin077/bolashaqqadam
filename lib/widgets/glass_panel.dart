import 'dart:ui';

import 'package:flutter/material.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 28,
    this.blur = 22,
    this.borderColor,
    this.boxShadow,
    this.gradient,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveBorder =
        borderColor ?? Colors.white.withValues(alpha: 0.08);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: color ?? const Color(0xFF101827).withValues(alpha: 0.74),
            gradient: gradient,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: effectiveBorder),
            boxShadow:
                boxShadow ??
                [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
          ),
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
