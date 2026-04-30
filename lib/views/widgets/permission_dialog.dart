// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:animations_in_flutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> checkExistingPermissions(
  BuildContext context,
  Function(File) onImagePicked,
) async {
  PermissionStatus cameraStatus = await Permission.camera.status;
  PermissionStatus photoStatus = await Permission.photos.status;

  if (cameraStatus.isGranted || photoStatus.isGranted) {
    _showImageSourceOptions(context, onImagePicked);
  } else {
    _showSoftAskDialog(context, onImagePicked);
  }
}

Future<void> _showSoftAskDialog(
  BuildContext context,
  Function(File) onImagePicked,
) async {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;
  final l10n = AppLocalizations.of(context)!;

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Icon(
        Icons.auto_awesome_motion_rounded,
        size: 48,
        color: colorScheme.primary,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.shareJourney,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.permissionDescription,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.notNow,
            style: TextStyle(color: colorScheme.primary),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () async {
            Navigator.pop(context);
            await _requestSystemPermissions(context, onImagePicked);
          },
          child: Text(l10n.allowAccess),
        ),
      ],
    ),
  );
}

void _showImageSourceOptions(
  BuildContext context,
  Function(File) onImagePicked,
) {
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
            // Handle bar for modern look
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
                _buildSourceCard(
                  context,
                  icon: Icons.image_search_rounded,
                  label: l10n.gallery,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery, onImagePicked);
                  },
                ),
                _buildSourceCard(
                  context,
                  icon: Icons.camera_rounded,
                  label: l10n.camera,
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

// Helper widget to match the Chip-style design of the app
Widget _buildSourceCard(
  BuildContext context, {
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      width: MediaQuery.of(context).size.width * 0.35,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withAlpha(102),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(128)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> _requestSystemPermissions(
  BuildContext context,
  Function(File) onImagePicked,
) async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.camera,
    Permission.photos,
  ].request();

  if (statuses.values.any((status) => status.isGranted)) {
    _showImageSourceOptions(context, onImagePicked);
  } else if (statuses[Permission.camera]!.isPermanentlyDenied ||
      statuses[Permission.photos]!.isPermanentlyDenied) {
    openAppSettings();
  }
}

Future<void> _pickImage(
  ImageSource source,
  Function(File) onImagePicked,
) async {
  final picker = ImagePicker();
  try {
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1000,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      onImagePicked(File(pickedFile.path));
    }
  } catch (e) {
    debugPrint("Error picking image: $e");
  }
}
