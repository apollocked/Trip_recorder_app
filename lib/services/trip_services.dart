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
    } else {
      // Seed default trips on a fresh install
      _trips = [
        Trip(title: 'Beach Paradise', price: '350', nights: '3', img: 'images/beach.png', date: DateTime(2026, 06, 15), description: 'Relax on the pristine white sands and enjoy the crystal clear waters.'),
        Trip(title: 'City Break', price: '400', nights: '5', img: 'images/city.png', date: DateTime(2026, 06, 20), description: 'Explore the bustling city life, visit museums, and enjoy fine dining.'),
        Trip(title: 'Ski Adventure', price: '750', nights: '2', img: 'images/ski.png', date: DateTime(2026, 06, 25), description: 'Hit the slopes and experience the thrill of skiing on fresh powder.'),
        Trip(title: 'Space Blast', price: '600', nights: '4', img: 'images/space.png', date: DateTime(2026, 06, 30), description: 'A once in a lifetime journey beyond the stars.'),
      ];
      final String encoded = jsonEncode(_trips.map((t) => t.toJson()).toList());
      await prefs.setString('user_trips', encoded);
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

  // Update an entire trip and persist
  Future<void> updateTrip(int index, Trip newTrip) async {
    if (index < 0 || index >= _trips.length) return;
    
    _trips[index] = newTrip;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_trips.map((t) => t.toJson()).toList());
    await prefs.setString('user_trips', encoded);
  }
}
