import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../data/repositories/trip_repository.dart';
import '../model/trip.dart';

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
        final file = File(trip.imagePath);
        if (file.isAbsolute && await file.exists()) {
          final saved = await _repository.addTrip(
            title: trip.title,
            price: trip.price,
            nights: trip.nights,
            imageFile: file,
            assetImagePath: null,
            date: trip.date,
            description: trip.description,
          );
          if (trip.isLiked) {
            await _repository.toggleLike(saved.id);
          }
        } else if (trip.imagePath.startsWith('images/')) {
          await _repository.addTrip(
            title: trip.title,
            price: trip.price,
            nights: trip.nights,
            imageFile: null,
            assetImagePath: trip.imagePath,
            date: trip.date,
            description: trip.description,
          );
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
    File? imageFile,
    String? assetImagePath,
    required DateTime date,
    String description = '',
  }) async {
    final trip = await _repository.addTrip(
      title: title,
      price: price,
      nights: nights,
      imageFile: imageFile,
      assetImagePath: assetImagePath,
      date: date,
      description: description,
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
    File? imageFile,
    String? existingImagePath,
    String? assetImagePath,
    required DateTime date,
    String description = '',
    bool? isLiked,
  }) async {
    final trip = await _repository.updateTrip(
      id,
      title: title,
      price: price,
      nights: nights,
      imageFile: imageFile,
      existingImagePath: existingImagePath,
      assetImagePath: assetImagePath,
      date: date,
      description: description,
      isLiked: isLiked,
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

  List<Trip> get filteredTrips {
    if (_searchQuery.isEmpty) return _trips;
    final lower = _searchQuery.toLowerCase();
    return _trips
        .where((t) =>
            t.title.toLowerCase().contains(lower) ||
            t.description.toLowerCase().contains(lower))
        .toList();
  }

  Trip? getTripById(String id) {
    try {
      return _trips.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
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
