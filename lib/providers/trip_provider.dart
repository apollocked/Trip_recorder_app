import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../data/repositories/trip_repository.dart';
import '../model/trip.dart';
import '../model/trip_category.dart';

class TripProvider extends ChangeNotifier {
  final TripRepository _repository = TripRepository();

  List<Trip> _trips = [];
  List<Trip> get trips => _trips;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isFirstTime = true;
  bool get isFirstTime => _isFirstTime;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  TripCategory? _categoryFilter;
  TripCategory? get categoryFilter => _categoryFilter;

  String _sortBy = 'date_desc';
  String get sortBy => _sortBy;

  TripProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _checkOnboardingStatus();
    await _migrateOldDataIfNeeded();
    await loadTrips();
  }

  Future<void> _migrateOldDataIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyMigrated = prefs.getBool(AppConstants.prefDataMigrated) ?? false;
    if (alreadyMigrated) return;

    final String? tripsJson = prefs.getString('user_trips');
    if (tripsJson == null) {
      await prefs.setBool(AppConstants.prefDataMigrated, true);
      return;
    }

    try {
      final List<dynamic> decoded = jsonDecode(tripsJson);
      final oldTrips = decoded.map((item) => Trip.fromJson(item)).toList();
      for (final trip in oldTrips) {
        final files = <File>[];
        final assets = <String>[];
        for (final path in trip.imagePaths) {
          final file = File(path);
          if (file.isAbsolute && await file.exists()) {
            files.add(file);
          } else if (path.startsWith('images/')) {
            assets.add(path);
          }
        }
        final saved = await _repository.addTrip(
          title: trip.title,
          price: trip.price,
          nights: trip.nights,
          imageFiles: files,
          assetImagePaths: assets,
          date: trip.date,
          description: trip.description,
          category: trip.category,
          rating: trip.rating,
        );
        if (trip.isLiked) {
          await _repository.toggleLike(saved.id);
        }
      }
      await prefs.remove('user_trips');
    } catch (e) {
      debugPrint('Migration error: $e');
    }

    await prefs.setBool(AppConstants.prefDataMigrated, true);
  }

  Future<void> loadTrips() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _trips = await _repository.getAllTrips();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await _initialize();
  }

  Future<Trip> addTrip({
    required String title,
    required double price,
    required int nights,
    required List<File> imageFiles,
    required List<String> assetImagePaths,
    required DateTime date,
    String description = '',
    TripCategory category = TripCategory.other,
    double rating = 0.0,
  }) async {
    final trip = await _repository.addTrip(
      title: title,
      price: price,
      nights: nights,
      imageFiles: imageFiles,
      assetImagePaths: assetImagePaths,
      date: date,
      description: description,
      category: category,
      rating: rating,
    );
    _trips.insert(0, trip);
    notifyListeners();
    return trip;
  }

  Future<Trip> updateTrip(
    String id, {
    required String title,
    required double price,
    required int nights,
    List<File>? imageFiles,
    List<String>? existingImagePaths,
    List<String>? assetImagePaths,
    required DateTime date,
    String description = '',
    bool? isLiked,
    TripCategory? category,
    double? rating,
  }) async {
    final trip = await _repository.updateTrip(
      id,
      title: title,
      price: price,
      nights: nights,
      imageFiles: imageFiles,
      existingImagePaths: existingImagePaths,
      assetImagePaths: assetImagePaths,
      date: date,
      description: description,
      isLiked: isLiked,
      category: category,
      rating: rating,
    );
    final index = _trips.indexWhere((t) => t.id == id);
    if (index != -1) {
      _trips[index] = trip;
      notifyListeners();
    }
    return trip;
  }

  Future<void> deleteTrip(String id) async {
    await _repository.deleteTrip(id);
    _trips.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  Future<void> toggleLike(String id) async {
    await _repository.toggleLike(id);
    final index = _trips.indexWhere((t) => t.id == id);
    if (index != -1) {
      _trips[index] = _trips[index].copyWith(isLiked: !_trips[index].isLiked);
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategoryFilter(TripCategory? category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  List<Trip> get filteredTrips {
    var result = List<Trip>.from(_trips);

    if (_searchQuery.isNotEmpty) {
      final lower = _searchQuery.toLowerCase();
      result = result
          .where((t) =>
              t.title.toLowerCase().contains(lower) ||
              t.description.toLowerCase().contains(lower))
          .toList();
    }

    if (_categoryFilter != null) {
      result = result.where((t) => t.category == _categoryFilter).toList();
    }

    switch (_sortBy) {
      case 'date_asc':
        result.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'date_desc':
        result.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'price_asc':
        result.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        result.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating_desc':
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'title_asc':
        result.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    return result;
  }

  Trip? getTripById(String id) {
    try {
      return _trips.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> get statistics {
    final totalTrips = _trips.length;
    final totalSpent = _trips.fold<double>(0, (sum, t) => sum + t.price);
    final totalNights = _trips.fold<int>(0, (sum, t) => sum + t.nights);
    final avgRating = totalTrips > 0
        ? _trips.fold<double>(0, (sum, t) => sum + t.rating) / totalTrips
        : 0.0;
    final likedCount = _trips.where((t) => t.isLiked).length;

    final categoryCounts = <TripCategory, int>{};
    for (final t in _trips) {
      categoryCounts[t.category] = (categoryCounts[t.category] ?? 0) + 1;
    }
    final topCategory = categoryCounts.entries.isNotEmpty
        ? categoryCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : null;

    final destinationCounts = <String, int>{};
    for (final t in _trips) {
      destinationCounts[t.title] = (destinationCounts[t.title] ?? 0) + 1;
    }
    final topDestination = destinationCounts.entries.isNotEmpty
        ? destinationCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : null;

    return {
      'totalTrips': totalTrips,
      'totalSpent': totalSpent,
      'totalNights': totalNights,
      'avgRating': double.parse(avgRating.toStringAsFixed(1)),
      'likedCount': likedCount,
      'topCategory': topCategory,
      'topDestination': topDestination,
      'categoryCounts': categoryCounts,
    };
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstTime = prefs.getBool(AppConstants.prefOnboardingDone) != true;
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefOnboardingDone, true);
    _isFirstTime = false;
    notifyListeners();
  }
}
