import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';

bool _sessionAnswered = false;

Future<bool> requestNotificationPermission(BuildContext context) async {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;
  final l10n = AppLocalizations.of(context)!;

  if (await Permission.notification.status.then((s) => s.isGranted)) return true;
  if (_sessionAnswered) return false;
  if (!context.mounted) return false;

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Icon(
        Icons.notifications_active_rounded,
        size: 48,
        color: colorScheme.primary,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.notificationPermissionTitle,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.notificationPermissionDescription,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
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
            Navigator.pop(ctx, true);
          },
          child: Text(l10n.allowAccess),
        ),
      ],
    ),
  );

  _sessionAnswered = true;

  if (result == true) {
    final status = await Permission.notification.request();
    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        final goSettings = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.notificationPermissionTitle),
            content: Text(l10n.notificationPermissionDescription),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.notNow),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx, true);
                  openAppSettings();
                },
                child: Text(l10n.goToSettings),
              ),
            ],
          ),
        );
        return goSettings ?? false;
      }
    }
    return status.isGranted;
  }
  return false;
}
