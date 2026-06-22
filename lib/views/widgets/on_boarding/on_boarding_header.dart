import 'package:flutter/material.dart';

class AmbientGlow extends StatelessWidget {
  final Color color;
  final double size;
  final Alignment alignment;

  const AmbientGlow({
    super.key,
    this.color = Colors.transparent,
    this.size = 0.8,
    this.alignment = Alignment.topLeft,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final glowColor = color == Colors.transparent
        ? Theme.of(context).colorScheme.primary
        : color;
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Container(
          width: screenSize.width * size,
          height: screenSize.width * size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: glowColor.withValues(alpha: 0.12),
          ),
        ),
      ),
    );
  }
}