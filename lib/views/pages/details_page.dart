import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/services/trip_services.dart';
import 'package:animations_in_flutter/views/pages/add_trip_page.dart';
import 'package:animations_in_flutter/views/widgets/cover_image_leading.dart';
import 'package:animations_in_flutter/views/widgets/heart_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DetailsPage extends StatelessWidget {
  final Trip trip;
  final int index;
  const DetailsPage({super.key, required this.trip, required this.index});

  @override
  Widget build(BuildContext context) {
    return Consumer<TripService>(
      builder: (context, tripService, _) {
        if (index >= tripService.trips.length) return const Scaffold();
        final currentTrip = tripService.trips[index];

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final updatedTrip = await Navigator.push<Trip>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTripPage(trip: currentTrip),
                    ),
                  );
                  if (updatedTrip != null && context.mounted) {
                    tripService.updateTrip(index, updatedTrip);
                  }
                },
              ),
            ],
          ),
          extendBodyBehindAppBar: true,
          body: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ClipRRect(
                  child: Hero(
                    tag: 'tag-image-${currentTrip.img}',
                    child: coverImage(currentTrip.img),
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
                      currentTrip.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    subtitle: Text(
                      '${currentTrip.nights} night stay for only \$${currentTrip.price}',
                      style: TextStyle(letterSpacing: 1),
                    ),
                    trailing: HeartWidget(
                      isLiked: currentTrip.isLiked,
                      index: index,
                    ),
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
                      currentTrip.description.isNotEmpty
                          ? currentTrip.description
                          : 'No description added for this trip yet.',
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
