import 'dart:io';

import 'package:flutter/material.dart';

Widget leadingImage(String imgPath) {
  // Check if it's a file path (from Image Picker) which is typically an absolute path
  final bool isFile = File(imgPath).isAbsolute;

  if (isFile) {
    return Image.file(
      File(imgPath),
      height: 50.0,
      width: 50.0,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.broken_image, size: 50),
    );
  } else {
    final assetPath = imgPath.startsWith('images/') ? imgPath : 'images/$imgPath';
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
