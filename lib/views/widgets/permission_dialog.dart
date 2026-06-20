// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/views/widgets/image_source_sheet.dart';
import 'package:animations_in_flutter/views/widgets/soft_ask_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> _isPhotoPermissionGranted() async {
  if (Platform.isAndroid) {
    final androidVersion = int.tryParse(Platform.version.split('.').firstOrNull ?? '0') ?? 0;
    if (androidVersion >= 33) {
      return await Permission.photos.status.isGranted;
    }
    return await Permission.storage.status.isGranted;
  }
  if (Platform.isIOS) {
    return await Permission.photos.status.isGranted;
  }
  return false;
}

Future<void> checkExistingPermissions(
  BuildContext context,
  Function(File) onImagePicked,
) async {
  if (await _isPhotoPermissionGranted()) {
    showImageSourceSheet(context, onImagePicked);
    return;
  }
  final l10n = AppLocalizations.of(context)!;
  await showSoftAskDialog(
    context,
    title: l10n.shareJourney,
    message: l10n.permissionDescription,
    onAllow: () => showImageSourceSheet(context, onImagePicked),
  );
}

Future<void> pickMultipleImages(
  BuildContext context,
  Function(List<File>) onImagesPicked,
) async {
  if (await _isPhotoPermissionGranted()) {
    final picker = ImagePicker();
    try {
      final pickedFiles = await picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1000,
      );
      if (pickedFiles.isNotEmpty) {
        onImagesPicked(pickedFiles.map((f) => File(f.path)).toList());
      }
    } catch (e) {
      debugPrint("Error picking multiple images: $e");
    }
    return;
  }
  final l10n = AppLocalizations.of(context)!;
  await showSoftAskDialog(
    context,
    title: l10n.shareJourney,
    message: l10n.permissionDescription,
    onAllow: () async {
      final picker = ImagePicker();
      try {
        final pickedFiles = await picker.pickMultiImage(
          imageQuality: 85,
          maxWidth: 1000,
        );
        if (pickedFiles.isNotEmpty) {
          onImagesPicked(pickedFiles.map((f) => File(f.path)).toList());
        }
      } catch (e) {
        debugPrint("Error picking multiple images: $e");
      }
    },
  );
}
