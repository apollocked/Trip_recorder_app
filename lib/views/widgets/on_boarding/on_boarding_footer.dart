import 'package:flutter/material.dart';

class OnboardingFooter extends StatelessWidget {
  final int itemCount;
  final int currentPage;
  final String buttonText;
  final VoidCallback onNextPressed;

  const OnboardingFooter({
    super.key,
    required this.itemCount,
    required this.currentPage,
    required this.buttonText,
    required this.onNextPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLastPage = currentPage == itemCount - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(
              itemCount,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsetsDirectional.only(end: 8),
                height: 8,
                width: currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: currentPage == index
                      ? colorScheme.primary
                      : colorScheme.primaryContainer.withValues(
                          alpha: 0.4,
                        ), // Fixed: Changed .withOpacity(0.4) to .withValues(alpha: 0.4)
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 56,
            width: isLastPage ? 150 : 56,
            child: ElevatedButton(
              onPressed: onNextPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: EdgeInsets.zero,
                elevation: 0,
              ),
              child: isLastPage
                  ? Text(
                      buttonText,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    )
                  : Icon(
                      Icons.arrow_forward_rounded,
                      size: 24,
                      color: colorScheme.onPrimary,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
