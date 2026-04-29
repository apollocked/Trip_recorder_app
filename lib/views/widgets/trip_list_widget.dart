import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/services/trip_services.dart';
import 'package:animations_in_flutter/views/widgets/shimmer_card_widget.dart';
import 'package:animations_in_flutter/views/widgets/trip_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for Haptics
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialTrips = Provider.of<TripService>(
        context,
        listen: false,
      ).trips;
      _syncList(initialTrips);
    });
  }

  void _syncList(List<Trip> latestTrips) async {
    if (_displayList.length > latestTrips.length) {
      _displayList.clear();
    }

    for (int i = _displayList.length; i < latestTrips.length; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;
      _displayList.add(latestTrips[i]);
      _listKey.currentState?.insertItem(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripService = context.watch<TripService>();
    final latestTrips = tripService.trips;

    if (latestTrips.length > _displayList.length) {
      _syncList(latestTrips);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Trips')),
      body: RefreshIndicator(
        onRefresh: () async {
          await HapticFeedback.vibrate();
          await tripService.refresh();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: _buildBody(latestTrips, tripService.isLoading),
        ),
      ),
    );
  }

  Widget _buildBody(List<Trip> latestTrips, bool serviceLoading) {
    if (serviceLoading) {
      return ListView.builder(
        itemCount: _displayList.isEmpty ? 6 : _displayList.length,
        itemBuilder: (context, index) => shimmerCard(context),
      );
    }
    if (latestTrips.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.beach_access, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "No Trips Found",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                    child: Text(
                      "Time to start planning your next adventure! \nPull down to check again.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return AnimatedList(
      key: _listKey,
      initialItemCount: _displayList.length,
      itemBuilder: (context, index, animation) {
        final trip = _displayList[index];
        return tripWidget(
          trip,
          animation,
          context,
          index,
          onRemove: () {
            HapticFeedback.vibrate();
            _displayList.removeAt(index);
            _listKey.currentState?.removeItem(
              index,
              (context, animation) => const SizedBox.shrink(),
              duration: Duration.zero,
            );
            Provider.of<TripService>(context, listen: false).removeTrip(index);
          },
        );
      },
    );
  }
}
