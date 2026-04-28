import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/services/trip_services.dart';
import 'package:animations_in_flutter/views/widgets/trip_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TripListPage extends StatefulWidget {
  const TripListPage({super.key});

  @override
  State<TripListPage> createState() => _TripListPageState();
}

class _TripListPageState extends State<TripListPage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<Trip> _displayList = [];

  @override
  void initState() {
    super.initState();
    // Initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialTrips = Provider.of<TripService>(
        context,
        listen: false,
      ).trips;
      _syncList(initialTrips);
    });
  }

  void _syncList(List<Trip> latestTrips) async {
    for (int i = _displayList.length; i < latestTrips.length; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      _displayList.add(latestTrips[i]);
      _listKey.currentState?.insertItem(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for new trips being added from other pages
    final latestTrips = context.watch<TripService>().trips;

    // If the service has more items than our display list, sync them
    if (latestTrips.length > _displayList.length) {
      _syncList(latestTrips);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: AnimatedList(
        key: _listKey,
        initialItemCount: _displayList.length,
        itemBuilder: (context, index, animation) {
          final trip = _displayList[index];
          return tripWidget(trip, animation, context, index, onRemove: () {
            _displayList.removeAt(index);
            _listKey.currentState?.removeItem(
              index,
              (context, animation) => const SizedBox.shrink(),
              duration: Duration.zero,
            );
            Provider.of<TripService>(context, listen: false).removeTrip(index);
          });
        },
      ),
    );
  }
}
