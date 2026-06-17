import 'dart:io';
import 'package:flutter/material.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/core/theme/app_colors.dart';
import 'package:animations_in_flutter/views/widgets/permission_dialog.dart';

class TripImagePicker extends StatelessWidget {
  final List<File> imageFiles;
  final List<String> existingImagePaths;
  final bool imageError;
  final ValueChanged<List<File>> onImagesAdded;
  final ValueChanged<int> onImageRemovedAt;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final AppLocalizations l10n;

  const TripImagePicker({
    super.key,
    required this.imageFiles,
    required this.existingImagePaths,
    required this.imageError,
    required this.onImagesAdded,
    required this.onImageRemovedAt,
    required this.colorScheme,
    required this.textTheme,
    required this.l10n,
  });

  List<String> get allPaths => [
    ...imageFiles.map((f) => f.path),
    ...existingImagePaths,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (allPaths.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: allPaths.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == allPaths.length) {
                  return _buildAddButton(context);
                }
                return _buildImageTile(context, index);
              },
            ),
          )
        else
          _buildEmptyState(context),
        if (allPaths.isNotEmpty) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () =>
                pickMultipleImages(context, (files) => onImagesAdded(files)),
            icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
            label: Text(l10n.addMorePhotos),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return GestureDetector(
      onTap: () => pickMultipleImages(context, (files) => onImagesAdded(files)),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: imageError
              ? colorScheme.errorContainer.withAlpha(200)
              : colorScheme.secondaryContainer.withAlpha(102),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: imageError ? colorScheme.error : colorScheme.outlineVariant,
            width: imageError ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_rounded,
              size: 42,
              color: imageError ? colorScheme.error : colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.photoreq,
              style: TextStyle(
                color: imageError
                    ? colorScheme.error
                    : colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.tapToAddPhotos,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () => pickMultipleImages(context, (files) => onImagesAdded(files)),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer.withAlpha(80),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outlineVariant.withAlpha(128)),
        ),
        child: Icon(
          Icons.add_photo_alternate_outlined,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildImageTile(BuildContext context, int index) {
    final path = allPaths[index];
    final isAsset = path.startsWith('images/');
    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
            image: DecorationImage(
              image: isAsset
                  ? AssetImage(path) as ImageProvider
                  : FileImage(File(path)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => onImageRemovedAt(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.imageOverlay,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: AppColors.white),
            ),
          ),
        ),
      ],
    );
  }
}
