import 'package:animations_in_flutter/core/theme/app_colors.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';

class ShimmerNextTripsPage extends StatelessWidget {
  const ShimmerNextTripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      period: const Duration(milliseconds: 1000),
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
        children: [
          _heroSummaryShimmer(),
          const SizedBox(height: 20),
          _sectionHeaderShimmer(),
          const SizedBox(height: 8),
          ...List.generate(2, (_) => _tripCardShimmer()),
          const SizedBox(height: 20),
          _sectionHeaderShimmer(),
          const SizedBox(height: 8),
          ...List.generate(1, (_) => _tripCardShimmer()),
        ],
      ),
    );
  }

  Widget _heroSummaryShimmer() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }

  Widget _sectionHeaderShimmer() {
    return Row(
      children: [
        Container(
          width: 4, height: 18,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 80, height: 16,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }

  Widget _tripCardShimmer() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
