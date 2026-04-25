import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;

        return Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF050816),
                      Color(0xFF070C18),
                      Color(0xFF04060E),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -120 + (math.sin(t * math.pi * 2) * 50),
              left: -60 + (math.cos(t * math.pi * 2) * 40),
              child: const _BlurOrb(size: 260, color: Color(0xFF34D1BF)),
            ),
            Positioned(
              top: 140 + (math.cos(t * math.pi * 2) * 60),
              right: -90 + (math.sin(t * math.pi * 2) * 45),
              child: const _BlurOrb(size: 320, color: Color(0xFF59A8FF)),
            ),
            Positioned(
              bottom: -110 + (math.cos(t * math.pi * 2) * 50),
              left: 90 + (math.sin(t * math.pi * 2) * 55),
              child: const _BlurOrb(size: 240, color: Color(0xFFFF7AC6)),
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
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}

class _BlurOrb extends StatelessWidget {
  const _BlurOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.10),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.34),
                  blurRadius: 120,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
