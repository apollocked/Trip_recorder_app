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

  Future<String> saveImage(File sourceFile, String tripId) async {
    final dir = await _imageDir;
    final extension = p.extension(sourceFile.path).isNotEmpty
        ? p.extension(sourceFile.path)
        : '.jpg';
    final targetPath = p.join(dir.path, '$tripId$extension');
    await sourceFile.copy(targetPath);
    return targetPath;
  }

  Future<void> deleteImage(String imagePath) async {
    if (imagePath.startsWith('images/')) return;
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<List<String>> getAllImagePaths() async {
    final dir = await _imageDir;
    final entities = await dir.list().toList();
    return entities
        .whereType<File>()
        .map((f) => f.path)
        .toList();
  }

  bool isAssetImage(String imagePath) {
    return imagePath.startsWith('images/');
  }
}
