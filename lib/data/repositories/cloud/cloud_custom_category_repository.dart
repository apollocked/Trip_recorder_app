import 'package:animations_in_flutter/services/supabase_service.dart';
import '../../../model/custom_category.dart';

class CloudCustomCategoryRepository {
  final SupabaseService _svc = SupabaseService();

  Future<List<CustomCategory>> getCategories(String type) async {
    if (!_svc.isLoggedIn) return [];
    final data = await _svc.client
        .from('cloud_custom_categories')
        .select()
        .eq('user_id', _svc.userId!)
        .eq('type', type)
        .order('name');
    return data.map((m) => CustomCategory.fromMap(m)).toList();
  }

  Future<void> addCategory(CustomCategory category) async {
    if (!_svc.isLoggedIn) return;
    await _svc.client.from('cloud_custom_categories').insert({
      ...category.toMap(),
      'user_id': _svc.userId,
    });
  }

  Future<void> updateCategory(CustomCategory category) async {
    if (!_svc.isLoggedIn) return;
    await _svc.client
        .from('cloud_custom_categories')
        .update(category.toMap())
        .eq('id', category.id)
        .eq('user_id', _svc.userId!);
  }

  Future<void> deleteCategory(String id) async {
    if (!_svc.isLoggedIn) return;
    await _svc.client
        .from('cloud_custom_categories')
        .delete()
        .eq('id', id)
        .eq('user_id', _svc.userId!);
  }

  Future<int> getCount(String type) async {
    if (!_svc.isLoggedIn) return 0;
    final data = await _svc.client
        .from('cloud_custom_categories')
        .select('id')
        .eq('user_id', _svc.userId!)
        .eq('type', type);
    return data.length;
  }
}
