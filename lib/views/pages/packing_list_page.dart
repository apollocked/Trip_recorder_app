import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/model/checklist_item.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/widgets/confirmation_dialog.dart';
import 'package:animations_in_flutter/views/widgets/empty_state.dart';

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
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final items = await context.read<TripProvider>().getChecklistItems(
        widget.tripId,
      );
      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorSavingTrip(e.toString()))),
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
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.itemName,
            hintText: l10n.addItemHint,
          ),
          onSubmitted: (val) => Navigator.pop(ctx, val.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.notNow),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l10n.addItem),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      await context.read<TripProvider>().addChecklistItem(
        tripId: widget.tripId,
        title: result,
      );
      _loadItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final checkedCount = _items.where((i) => i.isChecked).length;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.packingList,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _showAddItemDialog,
            tooltip: l10n.addItem,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadItems,
              child: Column(
                children: [
                  if (_items.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: checkedCount / _items.length,
                                minHeight: 6,
                                backgroundColor:
                                    colorScheme.surfaceContainerHighest,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.itemsChecked(checkedCount, _items.length),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: _items.isEmpty
                        ? EmptyState(
                            icon: Icons.checklist_rounded,
                            title: l10n.noItemsYet,
                            action: FilledButton.tonalIcon(
                              onPressed: _showAddItemDialog,
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: Text(l10n.addItem),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return Dismissible(
                                key: ValueKey(item.id),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (direction) =>
                                    showConfirmationDialog(
                                      context: context,
                                      title: l10n.confirmDeleteTitle(
                                        item.title,
                                      ),
                                      message: l10n.confirmDeleteMessage,
                                      icon: Icons.delete_rounded,
                                    ),
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: colorScheme.error,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.delete_rounded,
                                    color: colorScheme.onError,
                                  ),
                                ),
                                onDismissed: (_) async {
                                  await context
                                      .read<TripProvider>()
                                      .deleteChecklistItem(
                                        widget.tripId,
                                        item.id,
                                      );
                                  _loadItems();
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: item.isChecked
                                        ? colorScheme.primaryContainer
                                              .withAlpha(60)
                                        : colorScheme.surfaceContainerHighest
                                              .withAlpha(60),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: item.isChecked
                                          ? colorScheme.primary.withAlpha(80)
                                          : colorScheme.outlineVariant
                                                .withAlpha(128),
                                    ),
                                  ),
                                  child: CheckboxListTile(
                                    value: item.isChecked,
                                    onChanged: (val) async {
                                      await context
                                          .read<TripProvider>()
                                          .toggleChecklistItem(
                                            widget.tripId,
                                            item.id,
                                            val ?? false,
                                          );
                                      _loadItems();
                                    },
                                    title: Text(
                                      item.title,
                                      style: TextStyle(
                                        decoration: item.isChecked
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color: item.isChecked
                                            ? colorScheme.onSurfaceVariant
                                            : colorScheme.onSurface,
                                      ),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
