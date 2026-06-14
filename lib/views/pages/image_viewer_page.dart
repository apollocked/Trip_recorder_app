import 'package:flutter/material.dart';
import 'package:animations_in_flutter/views/widgets/cover_image_leading.dart';

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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
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
