import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/views/widgets/heart.dart';
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            child: Image.asset(
              'images/${trip.img}',
              height: 360,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          SizedBox(height: 30),
          ListTile(
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
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Text(
                  Ipsum().paragraphs(1),
                  style: TextStyle(color: Colors.grey[700], height: 1.4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
