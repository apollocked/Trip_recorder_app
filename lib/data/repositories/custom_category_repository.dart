import '../database/app_database.dart';
import '../../model/custom_category.dart';
import '../../services/supabase_service.dart';
import 'cloud/cloud_custom_category_repository.dart';

class CustomCategoryRepository {
  final AppDatabase _database = AppDatabase();
  final CloudCustomCategoryRepository _cloud = CloudCustomCategoryRepository();

  bool get _isCloud => SupabaseService().isLoggedIn;

  Future<List<CustomCategory>> getCategories(String type) async {
    if (_isCloud) return _cloud.getCategories(type);
    final db = await _database.database;
    final maps = await db.query(
      'custom_categories',
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'name ASC',
    );
    return maps.map((m) => CustomCategory.fromMap(m)).toList();
  }

  Future<void> addCategory(CustomCategory category) async {
    if (_isCloud) return _cloud.addCategory(category);
    final db = await _database.database;
    await db.insert('custom_categories', category.toMap());
  }

  Future<void> updateCategory(CustomCategory category) async {
    if (_isCloud) return _cloud.updateCategory(category);
    final db = await _database.database;
    await db.update(
      'custom_categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(String id) async {
    if (_isCloud) return _cloud.deleteCategory(id);
    final db = await _database.database;
    await db.delete('custom_categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getCount(String type) async {
    if (_isCloud) return _cloud.getCount(type);
    final db = await _database.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM custom_categories WHERE type = ?',
      [type],
    );
    return (result.first['count'] as int?) ?? 0;
  }
}
