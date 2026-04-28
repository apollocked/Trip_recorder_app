import 'package:animations_in_flutter/data/trip_list.dart';
import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/views/widgets/trip_widget.dart';
import 'package:flutter/material.dart';

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
      _addTrips();
    });
  }

  void _addTrips() async {
    for (int i = 0; i < trips.length; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      _displayList.add(trips[i]);
      _listKey.currentState?.insertItem(i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: AnimatedList(
        key: _listKey,
        initialItemCount: _displayList.length,
        itemBuilder: (context, index, animation) {
          return tripWidget(_displayList[index], animation, context, index);
        },
      ),
    );
  }
}
