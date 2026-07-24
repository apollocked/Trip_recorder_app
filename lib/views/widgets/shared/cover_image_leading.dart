import 'dart:io';

import 'package:animations_in_flutter/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

Widget coverImage(String imgPath, {double? height}) {
  final h = height ?? 360;

  if (imgPath.startsWith('http://') || imgPath.startsWith('https://')) {
    return Image.network(
      imgPath,
      height: h,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      errorBuilder: (context, error, stackTrace) => Container(
        height: h,
        color: AppColors.placeholderBg,
        child: const Icon(Icons.broken_image, size: 50),
      ),
    );
  }

  final bool isFile = File(imgPath).isAbsolute;

  if (isFile) {
    return Image.file(
      File(imgPath),
      height: h,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      errorBuilder: (context, error, stackTrace) => Container(
        height: h,
        color: AppColors.placeholderBg,
        child: const Icon(Icons.broken_image, size: 50),
      ),
    );
  } else {
    final assetPath = imgPath.startsWith('images/')
        ? imgPath
        : 'images/$imgPath';
    return Image.asset(
      assetPath,
      height: h,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      errorBuilder: (context, error, stackTrace) => Container(
        height: h,
        color: AppColors.placeholderBg,
        child: const Icon(Icons.landscape, size: 50),
      ),
    );
  }
}

Widget coverImageFromList(List<String> paths, {double? height}) {
  final h = height ?? 360;
  if (paths.isEmpty) {
    return Container(
      height: h,
      color: AppColors.placeholderBg,
      child: const Icon(Icons.landscape, size: 50),
    );
  }
  return Stack(
    fit: StackFit.expand,
    children: [
      coverImage(paths.first, height: h),
      if (paths.length > 1)
        Positioned(
          right: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.imageOverlay,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+${paths.length - 1}',
              style: const TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ),
    ],
  );
}
