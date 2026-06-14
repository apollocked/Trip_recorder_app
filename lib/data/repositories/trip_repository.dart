import 'dart:io';
import '../../model/trip.dart';
import '../../model/trip_category.dart';
import '../database/app_database.dart';
import 'image_storage_service.dart';

class TripRepository {
  final AppDatabase _database = AppDatabase();
  final ImageStorageService _imageService = ImageStorageService();

  Future<List<Trip>> getAllTrips() async {
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
  }) async {
    final trip = Trip(
      title: title,
      price: price,
      nights: nights,
      date: date,
      description: description,
      category: category,
      rating: rating,
    );

    final savedPaths = <String>[];
    if (imageFiles.isNotEmpty) {
      final paths = await _imageService.saveMultipleImages(imageFiles, trip.id);
      savedPaths.addAll(paths);
    }
    savedPaths.addAll(assetImagePaths);

    final savedTrip = trip.copyWith(imagePaths: savedPaths);
    await _database.insertTrip(savedTrip);
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
  }) async {
    final oldTrip = await _database.getTripById(id);
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
      final newPaths = await _imageService.saveMultipleImages(imageFiles, id);
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
    );

    await _database.updateTrip(updatedTrip);
    return updatedTrip;
  }

  Future<void> deleteTrip(String id) async {
    await _imageService.deleteAllTripImages(id);
    await _database.deleteTrip(id);
  }

  Future<void> toggleLike(String id) async {
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
