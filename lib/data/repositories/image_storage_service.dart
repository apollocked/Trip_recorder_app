import 'dart:io';
import 'package:animations_in_flutter/core/constants.dart';
import 'package:animations_in_flutter/services/supabase_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'cloud/cloud_image_storage_service.dart';

class ImageStorageService {
  final CloudImageStorageService _cloud = CloudImageStorageService();

  bool get _isCloud => SupabaseService().isLoggedIn;

  Future<Directory> get _imageDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, AppConstants.tripImagesDir));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<String> saveImage(
    File sourceFile,
    String tripId, {
    int index = 0,
  }) async {
    if (_isCloud) return _cloud.uploadImage(sourceFile, tripId, index: index);
    final dir = await _imageDir;
    final extension = p.extension(sourceFile.path).isNotEmpty
        ? p.extension(sourceFile.path)
        : '.jpg';
    final targetPath = p.join(dir.path, '${tripId}_$index$extension');
    await sourceFile.copy(targetPath);
    return targetPath;
  }

  Future<List<String>> saveMultipleImages(
    List<File> sourceFiles,
    String tripId,
  ) async {
    if (_isCloud) return _cloud.uploadMultiple(sourceFiles, tripId);
    final futures = <Future<String>>[];
    for (int i = 0; i < sourceFiles.length; i++) {
      futures.add(saveImage(sourceFiles[i], tripId, index: i));
    }
    return Future.wait(futures);
  }

  Future<void> deleteImage(String imagePath) async {
    if (_isCloud) return _cloud.deleteImage(imagePath);
    if (imagePath.startsWith('images/')) return;
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> deleteAllTripImages(String tripId) async {
    if (_isCloud) return _cloud.deleteAllTripImages(tripId);
    final dir = await _imageDir;
    if (!await dir.exists()) return;
    final prefix = '${tripId}_';
    final entities = await dir.list().toList();
    for (final entity in entities) {
      if (entity is File && p.basename(entity.path).startsWith(prefix)) {
        await entity.delete();
      }
    }
  }

  bool isAssetImage(String imagePath) {
    return imagePath.startsWith('images/');
  }
}
