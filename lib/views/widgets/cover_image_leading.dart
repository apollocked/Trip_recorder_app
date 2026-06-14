import 'dart:io';

import 'package:flutter/material.dart';

Widget coverImage(String imgPath) {
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
    final assetPath = imgPath.startsWith('images/')
        ? imgPath
        : 'images/$imgPath';
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

Widget coverImageFromList(List<String> paths) {
  if (paths.isEmpty) {
    return Container(
      height: 360,
      color: Colors.grey[300],
      child: const Icon(Icons.landscape, size: 50),
    );
  }
  return Stack(
    fit: StackFit.expand,
    children: [
      coverImage(paths.first),
      if (paths.length > 1)
        Positioned(
          right: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+${paths.length - 1}',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ),
    ],
  );
}
