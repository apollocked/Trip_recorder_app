import 'package:animations_in_flutter/services/trip_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HeartWidget extends StatefulWidget {
  final int index;
  final bool isLiked;

  const HeartWidget({super.key, required this.isLiked, required this.index});

  @override
  State<HeartWidget> createState() => _HeartWidgetState();
}

class _HeartWidgetState extends State<HeartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Color?> colorAnimation;
  late Animation<double> sizeAnimation;
  late Animation<double> curveAnimation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    curveAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.slowMiddle,
    );

    colorAnimation = ColorTween(
      begin: Colors.grey[400],
      end: Colors.red,
    ).animate(curveAnimation);

    sizeAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 30, end: 50), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 50, end: 30), weight: 50),
    ]).animate(curveAnimation);

    if (widget.isLiked) {
      controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onPressed() {
    final tripService = Provider.of<TripService>(context, listen: false);
    tripService.toggleLike(widget.index);
    if (tripService.trips[widget.index].isLiked) {
      controller.forward();
    } else {
      controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, _) {
        return IconButton(
          icon: Icon(
            Icons.favorite,
            color: colorAnimation.value,
            size: sizeAnimation.value,
          ),
          onPressed: () => onPressed(),
        );
      },
    );
  }
}
