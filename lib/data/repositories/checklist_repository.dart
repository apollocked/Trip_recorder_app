import '../database/app_database.dart';
import '../../model/checklist_item.dart';

class ChecklistRepository {
  final AppDatabase _database = AppDatabase();

  Future<List<ChecklistItem>> getChecklistItems(String tripId) async {
    final db = await _database.database;
    final maps = await db.query(
      'checklist_items',
      where: 'trip_id = ?',
      whereArgs: [tripId],
      orderBy: 'rowid ASC',
    );
    return maps.map((map) => ChecklistItem.fromMap(map)).toList();
  }

  Future<ChecklistItem> addItem({
    required String tripId,
    required String title,
    String category = 'general',
  }) async {
    final item = ChecklistItem(tripId: tripId, title: title, category: category);
    final db = await _database.database;
    await db.insert('checklist_items', item.toMap());
    return item;
  }

  Future<void> toggleItem(String id, bool isChecked) async {
    final db = await _database.database;
    await db.update(
      'checklist_items',
      {'is_checked': isChecked ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteItem(String id) async {
    final db = await _database.database;
    await db.delete('checklist_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAllTripItems(String tripId) async {
    final db = await _database.database;
    await db.delete('checklist_items', where: 'trip_id = ?', whereArgs: [tripId]);
  }
}
