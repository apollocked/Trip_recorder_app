// ignore_for_file: use_build_context_synchronously

import 'dart:io';
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
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Icon(Icons.camera_alt, size: 48, color: Colors.blue),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Share your journey!",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 10),
          Text(
            "We need access to your camera and gallery so you can upload beautiful photos of your trips.",
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Not Now"),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.pop(context); // Close this dialog
            await _requestSystemPermissions(context, onImagePicked);
          },
          child: const Text("Allow Access"),
        ),
      ],
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

void _showImageSourceOptions(
  BuildContext context,
  Function(File) onImagePicked,
) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Select Photo Source",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text("Gallery"),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery, onImagePicked);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text("Camera"),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera, onImagePicked);
            },
          ),
        ],
      ),
    ),
  );
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
      // Send the file back to the UI through the callback
      onImagePicked(File(pickedFile.path));
    }
  } catch (e) {
    debugPrint("Error picking image: $e");
  }
}
