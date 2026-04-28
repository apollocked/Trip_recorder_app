import 'dart:io';

import 'package:flutter/material.dart';

Widget coverImage(String imgPath) {
  // Same check: if it has a slash, it's a File path from the gallery
  final bool isFile = imgPath.contains('/') || imgPath.contains('\\');

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
    return Image.asset(
      'images/$imgPath',
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
