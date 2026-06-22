import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';
import 'package:animations_in_flutter/model/checklist_item.dart';
import 'package:animations_in_flutter/providers/trip_provider.dart';
import 'package:animations_in_flutter/views/widgets/common/confirmation_dialog.dart';

class PackingListItem extends StatelessWidget {
  final String tripId;
  final ChecklistItem item;
  final ColorScheme colorScheme;
  final VoidCallback onDeleted;

  const PackingListItem({
    super.key,
    required this.tripId,
    required this.item,
    required this.colorScheme,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => showConfirmationDialog(
        context: context,
        title: l10n.confirmDeleteTitle(item.title),
        message: l10n.confirmDeleteMessage,
        icon: Icons.delete_rounded,
      ),
      background: Container(
        alignment: isRtl ? Alignment.centerLeft : Alignment.centerRight,
        padding: EdgeInsets.only(
          right: isRtl ? 0 : 20, left: isRtl ? 20 : 0),
        decoration: BoxDecoration(
          color: colorScheme.error, borderRadius: BorderRadius.circular(16)),
        child: Icon(Icons.delete_rounded, color: colorScheme.onError),
      ),
      onDismissed: (_) async {
        await context.read<TripProvider>().deleteChecklistItem(tripId, item.id);
        onDeleted();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: item.isChecked
              ? colorScheme.primaryContainer.withAlpha(60)
              : colorScheme.surfaceContainerHighest.withAlpha(60),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isChecked
                ? colorScheme.primary.withAlpha(80)
                : colorScheme.outlineVariant.withAlpha(128),
          ),
        ),
        child: CheckboxListTile(
          value: item.isChecked,
          onChanged: (val) async {
            await context.read<TripProvider>().toggleChecklistItem(
                tripId, item.id, val ?? false);
            onDeleted();
          },
          title: Text(item.title, style: TextStyle(
            decoration: item.isChecked ? TextDecoration.lineThrough : null,
            color: item.isChecked
                ? colorScheme.onSurfaceVariant
                : colorScheme.onSurface,
          )),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ),
    );
  }
}
