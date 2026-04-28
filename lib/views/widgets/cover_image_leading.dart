import 'dart:io';

import 'package:flutter/material.dart';

Widget coverImage(String imgPath) {
  // Check if it's a file path (from Image Picker) which is typically an absolute path
  final bool isFile = File(imgPath).isAbsolute;

  if (isFile) {
    return Image.file(
      File(imgPath),
      height: 360,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 360,
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, size: 50),
      ),
    );
  } else {
    final assetPath = imgPath.startsWith('images/') ? imgPath : 'images/$imgPath';
    return Image.asset(
      assetPath,
      height: 360,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 360,
        color: Colors.grey[300],
        child: const Icon(Icons.landscape, size: 50),
      ),
    );
  }
}
