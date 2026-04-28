import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animations_in_flutter/model/trip.dart';

class TripService extends ChangeNotifier {
  List<Trip> _trips = [];
  List<Trip> get trips => _trips;

  TripService() {
    loadTrips();
  }

  // Load trips from Local Storage
  Future<void> loadTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tripsJson = prefs.getString('user_trips');

    if (tripsJson != null) {
      final List<dynamic> decoded = jsonDecode(tripsJson);
      _trips = decoded.map((item) => Trip.fromJson(item)).toList();
    }
    notifyListeners();
  }

  // Save and add new trip
  Future<void> addTrip(Trip trip) async {
    _trips.add(trip);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_trips.map((t) => t.toJson()).toList());
    await prefs.setString('user_trips', encoded);
  }

  // Remove a trip by index and persist
  Future<void> removeTrip(int index) async {
    if (index < 0 || index >= _trips.length) return;
    _trips.removeAt(index);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_trips.map((t) => t.toJson()).toList());
    await prefs.setString('user_trips', encoded);
  }

  // Toggle like status and persist
  Future<void> toggleLike(int index) async {
    if (index < 0 || index >= _trips.length) return;
    _trips[index].isLiked = !_trips[index].isLiked;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_trips.map((t) => t.toJson()).toList());
    await prefs.setString('user_trips', encoded);
  }
}
