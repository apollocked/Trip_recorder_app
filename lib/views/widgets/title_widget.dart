import 'package:flutter/material.dart';

Widget titleWidget(String title, BuildContext context) {
  return SizedBox(
    height: 89,
    child: TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeInOutQuint,
      duration: Duration(milliseconds: 800),
      builder: (context, double op, Widget? child) => Opacity(
        opacity: op,
        child: Padding(
          padding: EdgeInsets.only(top: op * 20),
          child: child,
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 26,
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
