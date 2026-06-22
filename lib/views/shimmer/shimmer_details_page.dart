import 'package:animations_in_flutter/core/theme/app_colors.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';

class ShimmerDetailsPage extends StatelessWidget {
  const ShimmerDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      period: const Duration(milliseconds: 1000),
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _imageCarouselShimmer(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 24, right: 24, left: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _headerShimmer(),
                    const SizedBox(height: 16),
                    _chipsShimmer(),
                    const SizedBox(height: 16),
                    _actionChipsShimmer(),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity, height: 1,
                      color: AppColors.white,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 100, height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(5, (_) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        width: double.infinity, height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    )),
                    Container(
                      width: 180, height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageCarouselShimmer() {
    return Container(
      width: double.infinity,
      height: 280,
      color: AppColors.white,
    );
  }

  Widget _headerShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 200, height: 22,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 120, height: 14,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ],
    );
  }

  Widget _chipsShimmer() {
    return Row(
      children: List.generate(3, (_) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Container(
          width: 80, height: 32,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      )),
    );
  }

  Widget _actionChipsShimmer() {
    return Row(
      children: List.generate(3, (_) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Container(
          width: 100, height: 36,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      )),
    );
  }
}
