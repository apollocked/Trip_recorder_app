import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animations_in_flutter/model/trip.dart';

class TripService extends ChangeNotifier {
  List<Trip> _trips = [];
  List<Trip> get trips => _trips;
  bool _isloading = false;
  bool get isLoading => _isloading;

  TripService() {
    loadTrips();
  }

  Future<void> loadTrips() async {
    _isloading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final String? tripsJson = prefs.getString('user_trips');

    // Artificial delay to make the shimmer effect visible and smooth
    await Future.delayed(const Duration(seconds: 1));

    if (tripsJson != null) {
      final List<dynamic> decoded = jsonDecode(tripsJson);
      _trips = decoded.map((item) => Trip.fromJson(item)).toList();
    } else {
      _trips = [
        Trip(
          title: 'Beach Paradise',
          price: '350',
          nights: '3',
          img: 'images/beach.png',
          date: DateTime(2026, 06, 15),
          description:
              'Relax on the pristine white sands and enjoy the crystal clear waters.',
        ),
        Trip(
          title: 'City Break',
          price: '400',
          nights: '5',
          img: 'images/city.png',
          date: DateTime(2026, 06, 20),
          description:
              'Explore the bustling city life, visit museums, and enjoy fine dining.',
        ),
      ];
      await _saveToPrefs();
    }
    _isloading = false;
    notifyListeners();
  }

  Future<void> refresh() async => await loadTrips();

  Future<void> addTrip(Trip trip) async {
    _trips.add(trip);
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> removeTrip(int index) async {
    if (index < 0 || index >= _trips.length) return;
    _trips.removeAt(index);
    await _saveToPrefs();
    notifyListeners();
  }

  // ADDED BACK: This fixes the "updateTrip isn't defined" error
  Future<void> updateTrip(int index, Trip newTrip) async {
    if (index < 0 || index >= _trips.length) return;
    _trips[index] = newTrip;
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> toggleLike(int index) async {
    if (index < 0 || index >= _trips.length) return;
    _trips[index].isLiked = !_trips[index].isLiked;
    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_trips.map((t) => t.toJson()).toList());
    await prefs.setString('user_trips', encoded);
  }
}
