import 'package:flutter/material.dart';

Widget titleWidget(String title) {
  return SizedBox(
    height: 80,
    child: TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
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
          fontSize: 36,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
