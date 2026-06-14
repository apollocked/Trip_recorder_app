import 'dart:io';
import 'package:animations_in_flutter/l10n/app_localizations.dart';
import 'package:animations_in_flutter/views/widgets/image_source_sheet.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> showSoftAskDialog(
  BuildContext context,
  void Function(File) onImagePicked,
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
      title: Icon(Icons.auto_awesome_motion_rounded, size: 48, color: colorScheme.primary),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.shareJourney,
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
          const SizedBox(height: 12),
          Text(l10n.permissionDescription,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.notNow, style: TextStyle(color: colorScheme.primary)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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

Future<void> _requestSystemPermissions(
  BuildContext context,
  void Function(File) onImagePicked,
) async {
  final statuses = await [Permission.camera, Permission.photos].request();
  if (statuses.values.any((s) => s.isGranted)) {
    showImageSourceSheet(context, onImagePicked);
  } else if (statuses[Permission.camera]!.isPermanentlyDenied ||
      statuses[Permission.photos]!.isPermanentlyDenied) {
    openAppSettings();
  }
}
