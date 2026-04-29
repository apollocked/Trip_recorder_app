import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';

Widget shimmerCard(BuildContext context) {
  return Shimmer.fromColors(
    period: const Duration(milliseconds: 1000),
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Card.outlined(
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 60, height: 12, color: Colors.white),
              const SizedBox(height: 8),
              Container(width: 150, height: 18, color: Colors.white),
            ],
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(width: 40, height: 12, color: Colors.white),
              Container(width: 60, height: 10, color: Colors.white),
            ],
          ),
        ),
      ),
    ),
  );
}
