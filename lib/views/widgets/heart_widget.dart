import 'package:flutter/material.dart';

class HeartWidget extends StatefulWidget {
  const HeartWidget({super.key});

  @override
  State<HeartWidget> createState() => _HeartWidgetState();
}

class _HeartWidgetState extends State<HeartWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;

  Animation? colorAnimation;
  Animation? sizeAnimation;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    colorAnimation = ColorTween(
      begin: Colors.grey[400],
      end: Colors.red,
    ).animate(controller!);

    sizeAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 30, end: 50), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 50, end: 30), weight: 50),
    ]).animate(controller!);

    controller?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          isLiked = true;
        });
      }
      if (status == AnimationStatus.dismissed) {
        setState(() {
          isLiked = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller!,
      builder: (BuildContext context, _) {
        return IconButton(
          icon: Icon(
            Icons.favorite,
            color: colorAnimation?.value,
            size: sizeAnimation?.value,
          ),
          onPressed: () {
            isLiked ? controller?.reverse() : controller?.forward();
          },
        );
      },
    );
  }
}
