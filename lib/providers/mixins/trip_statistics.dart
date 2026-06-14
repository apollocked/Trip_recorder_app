import '../../model/trip.dart';
import '../../model/trip_category.dart';

class TripStatistics {
  final int totalTrips;
  final double totalSpent;
  final int totalNights;
  final double avgRating;
  final int likedCount;
  final TripCategory? topCategory;
  final String? topDestination;
  final Map<TripCategory, int> categoryCounts;

  const TripStatistics({
    required this.totalTrips,
    required this.totalSpent,
    required this.totalNights,
    required this.avgRating,
    required this.likedCount,
    required this.topCategory,
    required this.topDestination,
    required this.categoryCounts,
  });

  factory TripStatistics.fromTrips(List<Trip> trips) {
    final totalTrips = trips.length;
    final totalSpent = trips.fold<double>(0, (sum, t) => sum + t.price);
    final totalNights = trips.fold<int>(0, (sum, t) => sum + t.nights);
    final avgRating = totalTrips > 0
        ? trips.fold<double>(0, (sum, t) => sum + t.rating) / totalTrips
        : 0.0;
    final likedCount = trips.where((t) => t.isLiked).length;

    final categoryCounts = <TripCategory, int>{};
    for (final t in trips) {
      categoryCounts[t.category] = (categoryCounts[t.category] ?? 0) + 1;
    }
    final topCategory = categoryCounts.entries.isNotEmpty
        ? categoryCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : null;

    final destinationCounts = <String, int>{};
    for (final t in trips) {
      destinationCounts[t.title] = (destinationCounts[t.title] ?? 0) + 1;
    }
    final topDestination = destinationCounts.entries.isNotEmpty
        ? destinationCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : null;

    return TripStatistics(
      totalTrips: totalTrips,
      totalSpent: totalSpent,
      totalNights: totalNights,
      avgRating: double.parse(avgRating.toStringAsFixed(1)),
      likedCount: likedCount,
      topCategory: topCategory,
      topDestination: topDestination,
      categoryCounts: categoryCounts,
    );
  }

  Map<String, dynamic> toMap() => {
    'totalTrips': totalTrips,
    'totalSpent': totalSpent,
    'totalNights': totalNights,
    'avgRating': avgRating,
    'likedCount': likedCount,
    'topCategory': topCategory,
    'topDestination': topDestination,
    'categoryCounts': categoryCounts,
  };
}
