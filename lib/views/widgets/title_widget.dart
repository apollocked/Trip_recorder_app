import 'package:animations_in_flutter/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

Widget titleWidget(String title, BuildContext context) {
  final theme = Theme.of(context);
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0),
    curve: Curves.easeInOutQuint,
    duration: const Duration(milliseconds: 800),
    builder: (context, op, child) => Opacity(
      opacity: op,
      child: Padding(padding: EdgeInsets.only(top: op * 20), child: child),
    ),
    child: Text(title,
      semanticsLabel: AppLocalizations.of(context)!.appTitleSemantics,
      style: TextStyle(fontSize: 26, color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
  );
}
