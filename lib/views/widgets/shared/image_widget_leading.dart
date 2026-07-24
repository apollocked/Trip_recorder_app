import 'dart:io';

import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

Widget leadingImage(String imgPath, {BuildContext? context}) {
  final bool isFile = File(imgPath).isAbsolute;
  final label = context != null
      ? AppLocalizations.of(context)!.coverPhotoSemantics
      : "Cover photo of the trip";

  if (isFile) {
    return Image.file(
      semanticLabel: label,
      File(imgPath),
      height: 50.0,
      width: 50.0,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.broken_image, size: 50),
    );
  } else {
    final assetPath = imgPath.startsWith('images/')
        ? imgPath
        : 'images/$imgPath';
    return Image.asset(
      assetPath,
      height: 50.0,
      width: 50.0,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.landscape, size: 50),
    );
  }
}

Widget leadingImageFromList(List<String> paths, {BuildContext? context}) {
  if (paths.isEmpty) {
    return Container(
      height: 50,
      width: 50,
      color: AppColors.placeholderBg,
      child: const Icon(Icons.landscape, size: 24),
    );
  }
  return leadingImage(paths.first, context: context);
}
