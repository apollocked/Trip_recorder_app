import 'package:flutter/material.dart';
import 'package:animations_in_flutter/core/l10n/app_localizations.dart';

class DatePickerField extends StatelessWidget {
  final IconData icon;
  final String label;
  final DateTime? currentDate;
  final ValueChanged<DateTime> onDateChanged;
  final bool isOptional;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;

  const DatePickerField({
    super.key,
    required this.icon,
    required this.label,
    required this.currentDate,
    required this.onDateChanged,
    this.isOptional = false,
    required this.colorScheme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate:
              currentDate ?? DateTime.now().add(const Duration(days: 1)),
          firstDate: isOptional ? DateTime.now() : DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (date == null) return;
        if (!context.mounted) return;
        if (isOptional) {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(currentDate ?? DateTime.now()),
          );
          if (time == null) return;
          if (!context.mounted) return;
          onDateChanged(
            DateTime(date.year, date.month, date.day, time.hour, time.minute),
          );
        } else {
          onDateChanged(date);
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: colorScheme.primary),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: currentDate != null
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            if (currentDate != null)
              _DateDisplay(date: currentDate!, colorScheme: colorScheme)
            else
              Text(
                l10n.notSet,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
          ],
        ),
      ),
    );
  }
}

class _DateDisplay extends StatelessWidget {
  final DateTime date;
  final ColorScheme colorScheme;
  const _DateDisplay({required this.date, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}",
          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(width: 6),
        Text(
          "${date.day}/${date.month}/${date.year}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
