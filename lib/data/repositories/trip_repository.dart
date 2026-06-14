import 'dart:io';
import '../../model/trip.dart';
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
    required File? imageFile,
    required String? assetImagePath,
    required DateTime date,
    String description = '',
  }) async {
    final trip = Trip(
      title: title,
      price: price,
      nights: nights,
      imagePath: assetImagePath ?? '',
      date: date,
      description: description,
    );

    String imagePath;
    if (imageFile != null) {
      imagePath = await _imageService.saveImage(imageFile, trip.id);
    } else if (assetImagePath != null) {
      imagePath = assetImagePath;
    } else {
      imagePath = '';
    }

    final savedTrip = trip.copyWith(imagePath: imagePath);
    await _database.insertTrip(savedTrip);
    return savedTrip;
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
    final oldTrip = await _database.getTripById(id);
    if (oldTrip == null) throw Exception('Trip not found');

    String imagePath;
    if (imageFile != null) {
      if (!_imageService.isAssetImage(oldTrip.imagePath)) {
        await _imageService.deleteImage(oldTrip.imagePath);
      }
      imagePath = await _imageService.saveImage(imageFile, id);
    } else if (assetImagePath != null) {
      imagePath = assetImagePath;
    } else if (existingImagePath != null) {
      imagePath = existingImagePath;
    } else {
      imagePath = oldTrip.imagePath;
    }

    final updatedTrip = Trip(
      id: id,
      title: title,
      price: price,
      nights: nights,
      imagePath: imagePath,
      date: date,
      description: description,
      isLiked: isLiked ?? oldTrip.isLiked,
      createdAt: oldTrip.createdAt,
    );

    await _database.updateTrip(updatedTrip);
    return updatedTrip;
  }

  Future<void> deleteTrip(String id) async {
    final trip = await _database.getTripById(id);
    if (trip == null) return;
    if (!_imageService.isAssetImage(trip.imagePath)) {
      await _imageService.deleteImage(trip.imagePath);
    }
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
