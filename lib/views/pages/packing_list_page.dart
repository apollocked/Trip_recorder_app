import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/model/checklist_item.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
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
  bool _isLoading = true;

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

  Future<void> _showAddItemDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.addItem),
        content: TextField(
          controller: controller, autofocus: true,
          inputFormatters: [LengthLimitingTextInputFormatter(200)],
          decoration: InputDecoration(labelText: l10n.itemName, hintText: l10n.addItemHint),
          onSubmitted: (val) => Navigator.pop(ctx, val.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.notNow)),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: Text(l10n.addItem)),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && mounted) {
      await context.read<TripProvider>().addChecklistItem(tripId: widget.tripId, title: result);
      _loadItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final checkedCount = _items.where((i) => i.isChecked).length;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(l10n.packingList,
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.add_rounded),
            onPressed: _showAddItemDialog, tooltip: l10n.addItem)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                          itemCount: _items.length,
                          itemBuilder: (_, i) => PackingListItem(
                              tripId: widget.tripId, item: _items[i],
                              colorScheme: cs, onDeleted: _loadItems)),
                ),
              ]),
            ),
    );
  }
}
