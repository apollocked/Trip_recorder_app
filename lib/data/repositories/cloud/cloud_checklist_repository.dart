import 'package:animations_in_flutter/model/checklist_item.dart';
import 'package:animations_in_flutter/services/supabase_service.dart';

class CloudChecklistRepository {
  final SupabaseService _svc = SupabaseService();

  Future<List<ChecklistItem>> getChecklistItems(String tripId) async {
    if (!_svc.isLoggedIn) return [];
    final data = await _svc.client
        .from('cloud_checklist')
        .select()
        .eq('trip_id', tripId)
        .eq('user_id', _svc.userId!);
    return (data as List).map((m) {
      return ChecklistItem(
        id: m['id'] as String,
        tripId: m['trip_id'] as String,
        title: m['title'] as String,
        isChecked: (m['is_checked'] as bool?) ?? false,
        category: (m['category'] as String?) ?? 'general',
      );
    }).toList();
  }

  Future<ChecklistItem> addItem({
    required String tripId,
    required String title,
    String category = 'general',
  }) async {
    final item = ChecklistItem(tripId: tripId, title: title, category: category);
    final map = item.toMap()
      ..['user_id'] = _svc.userId
      ..['is_checked'] = item.isChecked;
    await _svc.client.from('cloud_checklist').insert(map);
    return item;
  }

  Future<void> toggleItem(String id, bool isChecked) async {
    await _svc.client
        .from('cloud_checklist')
        .update({'is_checked': isChecked})
        .eq('id', id)
        .eq('user_id', _svc.userId!);
  }

  Future<void> deleteItem(String id) async {
    await _svc.client
        .from('cloud_checklist')
        .delete()
        .eq('id', id)
        .eq('user_id', _svc.userId!);
  }

  Future<void> deleteAllTripItems(String tripId) async {
    await _svc.client
        .from('cloud_checklist')
        .delete()
        .eq('trip_id', tripId)
        .eq('user_id', _svc.userId!);
  }
}
