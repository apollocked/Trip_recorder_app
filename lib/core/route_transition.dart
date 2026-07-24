import 'package:flutter/material.dart';

Route<T> slideRoute<T>(Widget page) => PageRouteBuilder<T>(
  pageBuilder: (_, _, _) => page,
  transitionsBuilder: (context, animation, _, child) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(isRtl ? -1 : 1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    );
  },
  transitionDuration: const Duration(milliseconds: 300),
);
