import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animations_in_flutter/model/trip.dart';

class TripService extends ChangeNotifier {
  List<Trip> _trips = [];
  List<Trip> get trips => _trips;
  bool _isFirstTime = true;
  bool get isFirstTime => _isFirstTime;
  bool _isloading = false;
  bool get isLoading => _isloading;

  TripService() {
    loadTrips();
  }

  Future<void> loadTrips() async {
    _isloading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? tripsJson = prefs.getString('user_trips');

      if (tripsJson != null) {
        final List<dynamic> decoded = jsonDecode(tripsJson);
        _trips = decoded.map((item) => Trip.fromJson(item)).toList();
      } else {
        await _saveToPrefs();
      }
    } catch (e) {
      debugPrint('Error loading trips from SharedPreferences: $e');
    } finally {
      _isloading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async => await loadTrips();

  Future<void> addTrip(Trip trip) async {
    _trips.add(trip);
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> removeTrip(int index) async {
    if (index < 0 || index >= _trips.length) return;
    _trips.removeAt(index);
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> updateTrip(int index, Trip newTrip) async {
    if (index < 0 || index >= _trips.length) return;
    _trips[index] = newTrip;
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> toggleLike(int index) async {
    if (index < 0 || index >= _trips.length) return;
    _trips[index].isLiked = !_trips[index].isLiked;

    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(_trips.map((t) => t.toJson()).toList());
      await prefs.setString('user_trips', encoded);
    } catch (e) {
      debugPrint('Error saving trips to SharedPreferences: $e');
    }
  }

  Future<void> checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstTime = prefs.getBool('is_first_run') ?? true;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_run', false);
    _isFirstTime = false;
    notifyListeners();
  }
}
