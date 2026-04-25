import 'package:flutter/material.dart';

class MatchScoreRing extends StatelessWidget {
  const MatchScoreRing({
    super.key,
    required this.percentage,
  });

  final int percentage;

  @override
  Widget build(BuildContext context) {
    final ringColor = _ringColorFor(percentage);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: percentage / 100),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SizedBox(
          width: 74,
          height: 74,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 74,
                height: 74,
                child: CircularProgressIndicator(
                  value: value,
                  strokeWidth: 7,
                  strokeCap: StrokeCap.round,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$percentage%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Match',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _ringColorFor(int value) {
    if (value >= 90) {
      return const Color(0xFF51E6A9);
    }

    if (value >= 80) {
      return const Color(0xFF59A8FF);
    }

    return const Color(0xFFFFC857);
  }
}
