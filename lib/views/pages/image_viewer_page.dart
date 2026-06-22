import 'package:animations_in_flutter/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:animations_in_flutter/views/widgets/common/cover_image_leading.dart';

class ImageViewerPage extends StatelessWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const ImageViewerPage({
    super.key,
    required this.imagePaths,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        iconTheme: const IconThemeData(color: AppColors.white),
        elevation: 0,
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Hero(
                tag: 'tag-image-${imagePaths[index]}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: coverImage(imagePaths[index]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
