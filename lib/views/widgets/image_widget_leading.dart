import 'dart:io';

import 'package:flutter/material.dart';

Widget leadingImage(String imgPath) {
  // Check if it's a file path (from Image Picker) or an asset name
  // Gallery images usually contain '/' or start with 'cache/' or 'data/'
  final bool isFile = imgPath.contains('/') || imgPath.contains('\\');

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
    return Image.asset(
      'images/$imgPath',
      height: 50.0,
      width: 50.0,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.landscape, size: 50),
    );
  }
}
