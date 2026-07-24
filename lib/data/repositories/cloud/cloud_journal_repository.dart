import 'dart:convert';
import 'package:animations_in_flutter/model/journal_entry.dart';
import 'package:animations_in_flutter/services/supabase_service.dart';

class CloudJournalRepository {
  final SupabaseService _svc = SupabaseService();

  Future<List<JournalEntry>> getEntries(String tripId) async {
    if (!_svc.isLoggedIn) return [];
    final data = await _svc.client
        .from('cloud_journal')
        .select()
        .eq('trip_id', tripId)
        .eq('user_id', _svc.userId!);
    return (data as List).map((m) => _fromCloudMap(m)).toList();
  }

  Future<JournalEntry> addEntry({
    required String tripId,
    required DateTime date,
    required String title,
    String text = '',
    List<String>? imagePaths,
  }) async {
    final entry = JournalEntry(
      tripId: tripId,
      date: date,
      title: title,
      text: text,
      imagePaths: imagePaths,
    );
    final map = entry.toMap()
      ..['user_id'] = _svc.userId
      ..['image_paths'] = entry.imagePaths;
    await _svc.client.from('cloud_journal').insert(map);
    return entry;
  }

  Future<void> updateEntry(JournalEntry entry) async {
    final map = entry.toMap()..['image_paths'] = entry.imagePaths;
    await _svc.client
        .from('cloud_journal')
        .update(map)
        .eq('id', entry.id)
        .eq('user_id', _svc.userId!);
  }

  Future<void> deleteEntry(String id) async {
    await _svc.client
        .from('cloud_journal')
        .delete()
        .eq('id', id)
        .eq('user_id', _svc.userId!);
  }

  Future<void> deleteAllTripEntries(String tripId) async {
    await _svc.client
        .from('cloud_journal')
        .delete()
        .eq('trip_id', tripId)
        .eq('user_id', _svc.userId!);
  }

  JournalEntry _fromCloudMap(Map<String, dynamic> map) {
    List<String> paths = [];
    final raw = map['image_paths'];
    if (raw is List) {
      paths = raw.cast<String>();
    } else if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) paths = decoded.cast<String>();
      } catch (_) {}
    }
    return JournalEntry(
      id: map['id'] as String,
      tripId: map['trip_id'] as String,
      date: DateTime.parse(map['date'] as String),
      title: map['title'] as String,
      text: (map['text'] as String?) ?? '',
      imagePaths: paths,
    );
  }
}
