import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/views/widgets/heart_widget.dart';
import 'package:flutter/material.dart';
import 'package:ipsum/ipsum.dart';

class DetailsPage extends StatelessWidget {
  final Trip trip;
  const DetailsPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      extendBodyBehindAppBar: true,
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ClipRRect(
              child: Hero(
                tag: 'tag-image-${trip.img}',
                child: Image.asset(
                  'images/${trip.img}',
                  height: 360,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          TweenAnimationBuilder(
            curve: Curves.easeInOut,
            tween: Tween(begin: 1.0, end: 0.0),
            duration: Duration(milliseconds: 600),
            builder: (context, double op, Widget? child) => Opacity(
              opacity: 1 - op,
              child: Padding(
                padding: EdgeInsets.only(
                  right: (1 - op) * 15,
                  left: (1 - op) * 15,
                ),
                child: child,
              ),
            ),
            child: SizedBox(
              child: ListTile(
                title: Text(
                  trip.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.grey[800],
                  ),
                ),
                subtitle: Text(
                  '${trip.nights} night stay for only \$${trip.price}',
                  style: TextStyle(letterSpacing: 1),
                ),
                trailing: HeartWidget(),
              ),
            ),
          ),
          TweenAnimationBuilder(
            curve: Curves.easeInOut,
            tween: Tween(begin: 1.0, end: 0.0),
            duration: Duration(milliseconds: 600),
            builder: (context, double op, Widget? child) => Padding(
              padding: EdgeInsets.only(
                top: op * 45,
                right: 24,
                left: 24,
                bottom: 10,
              ),
              child: child,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height / 2.3,
              width: double.infinity,
              child: SingleChildScrollView(
                child: Text(
                  Ipsum().paragraphs(1),
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: Colors.grey[500], fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
