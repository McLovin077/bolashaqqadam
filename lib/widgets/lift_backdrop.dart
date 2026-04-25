import 'package:flutter/material.dart';

class LiftBackdrop extends StatelessWidget {
  const LiftBackdrop({
    super.key,
    required this.child,
    this.primaryGlow = const Color(0xFF34D1BF),
    this.secondaryGlow = const Color(0xFF4C8DFF),
    this.tertiaryGlow = const Color(0xFFFFC857),
  });

  final Widget child;
  final Color primaryGlow;
  final Color secondaryGlow;
  final Color tertiaryGlow;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF050816),
                  Color(0xFF08101F),
                  Color(0xFF04060E),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -120,
          right: -40,
          child: _GlowOrb(
            color: secondaryGlow,
            size: 280,
          ),
        ),
        Positioned(
          top: 140,
          left: -60,
          child: _GlowOrb(
            color: primaryGlow,
            size: 220,
          ),
        ),
        Positioned(
          bottom: -80,
          right: -20,
          child: _GlowOrb(
            color: tertiaryGlow,
            size: 240,
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.02),
                  Colors.transparent,
                  Colors.white.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.28),
              color.withValues(alpha: 0.08),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
