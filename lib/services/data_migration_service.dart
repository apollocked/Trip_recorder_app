import 'dart:convert';
import 'dart:io';
import 'package:animations_in_flutter/core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/trip_repository.dart';
import '../model/trip.dart';
import 'package:flutter/foundation.dart';

class DataMigrationService {
  final TripRepository _repository;

  DataMigrationService(this._repository);

  Future<void> migrateIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyMigrated =
        prefs.getBool(AppConstants.prefDataMigrated) ?? false;
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
          currency: trip.currency,
          reminderDate: trip.reminderDate,
        );
        if (trip.isLiked) {
          await _repository.toggleLike(saved.id);
        }
      }
      await prefs.remove('user_trips');
      await prefs.setBool(AppConstants.prefDataMigrated, true);
    } catch (e) {
      debugPrint('Migration error: $e');
    }
  }
}
