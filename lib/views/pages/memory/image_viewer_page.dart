import 'package:animations_in_flutter/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:animations_in_flutter/views/widgets/shared/cover_image_leading.dart';

class ImageViewerPage extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const ImageViewerPage({
    super.key,
    required this.imagePaths,
    this.initialIndex = 0,
  });

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  PageController? _pageController;

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

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
        controller:
            _pageController ??= PageController(initialPage: widget.initialIndex),
        itemCount: widget.imagePaths.length,
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Hero(
                tag: 'tag-image-${widget.imagePaths[index]}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: coverImage(widget.imagePaths[index]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
