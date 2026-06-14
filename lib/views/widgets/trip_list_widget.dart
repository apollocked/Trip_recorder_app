// ignore_for_file: use_build_context_synchronously

import 'package:animations_in_flutter/l10n/app_localizations.dart';
import 'package:animations_in_flutter/model/trip.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/pages/add_trip_page.dart';
import 'package:animations_in_flutter/views/widgets/settings_modal.dart';
import 'package:animations_in_flutter/views/widgets/shimmer_card_widget.dart';
import 'package:animations_in_flutter/views/widgets/trip_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class TripListPage extends StatefulWidget {
  const TripListPage({super.key});

  @override
  State<TripListPage> createState() => _TripListPageState();
}

class _TripListPageState extends State<TripListPage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<Trip> _displayList = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialTrips = Provider.of<TripProvider>(
        context,
        listen: false,
      ).trips;
      _syncList(initialTrips);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    final tripProvider = context.watch<TripProvider>();
    final latestTrips = tripProvider.trips;
    final filteredTrips = tripProvider.filteredTrips;

    if (latestTrips.length > _displayList.length) {
      _syncList(latestTrips);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.tripsList,
          semanticsLabel: 'Title of the trip list',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => showSettingsModal(context),
            tooltip: 'Settings',
          ),

          SizedBox(width: 16),

          latestTrips.isEmpty
              ? const SizedBox.shrink()
              : FloatingActionButton.extended(
                  onPressed: () async {
                    HapticFeedback.lightImpact();
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddTripPage(),
                      ),
                    );
                  },
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  elevation: 6,
                  icon: const Icon(
                    semanticLabel: "adding a new trip",
                    Icons.add_road_rounded,
                    size: 18,
                  ),
                  label: Text(
                    AppLocalizations.of(context)!.newjourney,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      fontSize: 12,
                    ),
                  ),
                ),

          SizedBox(width: 16),
        ],
      ),

      body: Column(
        children: [
          if (latestTrips.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => tripProvider.setSearchQuery(value),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withAlpha(60),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              semanticsLabel: "Pull to refresh the trip list",
              onRefresh: () async {
                await HapticFeedback.vibrate();
                await tripProvider.refresh();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                child: _buildBody(filteredTrips, tripProvider.isLoading),
              ),
            ),
          ),
        ],
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
                  const Icon(
                    Icons.beach_access,
                    size: 80,
                    color: Colors.grey,
                    semanticLabel: "No trips icon",
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noTripsFound,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 8,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.emptylistDescription,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),

                  FloatingActionButton.extended(
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddTripPage(),
                        ),
                      );
                    },
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 6,
                    icon: const Icon(
                      Icons.add_road_rounded,
                      semanticLabel: "Add",
                    ),
                    label: Text(
                      AppLocalizations.of(context)!.newjourney,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.3,
                        fontSize: 12,
                      ),
                    ),
                  ),
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
        return Semantics(
          label:
              "Trip item of ${trip.title}, tap for details ,swape left to delete",
          child: tripWidget(
            trip,
            animation,
            context,
            index,
            onRemove: () {
              HapticFeedback.vibrate();
              final removedTrip = _displayList.removeAt(index);
              _listKey.currentState?.removeItem(
                index,
                (context, animation) => const SizedBox.shrink(),
                duration: Duration.zero,
              );
              Provider.of<TripProvider>(
                context,
                listen: false,
              ).deleteTrip(removedTrip.id);
            },
          ),
        );
      },
    );
  }
}
