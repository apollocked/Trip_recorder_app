import '../database/app_database.dart';
import '../../model/trip_template.dart';
import '../../services/supabase_service.dart';
import 'cloud/cloud_template_repository.dart';

class TemplateRepository {
  final AppDatabase _database = AppDatabase();
  final CloudTemplateRepository _cloud = CloudTemplateRepository();

  bool get _isCloud => SupabaseService().isLoggedIn;

  Future<List<TripTemplate>> getTemplates() async {
    if (_isCloud) return _cloud.getTemplates();
    final db = await _database.database;
    final maps = await db.query('trip_templates', orderBy: 'name ASC');
    return maps.map((m) => TripTemplate.fromMap(m)).toList();
  }

  Future<void> addTemplate(TripTemplate template) async {
    if (_isCloud) return _cloud.addTemplate(template);
    final db = await _database.database;
    await db.insert('trip_templates', template.toMap());
  }

  Future<void> deleteTemplate(String id) async {
    if (_isCloud) return _cloud.deleteTemplate(id);
    final db = await _database.database;
    await db.delete('trip_templates', where: 'id = ?', whereArgs: [id]);
  }
}
