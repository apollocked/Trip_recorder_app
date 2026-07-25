import 'package:animations_in_flutter/services/supabase_service.dart';
import '../../../model/trip_template.dart';

class CloudTemplateRepository {
  final SupabaseService _svc = SupabaseService();

  Future<List<TripTemplate>> getTemplates() async {
    if (!_svc.isLoggedIn) return [];
    final data = await _svc.client
        .from('cloud_templates')
        .select()
        .eq('user_id', _svc.userId!)
        .order('name');
    return data.map((m) => TripTemplate.fromMap(m)).toList();
  }

  Future<void> addTemplate(TripTemplate template) async {
    if (!_svc.isLoggedIn) return;
    await _svc.client.from('cloud_templates').insert({
      ...template.toMap(),
      'user_id': _svc.userId,
    });
  }

  Future<void> deleteTemplate(String id) async {
    if (!_svc.isLoggedIn) return;
    await _svc.client
        .from('cloud_templates')
        .delete()
        .eq('id', id)
        .eq('user_id', _svc.userId!);
  }
}
