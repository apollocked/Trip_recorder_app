import 'dart:convert';
import 'dart:io';
import '../../model/trip.dart';
import '../../model/trip_category.dart';
import '../../services/supabase_service.dart';
import '../database/app_database.dart';
import 'cloud/cloud_trip_repository.dart';
import 'cloud/cloud_image_storage_service.dart';
import 'image_storage_service.dart';

class TripRepository {
  final AppDatabase _database = AppDatabase();
  final ImageStorageService _imageService = ImageStorageService();
  final CloudTripRepository _cloudTrips = CloudTripRepository();
  final CloudImageStorageService _cloudImages = CloudImageStorageService();

  bool get _isCloud => SupabaseService().isLoggedIn;

  Future<List<Trip>> getAllTrips() async {
    if (_isCloud) return _cloudTrips.getAllTrips();
    return await _database.getAllTrips();
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
    final trip = Trip(
      title: title,
      price: price,
      nights: nights,
      date: date,
      description: description,
      category: category,
      rating: rating,
      currency: currency,
      reminderDate: reminderDate,
    );

    if (_isCloud) {
      final savedPaths = <String>[];
      if (imageFiles.isNotEmpty) {
        final cloudPaths = await _cloudImages.uploadMultiple(imageFiles, trip.id);
        savedPaths.addAll(cloudPaths);
      }
      savedPaths.addAll(assetImagePaths);
      final savedTrip = trip.copyWith(imagePaths: savedPaths);
      await _cloudTrips.insertTrip(savedTrip);
      return savedTrip;
    }

    final savedPaths = <String>[];
    if (imageFiles.isNotEmpty) {
      final paths = await _imageService.saveMultipleImages(imageFiles, trip.id);
      savedPaths.addAll(paths);
    }
    savedPaths.addAll(assetImagePaths);

    final savedTrip = trip.copyWith(imagePaths: savedPaths);

    try {
      await _database.insertTrip(savedTrip);
    } catch (e) {
      for (final path in savedPaths) {
        if (!_imageService.isAssetImage(path)) {
          await _imageService.deleteImage(path);
        }
      }
      rethrow;
    }

    return savedTrip;
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
    final oldTrip = _isCloud
        ? (await _cloudTrips.getAllTrips()).where((t) => t.id == id).firstOrNull
        : await _database.getTripById(id);
    if (oldTrip == null) throw Exception('Trip not found');

    final finalPaths = <String>[];

    if (existingImagePaths != null) {
      for (final path in existingImagePaths) {
        if (!_imageService.isAssetImage(path) && !File(path).existsSync()) {
          continue;
        }
        finalPaths.add(path);
      }
    }

    if (assetImagePaths != null) {
      finalPaths.addAll(assetImagePaths);
    }

    if (imageFiles != null && imageFiles.isNotEmpty) {
      final newPaths = _isCloud
          ? await _cloudImages.uploadMultiple(imageFiles, id)
          : await _imageService.saveMultipleImages(imageFiles, id);
      finalPaths.addAll(newPaths);
    }

    if (finalPaths.isEmpty) {
      finalPaths.addAll(oldTrip.imagePaths);
    }

    final updatedTrip = Trip(
      id: id,
      title: title,
      price: price,
      nights: nights,
      imagePaths: finalPaths,
      date: date,
      description: description,
      isLiked: isLiked ?? oldTrip.isLiked,
      createdAt: oldTrip.createdAt,
      category: category ?? oldTrip.category,
      rating: rating ?? oldTrip.rating,
      currency: currency ?? oldTrip.currency,
      reminderDate: reminderDate ?? oldTrip.reminderDate,
    );

    if (_isCloud) {
      await _cloudTrips.updateTrip(updatedTrip);
    } else {
      await _database.updateTrip(updatedTrip);
    }

    final removedPaths = oldTrip.imagePaths
        .where((p) => !finalPaths.contains(p))
        .toList();
    for (final path in removedPaths) {
      if (_isCloud) {
        await _cloudImages.deleteImage(path);
      } else {
        await _imageService.deleteImage(path);
      }
    }

    return updatedTrip;
  }

  Future<void> deleteTrip(String id) async {
    if (_isCloud) {
      await _cloudImages.deleteAllTripImages(id);
      return _cloudTrips.deleteTrip(id);
    }
    final trip = await _database.getTripById(id);
    if (trip != null) {
      await _imageService.deleteAllTripImages(id);
      final db = await _database.database;
      final journalMaps = await db.query(
        'journal_entries',
        columns: ['image_paths'],
        where: 'trip_id = ?',
        whereArgs: [id],
      );
      for (final map in journalMaps) {
        final pathsJson = map['image_paths'] as String? ?? '[]';
        final List<dynamic> imagePaths = jsonDecode(pathsJson);
        for (final path in imagePaths) {
          if (path is String && !_imageService.isAssetImage(path)) {
            await _imageService.deleteImage(path);
          }
        }
      }
    }
    await _database.deleteTrip(id);
  }

  Future<void> toggleLike(String id) async {
    if (_isCloud) return _cloudTrips.toggleLike(id);
    await _database.toggleLike(id);
  }

  Future<List<Trip>> searchTrips(String query) async {
    if (query.isEmpty) return await getAllTrips();
    final all = await getAllTrips();
    final lower = query.toLowerCase();
    return all
        .where((t) =>
            t.title.toLowerCase().contains(lower) ||
            t.description.toLowerCase().contains(lower))
        .toList();
  }
}
