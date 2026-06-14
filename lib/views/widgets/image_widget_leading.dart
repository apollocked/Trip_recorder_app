import 'dart:io';

import 'package:flutter/material.dart';

Widget leadingImage(String imgPath) {
  final bool isFile = File(imgPath).isAbsolute;

  if (isFile) {
    return Image.file(
      semanticLabel: "Cover photo of the trip",
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

Widget leadingImageFromList(List<String> paths) {
  if (paths.isEmpty) {
    return Container(
      height: 50, width: 50,
      color: Colors.grey[300],
      child: const Icon(Icons.landscape, size: 24),
    );
  }
  return leadingImage(paths.first);
}
