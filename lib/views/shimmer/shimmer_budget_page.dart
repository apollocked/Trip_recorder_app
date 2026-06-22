import 'package:animations_in_flutter/core/theme/app_colors.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';

class ShimmerBudgetPage extends StatelessWidget {
  const ShimmerBudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      period: const Duration(milliseconds: 1000),
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _shimmerCard(height: 120),
            const SizedBox(height: 24),
            _shimmerBar(width: 160, height: 14),
            const SizedBox(height: 12),
            ...List.generate(4, (_) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _shimmerBar(width: double.infinity, height: 18),
            )),
            const SizedBox(height: 24),
            _shimmerBar(width: 100, height: 14),
            const SizedBox(height: 8),
            ...List.generate(4, (_) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _shimmerCard(height: 72),
            )),
          ],
        ),
      ),
    );
  }

  Widget _shimmerCard({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _shimmerBar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
