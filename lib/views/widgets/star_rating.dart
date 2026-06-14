import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final bool interactive;
  final ValueChanged<double>? onChanged;

  const StarRating({
    super.key,
    this.rating = 0.0,
    this.size = 28,
    this.interactive = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = (index + 1).toDouble();
        final isFilled = starValue <= rating;
        final isHalf = !isFilled && (starValue - 0.5) <= rating;

        return GestureDetector(
          onTap: interactive ? () => onChanged?.call(starValue) : null,
          child: Padding(
            padding: EdgeInsets.only(right: index < 4 ? 2 : 0),
            child: Icon(
              isFilled
                  ? Icons.star_rounded
                  : isHalf
                      ? Icons.star_half_rounded
                      : Icons.star_border_rounded,
              size: size,
              color: isFilled || isHalf
                  ? Colors.amber
                  : colorScheme.outlineVariant,
            ),
          ),
        );
      }),
    );
  }
}
