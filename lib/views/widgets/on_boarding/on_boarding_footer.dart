import 'package:flutter/material.dart';

class OnboardingFooter extends StatelessWidget {
  final int itemCount;
  final int currentPage;
  final String buttonText;
  final String nextLabel;
  final String skipLabel;
  final VoidCallback onNextPressed;
  final VoidCallback onSkip;

  const OnboardingFooter({
    super.key,
    required this.itemCount,
    required this.currentPage,
    required this.buttonText,
    required this.nextLabel,
    required this.skipLabel,
    required this.onNextPressed,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLastPage = currentPage == itemCount - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pill-shaped page indicator
          Container(
            height: 8,
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(itemCount, (i) {
                final isActive = i == currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 8,
                  width: isActive ? 28 : 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? colorScheme.primary
                        : colorScheme.primary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          // CTA button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: onNextPressed,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: isLastPage
                  ? Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          nextLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
            ),
          ),
          if (!isLastPage) ...[
            const SizedBox(height: 12),
            // Skip button
            TextButton(
              onPressed: onSkip,
              child: Text(
                skipLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
