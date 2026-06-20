import 'package:flutter/material.dart';
import '../../data/repositories/checklist_repository.dart';
import '../../model/checklist_item.dart';

mixin ChecklistProviderMixin on ChangeNotifier {
  final ChecklistRepository _checklistRepository = ChecklistRepository();
  final Map<String, List<ChecklistItem>> _checklistCache = {};

  Future<List<ChecklistItem>> getChecklistItems(String tripId) async {
    if (_checklistCache.containsKey(tripId)) return _checklistCache[tripId]!;
    final items = await _checklistRepository.getChecklistItems(tripId);
    _checklistCache[tripId] = items;
    return items;
  }

  Future<void> addChecklistItem({
    required String tripId,
    required String title,
    String category = 'general',
  }) async {
    final item = await _checklistRepository.addItem(
      tripId: tripId,
      title: title,
      category: category,
    );
    _checklistCache[tripId] = [...(_checklistCache[tripId] ?? []), item];
    notifyListeners();
  }

  Future<void> toggleChecklistItem(String tripId, String itemId, bool isChecked) async {
    await _checklistRepository.toggleItem(itemId, isChecked);
    final list = _checklistCache[tripId];
    if (list != null) {
      final idx = list.indexWhere((i) => i.id == itemId);
      if (idx != -1) {
        list[idx] = list[idx].copyWith(isChecked: isChecked);
        notifyListeners();
      }
    }
  }

  Future<void> deleteChecklistItem(String tripId, String itemId) async {
    await _checklistRepository.deleteItem(itemId);
    final list = _checklistCache[tripId];
    if (list != null) {
      list.removeWhere((i) => i.id == itemId);
      notifyListeners();
    }
  }

  Future<void> deleteAllTripChecklistItems(String tripId) async {
    await _checklistRepository.deleteAllTripItems(tripId);
    _checklistCache.remove(tripId);
    notifyListeners();
  }

  void clearChecklistCache(String tripId) {
    _checklistCache.remove(tripId);
  }
}
