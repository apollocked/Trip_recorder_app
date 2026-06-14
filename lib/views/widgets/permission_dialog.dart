// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:animations_in_flutter/views/widgets/image_source_sheet.dart';
import 'package:animations_in_flutter/views/widgets/soft_ask_dialog.dart';
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
    showImageSourceSheet(context, onImagePicked);
  } else {
    showSoftAskDialog(context, onImagePicked);
  }
}

Future<void> pickMultipleImages(
  BuildContext context,
  Function(List<File>) onImagesPicked,
) async {
  PermissionStatus photoStatus = await Permission.photos.status;
  if (photoStatus.isGranted) {
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
  } else {
    final statuses = await [Permission.photos].request();
    if (statuses[Permission.photos]!.isGranted) {
      final picker = ImagePicker();
      final pickedFiles = await picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1000,
      );
      if (pickedFiles.isNotEmpty) {
        onImagesPicked(pickedFiles.map((f) => File(f.path)).toList());
      }
    }
  }
}
