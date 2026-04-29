import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/views/pages/details_page.dart';
import 'package:animations_in_flutter/views/widgets/image_widget_leading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget tripWidget(
  Trip trip,
  Animation<double> animation,
  BuildContext context,
  int index, {
  required VoidCallback onRemove,
}) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
    child: FadeTransition(
      opacity: animation,
      child: Dismissible(
        direction: DismissDirection.endToStart,

        background: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.error,
            borderRadius: BorderRadius.circular(8.0),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Icon(
            Icons.delete,
            color: Theme.of(context).colorScheme.onError,
          ),
        ),
        key: Key('${trip.title}-${trip.date}'),
        onDismissed: (direction) {
          HapticFeedback.vibrate();
          onRemove();
        },
        child: Card.outlined(
          shape: Theme.of(context).cardTheme.shape,
          child: ListTile(
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsPage(trip: trip, index: index),
                ),
              );
            },
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${trip.nights} nights',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
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
                child: leadingImage(trip.img),
              ),
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  '\$${trip.price}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${trip.date.day}/${trip.date.month}/${trip.date.year}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
