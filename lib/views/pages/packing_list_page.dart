import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/model/checklist_item.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/shimmer/shimmer_packing_list_page.dart';
import 'package:animations_in_flutter/views/widgets/empty_state.dart';
import 'package:animations_in_flutter/views/widgets/packing_list_item.dart';

class PackingListPage extends StatefulWidget {
  final String tripId;
  const PackingListPage({super.key, required this.tripId});

  @override
  State<PackingListPage> createState() => _PackingListPageState();
}

class _PackingListPageState extends State<PackingListPage> {
  List<ChecklistItem> _items = [];
  String _selectedCategory = 'general';
  bool _isLoading = true;

  static const _categories = [
    'general', 'documents', 'clothing', 'electronics', 'toiletries',
  ];

  String _catLabel(AppLocalizations l10n, String cat) {
    switch (cat) {
      case 'documents': return l10n.prepCatDocuments;
      case 'clothing': return l10n.prepCatClothing;
      case 'electronics': return l10n.prepCatElectronics;
      case 'toiletries': return l10n.prepCatToiletries;
      default: return l10n.categoryOther;
    }
  }

  @override
  void initState() { super.initState(); _loadItems(); }

  Future<void> _loadItems() async {
    try {
      final items = await context.read<TripProvider>().getChecklistItems(widget.tripId);
      if (mounted) setState(() { _items = items; _isLoading = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorSavingTrip(e.toString()))),
        );
      }
    }
  }

  Map<String, List<ChecklistItem>> get _grouped {
    final map = <String, List<ChecklistItem>>{};
    for (final cat in _categories) { map[cat] = []; }
    for (final item in _items) {
      map.putIfAbsent(item.category, () => []);
      map[item.category]!.add(item);
    }
    map.removeWhere((_, v) => v.isEmpty);
    return map;
  }

  Future<void> _showAddItemDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    String chosenCat = _selectedCategory;

    final result = await showDialog<List<String>>( context: context,
        builder: (ctx) => StatefulBuilder(
            builder: (ctx, setDialogState) => AlertDialog(
              title: Text(l10n.addItem),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller, autofocus: true,
                    inputFormatters: [LengthLimitingTextInputFormatter(200)],
                    decoration: InputDecoration(
                      labelText: l10n.itemName,
                      hintText: l10n.addItemHint,
                    ),
                    onSubmitted: (val) => Navigator.pop(ctx, [val.trim(), chosenCat]),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: _categories.map((cat) => ChoiceChip(
                      label: Text(_catLabel(l10n, cat)),
                      selected: chosenCat == cat,
                      onSelected: (s) => setDialogState(() => chosenCat = cat),
                    )).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.notNow)),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, [controller.text.trim(), chosenCat]),
                  child: Text(l10n.addItem),
                ),
              ],
            ),
        ),
    );

    if (result != null && mounted) {
      final title = result[0];
      final cat = result[1];
      if (title.isNotEmpty) {
        setState(() => _selectedCategory = cat);
        await context.read<TripProvider>().addChecklistItem(
          tripId: widget.tripId, title: title, category: cat,
        );
        _loadItems();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final checkedCount = _items.where((i) => i.isChecked).length;
    final grouped = _grouped;
    final catKeys = grouped.keys.toList();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(l10n.packingList,
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          FilledButton.icon(
            onPressed: _showAddItemDialog,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text(l10n.addItem),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? const ShimmerPackingListPage()
          : RefreshIndicator(
              onRefresh: _loadItems,
              child: Column(children: [
                if (_items.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(children: [
                      Expanded(child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                              value: checkedCount / _items.length, minHeight: 6,
                              backgroundColor: cs.surfaceContainerHighest))),
                      const SizedBox(width: 12),
                      Text(l10n.itemsChecked(checkedCount, _items.length),
                          style: TextStyle(fontWeight: FontWeight.w600,
                              color: cs.onSurfaceVariant, fontSize: 13)),
                    ]),
                  ),
                Expanded(
                  child: _items.isEmpty
                      ? EmptyState(
                          icon: Icons.checklist_rounded, title: l10n.noItemsYet,
                          subtitle: l10n.prepDescription,
                          action: FilledButton.tonalIcon(
                              onPressed: _showAddItemDialog,
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: Text(l10n.addItem)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _buildItemCount(grouped, catKeys),
                          itemBuilder: (_, i) => _buildItem(grouped, catKeys, i, l10n, cs),
                        ),
                ),
              ]),
            ),
    );
  }

  int _buildItemCount(Map<String, List<ChecklistItem>> grouped, List<String> keys) {
    int count = 0;
    for (final k in keys) {
      count += 1; // section header
      count += grouped[k]!.length;
    }
    return count;
  }

  Widget _buildItem(Map<String, List<ChecklistItem>> grouped, List<String> keys,
      int i, AppLocalizations l10n, ColorScheme cs) {
    int idx = 0;
    for (final k in keys) {
      if (i == idx) {
        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(_catLabel(l10n, k),
              style: TextStyle(fontWeight: FontWeight.bold,
                  color: cs.primary, fontSize: 14)),
        );
      }
      idx++;
      final items = grouped[k]!;
      if (i < idx + items.length) {
        return PackingListItem(
          tripId: widget.tripId,
          item: items[i - idx],
          colorScheme: cs,
          onDeleted: _loadItems,
        );
      }
      idx += items.length;
    }
    return const SizedBox.shrink();
  }
}
