import '../database/app_database.dart';
import '../../model/journal_entry.dart';
import '../../services/supabase_service.dart';
import 'cloud/cloud_journal_repository.dart';

class JournalRepository {
  final AppDatabase _database = AppDatabase();
  final CloudJournalRepository _cloud = CloudJournalRepository();

  bool get _isCloud => SupabaseService().isLoggedIn;

  Future<List<JournalEntry>> getEntries(String tripId) async {
    if (_isCloud) return _cloud.getEntries(tripId);
    final db = await _database.database;
    final maps = await db.query(
      'journal_entries',
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'date DESC',
    );
    return maps.map((map) => JournalEntry.fromMap(map)).toList();
  }

  Future<JournalEntry> addEntry({
    required String tripId,
    required DateTime date,
    required String title,
    String text = '',
    List<String>? imagePaths,
  }) async {
    if (_isCloud) {
      return _cloud.addEntry(tripId: tripId, date: date, title: title, text: text, imagePaths: imagePaths);
    }
    final entry = JournalEntry(
      tripId: tripId,
      date: date,
      title: title,
      text: text,
      imagePaths: imagePaths,
    );
    final db = await _database.database;
    await db.insert('journal_entries', entry.toMap());
    return entry;
  }

  Future<void> updateEntry(JournalEntry entry) async {
    if (_isCloud) return _cloud.updateEntry(entry);
    final db = await _database.database;
    await db.update(
      'journal_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<void> deleteEntry(String id) async {
    if (_isCloud) return _cloud.deleteEntry(id);
    final db = await _database.database;
    await db.delete('journal_entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllTripEntries(String tripId) async {
    if (_isCloud) return _cloud.deleteAllTripEntries(tripId);
    final db = await _database.database;
    await db.delete('journal_entries', where: 'trip_id = ?', whereArgs: [tripId]);
  }
}
