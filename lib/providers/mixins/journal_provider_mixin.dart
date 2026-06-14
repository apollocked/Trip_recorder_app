import 'package:flutter/material.dart';
import '../../data/repositories/journal_repository.dart';
import '../../model/journal_entry.dart';

mixin JournalProviderMixin on ChangeNotifier {
  final JournalRepository _journalRepository = JournalRepository();
  final Map<String, List<JournalEntry>> _journalCache = {};

  Future<List<JournalEntry>> getJournalEntries(String tripId) async {
    if (_journalCache.containsKey(tripId)) return _journalCache[tripId]!;
    final entries = await _journalRepository.getEntries(tripId);
    _journalCache[tripId] = entries;
    return entries;
  }

  Future<JournalEntry> addJournalEntry({
    required String tripId,
    required DateTime date,
    required String title,
    String text = '',
    List<String>? imagePaths,
  }) async {
    final entry = await _journalRepository.addEntry(
      tripId: tripId,
      date: date,
      title: title,
      text: text,
      imagePaths: imagePaths,
    );
    _journalCache[tripId] = [...(_journalCache[tripId] ?? []), entry];
    notifyListeners();
    return entry;
  }

  Future<void> updateJournalEntry(JournalEntry entry) async {
    await _journalRepository.updateEntry(entry);
    final list = _journalCache[entry.tripId];
    if (list != null) {
      final idx = list.indexWhere((e) => e.id == entry.id);
      if (idx != -1) {
        list[idx] = entry;
        notifyListeners();
      }
    }
  }

  Future<void> deleteJournalEntry(String tripId, String entryId) async {
    await _journalRepository.deleteEntry(entryId);
    final list = _journalCache[tripId];
    if (list != null) {
      list.removeWhere((e) => e.id == entryId);
      notifyListeners();
    }
  }

  Future<void> deleteAllTripJournalEntries(String tripId) async {
    await _journalRepository.deleteAllTripEntries(tripId);
    _journalCache.remove(tripId);
    notifyListeners();
  }

  void clearJournalCache(String tripId) {
    _journalCache.remove(tripId);
  }
}
