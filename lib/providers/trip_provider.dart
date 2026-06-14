import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../data/repositories/trip_repository.dart';
import '../model/trip.dart';
import '../model/trip_category.dart';
import '../services/data_migration_service.dart';
import '../services/notification_service.dart';
import 'mixins/checklist_provider_mixin.dart';
import 'mixins/expense_provider_mixin.dart';
import 'mixins/journal_provider_mixin.dart';
import 'mixins/trip_statistics.dart';

class TripProvider extends ChangeNotifier
    with ExpenseProviderMixin, ChecklistProviderMixin, JournalProviderMixin {
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
    await DataMigrationService(_repository).migrateIfNeeded();
    await loadTrips();
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
    String currency = 'USD',
    DateTime? reminderDate,
  }) async {
    final trip = await _repository.addTrip(
      title: title, price: price, nights: nights,
      imageFiles: imageFiles, assetImagePaths: assetImagePaths,
      date: date, description: description,
      category: category, rating: rating,
      currency: currency, reminderDate: reminderDate,
    );
    _trips.insert(0, trip);
    _scheduleReminder(trip);
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
    String? currency,
    DateTime? reminderDate,
  }) async {
    await NotificationService().cancelTripReminder(id);
    final trip = await _repository.updateTrip(id,
      title: title, price: price, nights: nights,
      imageFiles: imageFiles, existingImagePaths: existingImagePaths,
      assetImagePaths: assetImagePaths, date: date, description: description,
      isLiked: isLiked, category: category, rating: rating,
      currency: currency, reminderDate: reminderDate,
    );
    final index = _trips.indexWhere((t) => t.id == id);
    if (index != -1) {
      _trips[index] = trip;
      _scheduleReminder(trip);
      notifyListeners();
    }
    return trip;
  }

  Future<void> deleteTrip(String id) async {
    await NotificationService().cancelTripReminder(id);
    await _repository.deleteTrip(id);
    _trips.removeWhere((t) => t.id == id);
    clearExpensesCache(id);
    clearChecklistCache(id);
    clearJournalCache(id);
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

  void setSearchQuery(String query) { _searchQuery = query; notifyListeners(); }
  void setCategoryFilter(TripCategory? category) { _categoryFilter = category; notifyListeners(); }
  void setSortBy(String sort) { _sortBy = sort; notifyListeners(); }

  List<Trip> get filteredTrips {
    var result = List<Trip>.from(_trips);

    if (_searchQuery.isNotEmpty) {
      final lower = _searchQuery.toLowerCase();
      result = result.where((t) =>
          t.title.toLowerCase().contains(lower) ||
          t.description.toLowerCase().contains(lower)).toList();
    }

    if (_categoryFilter != null) {
      result = result.where((t) => t.category == _categoryFilter).toList();
    }

    switch (_sortBy) {
      case 'date_asc': result.sort((a, b) => a.date.compareTo(b.date)); break;
      case 'date_desc': result.sort((a, b) => b.date.compareTo(a.date)); break;
      case 'price_asc': result.sort((a, b) => a.price.compareTo(b.price)); break;
      case 'price_desc': result.sort((a, b) => b.price.compareTo(a.price)); break;
      case 'rating_desc': result.sort((a, b) => b.rating.compareTo(a.rating)); break;
      case 'title_asc': result.sort((a, b) => a.title.compareTo(b.title)); break;
    }

    return result;
  }

  Trip? getTripById(String id) {
    try { return _trips.firstWhere((t) => t.id == id); } catch (_) { return null; }
  }

  Map<String, dynamic> get statistics => TripStatistics.fromTrips(_trips).toMap();

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

  void _scheduleReminder(Trip trip) {
    if (trip.reminderDate != null) {
      NotificationService().scheduleTripReminder(
        tripId: trip.id,
        tripTitle: trip.title,
        remindAt: trip.reminderDate!,
      );
    }
  }
}
