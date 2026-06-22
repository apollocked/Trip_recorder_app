import 'dart:io';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/views/widgets/common/image_source_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void showImageSourceSheet(
  BuildContext context,
  void Function(File) onImagePicked, {
  bool multiPick = false,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;
  final l10n = AppLocalizations.of(context)!;

  showModalBottomSheet(
    context: context,
    backgroundColor: colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              l10n.selectPhotoSource,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ImageSourceCard(
                  icon: Icons.image_search_rounded,
                  label: l10n.gallery,
                  colorScheme: colorScheme,
                  onTap: () {
                    Navigator.pop(context);
                    if (multiPick) {
                      ImagePicker()
                          .pickMultiImage(imageQuality: 85, maxWidth: 1000)
                          .then((files) {
                            if (files.isNotEmpty) {
                              onImagePicked(File(files.first.path));
                            }
                          });
                    } else {
                      _pickImage(ImageSource.gallery, onImagePicked);
                    }
                  },
                ),
                ImageSourceCard(
                  icon: Icons.camera_rounded,
                  label: l10n.camera,
                  colorScheme: colorScheme,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera, onImagePicked);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ),
  );
}

Future<void> _pickImage(
  ImageSource source,
  void Function(File) onImagePicked,
) async {
  final picker = ImagePicker();
  try {
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1000,
      imageQuality: 85,
    );
    if (pickedFile != null) onImagePicked(File(pickedFile.path));
  } catch (e) {
    debugPrint("Error picking image: $e");
  }
}
