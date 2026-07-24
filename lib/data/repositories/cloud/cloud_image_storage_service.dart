import 'dart:io';
import 'package:animations_in_flutter/services/supabase_service.dart';
import 'package:path/path.dart' as p;

class CloudImageStorageService {
  final SupabaseService _svc = SupabaseService();
  static const String _bucket = 'trip-images';

  String _userFolder() => '${_svc.userId}/';

  Future<String> uploadImage(File file, String tripId, {int index = 0}) async {
    final ext = p.extension(file.path).isNotEmpty ? p.extension(file.path) : '.jpg';
    final path = '${_userFolder()}${tripId}_$index$ext';
    await _svc.client.storage.from(_bucket).upload(path, file);
    return path;
  }

  Future<List<String>> uploadMultiple(
    List<File> files,
    String tripId,
  ) async {
    final paths = <String>[];
    for (int i = 0; i < files.length; i++) {
      final path = await uploadImage(files[i], tripId, index: i);
      paths.add(path);
    }
    return paths;
  }

  Future<String> getSignedUrl(String storagePath) async {
    final signed = await _svc.client.storage
        .from(_bucket)
        .createSignedUrl(storagePath, 3600 * 24 * 7);
    return signed;
  }

  Future<List<String>> getSignedUrls(List<String> storagePaths) async {
    final urls = <String>[];
    for (final path in storagePaths) {
      if (path.startsWith('images/')) {
        urls.add(path);
        continue;
      }
      try {
        final url = await getSignedUrl(path);
        urls.add(url);
      } catch (_) {
        urls.add(path);
      }
    }
    return urls;
  }

  Future<void> deleteImage(String storagePath) async {
    if (storagePath.startsWith('images/')) return;
    try {
      await _svc.client.storage.from(_bucket).remove([storagePath]);
    } catch (_) {}
  }

  Future<void> deleteAllTripImages(String tripId) async {
    final prefix = '${_userFolder()}${tripId}_';
    try {
      final files = await _svc.client.storage.from(_bucket).list(path: _userFolder());
      final toDelete = files
          .where((f) => f.name.startsWith('${tripId}_'))
          .map((f) => '${_userFolder()}${f.name}')
          .toList();
      if (toDelete.isNotEmpty) {
        await _svc.client.storage.from(_bucket).remove(toDelete);
      }
    } catch (_) {}
  }

  bool isAssetImage(String imagePath) => imagePath.startsWith('images/');
}
