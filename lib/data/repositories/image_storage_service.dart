import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../core/constants.dart';

class ImageStorageService {
  Future<Directory> get _imageDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, AppConstants.tripImagesDir));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<String> saveImage(File sourceFile, String tripId, {int index = 0}) async {
    final dir = await _imageDir;
    final extension = p.extension(sourceFile.path).isNotEmpty
        ? p.extension(sourceFile.path)
        : '.jpg';
    final targetPath = p.join(dir.path, '${tripId}_$index$extension');
    await sourceFile.copy(targetPath);
    return targetPath;
  }

  Future<List<String>> saveMultipleImages(List<File> sourceFiles, String tripId) async {
    final paths = <String>[];
    for (int i = 0; i < sourceFiles.length; i++) {
      final path = await saveImage(sourceFiles[i], tripId, index: i);
      paths.add(path);
    }
    return paths;
  }

  Future<void> deleteImage(String imagePath) async {
    if (imagePath.startsWith('images/')) return;
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> deleteAllTripImages(String tripId) async {
    final dir = await _imageDir;
    if (!await dir.exists()) return;
    final entities = await dir.list().toList();
    for (final entity in entities) {
      if (entity is File && p.basenameWithoutExtension(entity.path) == tripId) {
        await entity.delete();
      }
    }
  }

  bool isAssetImage(String imagePath) {
    return imagePath.startsWith('images/');
  }
}
