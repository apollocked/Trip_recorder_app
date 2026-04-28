import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/views/pages/details_page.dart';
import 'package:flutter/material.dart';

Widget tripWidget(
  Trip trip,
  Animation<double> animation,
  BuildContext context,
) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1, 0), // Starts from bottom
      end: Offset.zero, // Ends at original position
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
    child: FadeTransition(
      opacity: animation,
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DetailsPage(trip: trip)),
          );
        },
        contentPadding: const EdgeInsets.all(25),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${trip.nights} nights',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue[300],
              ),
            ),
            Text(
              trip.title,
              style: TextStyle(fontSize: 20, color: Colors.grey[600]),
            ),
          ],
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Hero(
            tag: 'tag-image-${trip.img}',
            child: Image.asset(
              'images/${trip.img}',
              height: 50.0,
              width: 50.0,
              fit: BoxFit.cover,
              // Error handling in case image is missing
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.landscape, size: 50),
            ),
          ),
        ),
        trailing: Text(
          '\$${trip.price}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ),
  );
}
