import 'package:flutter/material.dart';

class HeartWidget extends StatefulWidget {
  const HeartWidget({super.key});

  @override
  State<HeartWidget> createState() => _HeartWidgetState();
}

class _HeartWidgetState extends State<HeartWidget> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.favorite, color: Colors.grey[400], size: 30),
      onPressed: () {},
    );
  }
}
